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
                      print("curr user profile??? $currUserProfile");

                      return SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UserStories(
                                          userStories: stories[currUser]!,
                                        ),
                                  ),
                                );
                              },
                              //trick to create the gradient border around the avatar
                              //use 2 containers, the outer one with gradient and inner one with circle avatar
                              //use first containers padding to create the border thickness effect
                              //essentially it is a rounded container with color of thhe gradient given but we put an element in it(the child container) with a padding which gives us the desired effect
                              child: Container(
                                width: 80, // 2 * radius + border
                                height: 80, // 2 * radius + border
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        index % 2 == 0
                                            ? [
                                              const Color.fromARGB(
                                                255,
                                                103,
                                                1,
                                                121,
                                              ),
                                              const Color.fromARGB(
                                                255,
                                                255,
                                                64,
                                                50,
                                              ),
                                            ]
                                            : [
                                              const Color.fromARGB(
                                                255,
                                                255,
                                                64,
                                                50,
                                              ),
                                              const Color.fromARGB(
                                                255,
                                                103,
                                                1,
                                                121,
                                              ),
                                            ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    5,
                                  ), // border thickness

                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(
                                      5,
                                    ), // border thickness trick again
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundImage: CachedNetworkImageProvider(
                                        currUserProfile['dp'] ??
                                            'https://www.pngitem.com/pimgs/m/150-1503941_user-profile-default-image-png-clipart-png-download.png',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              currUserProfile?['email'].split('@')[0],
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
