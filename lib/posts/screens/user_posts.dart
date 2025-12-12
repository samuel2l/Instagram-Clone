import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/posts/models/Post.dart';
import 'package:instagram/posts/repository/post_repository.dart';
import 'package:instagram/posts/screens/post_details.dart';

class UserPosts extends ConsumerStatefulWidget {
  const UserPosts({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserPostsState();
}

class _UserPostsState extends ConsumerState<UserPosts> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: ref.watch(postRepositoryProvider).getUserPosts(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.red,));
        } else if (snapshot.hasError) {
          return Text("Something went wrong: ${snapshot.error}");
        } else if (snapshot.hasData) {
          final posts = snapshot.data!;

          if (posts.isEmpty) {
            return Text("User has no posts");
          } else {
            return GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final firstUrl = post.mediaUrls[0];

                final isImage =
                    firstUrl.endsWith('.jpg') ||
                    firstUrl.endsWith('.jpeg') ||
                    firstUrl.endsWith('.png') ||
                    firstUrl.endsWith('.webp');

                return FutureBuilder<Widget>(
                  future:
                      isImage
                          ? Future.value(
                            Image.network(firstUrl, fit: BoxFit.cover),
                          )
                          : Future.value(
                            Image.asset("assets/images/IMG_3846.JPG"),
                          ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(),);
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error);
                    } else {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return PostDetails(post: post);
                              },
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: snapshot.data!,
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        } 
        else {
          return Text("Unexpected error");
        }
      },
    );
  }

  // Future<Widget> _buildVideoThumbnail(String videoUrl) async {
  //   final Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
  //     video: videoUrl,
  //     imageFormat: ImageFormat.JPEG,
  //     maxWidth: 64,
  //     quality: 15,
  //   );

  //   if (thumbnailBytes != null) {
  //     return Image.memory(thumbnailBytes, fit: BoxFit.cover);
  //   } else {
  //     return Icon(Icons.videocam_off);
  //   }
  // }
}
