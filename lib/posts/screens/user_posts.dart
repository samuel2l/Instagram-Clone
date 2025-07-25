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
    return Container(
      child: StreamBuilder(
        stream: ref.watch(postRepositoryProvider).getUserPosts(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error loading posts");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            print("gotten data????? ${snapshot.data}");
          }
          return Text("unexpected error");
        },
      ),
    );
  }
}
