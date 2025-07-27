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
            return Text("ahahahahaha");
            // Or return your actual list view or grid view of posts here
          }
        } else {
          return Text("Unexpected error");
        }
      },
    );
  }
}
