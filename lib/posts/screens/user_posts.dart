import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/posts/repository/post_repository.dart';

class UserPosts extends ConsumerStatefulWidget {
  const UserPosts({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserPostsState();
}

class _UserPostsState extends ConsumerState<UserPosts> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ref.watch(postRepositoryProvider).getUserPosts(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Something went wrong: ${snapshot.error}");
        } else if (snapshot.hasData) {
          final posts = snapshot.data!;
          print("posts $posts");

          if (posts.isEmpty) {
            return Text("User has no posts");
          } else {
            return 
            GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            Map<String,dynamic> post=posts[index];
            return Container(
              color: Colors.red,
              child: Center(
                child: 
                // Text(
                //   '$index',
                //   style: TextStyle(color: Colors.white, fontSize: 20),
                // ),
                // post["imageUrls"][0].endsWith('.jpg') || post["imageUrls"][0].endsWith('.jpeg')||post["imageUrls"][0].endsWith('.png')||post["imageUrls"][0].endsWith('.webp')? 
                Image.network(post["imageUrls"][0])
                // :
              ),
            );
          },
        )
      ;

          }
        } else {
          return Text("Unexpected error");
        }
      },
    );
  }
}
