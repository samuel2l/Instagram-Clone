import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/posts/repository/post_repository.dart';
import 'package:instagram/posts/widgets/post_video.dart';

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
            height: 400,
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
                    : PostVideo(url: imageUrl);
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  print("post data???? ${widget.post}");
                  ref
                      .read(postRepositoryProvider)
                      .toggleLikePost(widget.post["postId"]);
                },
                icon: FutureBuilder<bool>(
                  future: ref
                      .watch(postRepositoryProvider)
                      .hasLikedPost("${widget.post["postId"]}"),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Icon(
                        Icons.favorite,
                        color:
                            snapshot.data == true ? Colors.red : Colors.white,
                      );
                    }
                    return Icon(Icons.favorite, color: Colors.white);
                  },
                ),
              ),

              StreamBuilder(
                stream: ref
                    .watch(postRepositoryProvider)
                    .getLikesCount(widget.post["postId"]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("${snapshot.data}");
                  }

                  return Text(" ");
                },
              ),
              Text(
                "Likes ${widget.post["likes"].length}  ${widget.post["caption"]}",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
