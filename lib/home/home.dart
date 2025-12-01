import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram/posts/screens/create_post.dart';
import 'package:instagram/stories/repository/story_repository.dart';
import 'package:instagram/stories/screens/user_stories.dart';
import 'package:instagram/chat/screens/chats.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePost()),
            );
          },
        ),
        title: Text(
          "Instagram",
          style: TextStyle(
            fontFamily: 'ImperialScript',
            fontWeight: FontWeight.bold,
            fontSize: 34,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Chats()),
              );
            },
            icon: SvgPicture.asset(
              "assets/svgs/send.svg",
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: ref.read(storyRepositoryProvider).getValidStories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Unexpected error"));
              }

              final stories = snapshot.data ?? {};
              List users = stories.keys.toList();
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: ListView.builder(
                    itemCount: users.length,
                    scrollDirection: Axis.horizontal,

                    itemBuilder: (context, index) {
                      final currUser = users[index];
                      print("curr user??? $currUser");
                      final currUserProfile =
                          stories[currUser]?[0]["userProfile"];

                      return SizedBox(
                        width: 100,
                        child: Column(
                          children: [GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return
                                    // Center(child: Text("User Stories here"));
                                    UserStories(userStories: stories[currUser]!);
                                  },
                                ),
                              );
                            },
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.green,
                          
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      currUserProfile?['dp'] ??
                                      "https://plus.unsplash.com/premium_photo-1764435536930-c93558fa72c6?q=80&w=3023&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                                ),
                              ),
                            ),
                          ),
                            SizedBox(height: 5),
                            Text(
                              currUserProfile?['email'].split('@')[0] ,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],  
                        ),
                      );
                    },
                  ),
                );
              }
              return Text("unexpected error");
            },
          ),
        ],
      ),
    );
  }
}
