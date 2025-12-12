import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/posts/repository/post_repository.dart';
import 'package:instagram/posts/screens/post_detail.dart';

class PostFeed extends ConsumerStatefulWidget {
  const PostFeed({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostFeedState();
}

class _PostFeedState extends ConsumerState<PostFeed> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: ref.read(postRepositoryProvider).getFeedPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          } else if (snapshot.hasError) {
            return Text("Something went wrong: ${snapshot.error}");
          } else if (snapshot.hasData) {
            final posts = snapshot.data!;
      
            if (posts.isEmpty) {
              return Text("No posts available");
            } else {
              return ListView.builder(
                
                shrinkWrap: true,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostDetail(post: posts[index]);
                },
              );
            }
          }
          return Text("No data");
        },
      ),
    );
  }
}
