import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:instagram/posts/repository/post_repository.dart';

class Reels extends ConsumerStatefulWidget {
  const Reels({super.key});

  @override
  ConsumerState<Reels> createState() => _ReelsState();
}

class _ReelsState extends ConsumerState<Reels> {
  late PageController pageController;
  CachedVideoPlayerPlusController? controller;

  List<dynamic>? reelData;
  List<String> reels = [];

  int currentIndex = 0;
  bool isHolding = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _loadReels();
  }

  Future<void> _loadReels() async {
    reelData = await ref.read(postRepositoryProvider).getReels();

    reels = reelData!
        .map<String>((reel) => reel["imageUrls"][0] as String)
        .toList();

    await _playVideo(0);
  }

  Future<void> _playVideo(int index) async {
    if (index < 0 || index >= reels.length) return;

    final newController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(reels[index]),
    );

    await newController.initialize();
    await newController.play();

    controller?.dispose();

    setState(() {
      controller = newController;
      currentIndex = index;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || reelData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: GestureDetector(
        onLongPress: () {
          controller?.pause();
          setState(() => isHolding = true);
        },
        onLongPressUp: () {
          controller?.play();
          setState(() => isHolding = false);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              controller: pageController,
              itemCount: reels.length,
              onPageChanged: (index) {
                _playVideo(index);
              },
              itemBuilder: (context, index) {
                return CachedVideoPlayerPlus(controller!);
              },
            ),

            /// ❤️ LIKE + COUNT
            Positioned(
              right: 10,
              bottom: 220,
              child: Column(
                children: [
                  IconButton(
                    icon: FutureBuilder<bool>(
                      future: ref
                          .watch(postRepositoryProvider)
                          .hasLikedPost(
                            reelData![currentIndex]["postId"],
                          ),
                      builder: (context, snapshot) {
                        return Icon(
                          snapshot.data == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: snapshot.data == true
                              ? Colors.red
                              : Colors.white,
                        );
                      },
                    ),
                    onPressed: () {
                      ref
                          .read(postRepositoryProvider)
                          .toggleLikePost(
                            reelData![currentIndex]["postId"],
                          );
                    },
                  ),
                  StreamBuilder(
                    stream: ref
                        .watch(postRepositoryProvider)
                        .getLikesCount(
                          reelData![currentIndex]["postId"],
                        ),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data?.toString() ?? "0",
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// ⏸ HOLD INDICATOR
            if (isHolding)
              const Center(
                child: Icon(
                  Icons.pause_circle_filled,
                  size: 80,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}