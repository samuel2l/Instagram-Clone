import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/posts/models/Post.dart';
import 'package:instagram/posts/repository/post_repository.dart';
import 'package:instagram/posts/widgets/post_video.dart';
import 'package:instagram/profile/repository/profile_repository.dart';

class PostDetail extends ConsumerStatefulWidget {
  const PostDetail({super.key, required this.post});
  final Post post;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostDetailState();
}

class _PostDetailState extends ConsumerState<PostDetail> {
  final PageController _controller = PageController();
  TextEditingController commentController = TextEditingController();
  bool hasProfileLoaded = false;
  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Column(
      children: [
        FutureBuilder(
          future: ref
              .read(profileRepositoryProvider)
              .getUserProfileOnce(uid: post.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile();
            } else if (snapshot.hasError) {
              return Text("Error loading user data");
            } else if (snapshot.hasData) {
              final userProfile = snapshot.data!;
              if (!hasProfileLoaded) {
                // Wait until Flutter finishes building the UI, and THEN run setState.
                //basically since i need to set state after build is complete and the only place i know the profile loaded isin the builder and state cannot be updated in a builder since part of the tree is still being built
                //so use the add post frame callback to schedule the state update after build is complete
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    hasProfileLoaded = true;
                  });
                });
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(userProfile.profile.dp),
                ),
                title: Text(userProfile.profile.username),
              );
            }
            return Text("No user data");
          },
        ),
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _controller,
            itemCount: post.mediaUrls.length,
            itemBuilder: (context, index) {
              String imageUrl = post.mediaUrls[index];

              return hasProfileLoaded
                  ? Stack(
                    children: [
                      imageUrl.endsWith('.jpg') ||
                              imageUrl.endsWith('.jpeg') ||
                              imageUrl.endsWith('.png') ||
                              imageUrl.endsWith('.webp')
                          ? SizedBox(
                            height: 400,
                            width: double.infinity,
                            child: Image.network(
                              post.mediaUrls[index],
                              fit: BoxFit.cover,
                            ),
                          )
                          : SizedBox(
                            height: 400,
                            width: double.infinity,

                            child: PostVideo(url: imageUrl),
                          ),

                      Positioned(
                        right: 0,
                        child: Container(
                          height: 30,
                          width: 34,
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color(0xFF121212),
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(14),
                              right: Radius.circular(14),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}/${post.mediaUrls.length}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : Container();
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
                                      commentText:
                                          commentController.text.trim(),
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
    );
  }
}
