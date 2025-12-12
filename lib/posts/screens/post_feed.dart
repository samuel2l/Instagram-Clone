import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/posts/models/Post.dart';
import 'package:instagram/posts/repository/post_repository.dart';
import 'package:instagram/posts/widgets/post_video.dart';

class PostFeed extends ConsumerStatefulWidget {
  const PostFeed({super.key, required this.post});
  final Post post;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostFeedState();
}

class _PostFeedState extends ConsumerState<PostFeed> {
  final PageController _controller = PageController();
  TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _controller,
              itemCount: post.mediaUrls.length,
              itemBuilder: (context, index) {
                String imageUrl = post.mediaUrls[index];
                return imageUrl.endsWith('.jpg') ||
                        imageUrl.endsWith('.jpeg') ||
                        imageUrl.endsWith('.png') ||
                        imageUrl.endsWith('.webp')
                    ? Image.network(post.mediaUrls[index], fit: BoxFit.cover)
                    : PostVideo(url: imageUrl);
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ref.read(postRepositoryProvider).toggleLikePost(post.postId);
                  setState(() {});
                },
                icon: FutureBuilder<bool>(
                  future: ref
                      .watch(postRepositoryProvider)
                      .hasLikedPost(post.postId),
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
                    .getLikesCount(post.postId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("${snapshot.data}");
                  }
                  if (snapshot.hasError) {
                    return Text("0");
                  }
                  return CircularProgressIndicator();
                },
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StreamBuilder(
                            stream: ref
                                .watch(postRepositoryProvider)
                                .getPostComments(post.postId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data != null &&
                                    snapshot.data!.isNotEmpty) {
                                  final commentData = snapshot.data!;
                                  return Expanded(
                                    child: ListView.builder(
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        final comment = commentData[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              comment["dp"],
                                            ),
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
                          Container(
                            padding: EdgeInsets.all(8),
                            child: TextField(
                              controller: commentController,
                              onSubmitted: (value) async {
                                final profileData =
                                    await ref
                                        .watch(authRepositoryProvider)
                                        .getUser();
                                if (profileData != null) {
                                  await ref
                                      .read(postRepositoryProvider)
                                      .addCommentToPost(
                                        postId: post.postId,
                                        email: profileData.email,
                                        dp: profileData.profile.dp,
                                        commentText: commentController.text.trim(),
                                      );
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.chat_bubble_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
