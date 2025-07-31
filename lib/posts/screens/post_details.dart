import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
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
  TextEditingController commentController = TextEditingController();
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
                  ref
                      .read(postRepositoryProvider)
                      .toggleLikePost(widget.post["postId"]);
                  setState(() {});
                },
                icon: FutureBuilder<bool>(
                  future: ref
                      .watch(postRepositoryProvider)
                      .hasLikedPost("${widget.post["postId"]}"),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data == true
                          ? Icon(Icons.favorite, color: Colors.red)
                          : Icon(Icons.favorite_outline, color: Colors.black);
                    }
                    return Icon(Icons.favorite_outline, color: Colors.black);
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
            ],
          ),
          TextField(
            controller: commentController,
            onSubmitted: (value) async {
              final profileData =
                  await ref.watch(authRepositoryProvider).getUser();
              if (profileData != null) {
                await ref
                    .read(postRepositoryProvider)
                    .addCommentToPost(
                      postId: widget.post["postId"],
                      email: profileData.email,
                      dp: profileData.profile.dp,
                      commentText: commentController.text.trim(),
                    );
              }
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: ref
                  .watch(postRepositoryProvider)
                  .getPostComments(widget.post["postId"]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    print("comments data????? ${snapshot.data}");
                    final commentData = snapshot.data!;
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final comment = commentData[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(comment["dp"]),
                            ),
                            subtitle: Text("${comment["email"]}"),
                            title: Text("${comment["text"]}"),
                          );
                        },
                      ),
                    );
                  }
                }
                return Center(child: Text("No comments yet"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
