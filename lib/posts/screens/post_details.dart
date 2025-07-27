import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/chat/widgets/video_message.dart';
import 'package:instagram/utils/constants.dart';

class PostDetails extends ConsumerStatefulWidget {
  const PostDetails({super.key, required this.post});
  final Map<String, dynamic> post;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostDetailsState();
}

class _PostDetailsState extends ConsumerState<PostDetails> {
  final PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            height: 300, // adjust as needed
            child: PageView.builder(
              controller: _controller,
              itemCount: (widget.post["imageUrls"] as List).length,
              itemBuilder: (context, index) {
                String imageUrl = widget.post["imageUrls"][index];
                return imageUrl.endsWith('.jpg') ||
                        imageUrl.endsWith('.jpeg') ||
                        imageUrl.endsWith('.png') ||
                        imageUrl.endsWith('.webp')
                    ? Image.network(
                      widget.post["imageUrls"][index],
                      fit: BoxFit.cover,
                    )
                    : VideoMessage(url: imageUrl, isSender: false,playOnInit: true,);
              },
            ),
          ),
        ],
      ),
    );
  }
}
