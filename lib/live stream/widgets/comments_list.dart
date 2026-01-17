import 'package:flutter/material.dart';
import 'package:instagram/widgets/gif_sticker_message.dart';

class AnimatedCommentsList extends StatefulWidget {
  final List<Map<String, dynamic>> comments;

  const AnimatedCommentsList({
    super.key,
    required this.comments,
  });

  @override
  State<AnimatedCommentsList> createState() => _AnimatedCommentsListState();
}

class _AnimatedCommentsListState extends State<AnimatedCommentsList> {
  final ScrollController _scrollController = ScrollController();
  List<String> _previousCommentIds = [];

  @override
  void didUpdateWidget(AnimatedCommentsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-scroll to bottom when new comment arrives
    if (widget.comments.length > oldWidget.comments.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isNewComment(int index) {
    if (index >= widget.comments.length) return false;
    
    final currentIds = widget.comments
        .map((c) => c['id']?.toString() ?? c['text']?.toString() ?? '')
        .toList();
    
    final commentId = currentIds[index];
    final isNew = !_previousCommentIds.contains(commentId);
    
    // Update previous IDs after checking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _previousCommentIds = currentIds;
      }
    });
    
    return isNew;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comments.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80, top: 16, left: 8, right: 8),
      itemCount: widget.comments.length,
      itemBuilder: (context, index) {
        final comment = widget.comments[index];
        final isNew = _isNewComment(index);
        
        return AnimatedCommentBubble(
          email: comment['username'] ?? 'Unknown',
          text: comment['text'] ?? '',
          index: index,
          isNew: isNew,
          type: comment['type'],
        );
      },
    );
  }
}

class AnimatedCommentBubble extends StatefulWidget {
  final String email;
  final String text;
  final int index;
  final bool isNew;
  final String? type;

  const AnimatedCommentBubble({
    super.key,
    required this.email,
    required this.text,
    required this.index,
    required this.isNew,
    this.type,
  });

  @override
  State<AnimatedCommentBubble> createState() => _AnimatedCommentBubbleState();
}

class _AnimatedCommentBubbleState extends State<AnimatedCommentBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Stagger the animations based on index
    Future.delayed(Duration(milliseconds: widget.isNew ? 0 : widget.index * 50), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: widget.type == 'GIF'
                  ? GifStickerMessage(
                      email: widget.email,
                      content: widget.text,
                    )
                  : Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.email.split('@')[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}