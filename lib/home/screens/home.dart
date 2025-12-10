import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/posts/screens/create_post.dart';
import 'package:instagram/stories/repository/story_repository.dart';
import 'package:instagram/stories/screens/select_story_image.dart';
import 'package:instagram/stories/screens/user_stories.dart';
import 'package:instagram/chat/screens/chats.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  bool currentUserHasStory = true;

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
            future: ref
                .read(storyRepositoryProvider)
                .getValidStories(ref.read(getUserProvider).value?.firebaseUID),
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
                      var currUserProfile;
                      if (stories[currUser] != null &&
                          stories[currUser]!.isNotEmpty) {
                        currUserProfile = stories[currUser]?[0]["userProfile"];
                      } else {
                        //the only time a user will be returned even if they have no stories is when they are the current user
                        currUserProfile =
                            ref.read(getUserProvider).value?.toMap();
                        currentUserHasStory = false;
                      }

                      print("the curr user profile? $currUserProfile");
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

                              child:
                                  //if user has no story then its just a circle avatar with dp and a plus icon to post
                                  currUser ==
                                              ref
                                                  .read(getUserProvider)
                                                  .value
                                                  ?.firebaseUID &&
                                          !currentUserHasStory
                                      ? Stack(
                                        children: [
                                          Container(
                                            width: 80, // 2 * radius + border
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: CircleAvatar(
                                              radius: 80,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                    currUserProfile['dp'],
                                                  ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                SelectStoryImage(),
                                                      ),
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                      :
                                      //trick to create the gradient border around the avatar
                                      //use 2 containers, the outer one with gradient and inner one with circle avatar
                                      //use first containers padding to create the border thickness effect
                                      //essentially it is a rounded container with color of thhe gradient given but we put an element in it(the child container) with a padding which gives us the desired effect
                                      FutureBuilder(
                                        future: ref
                                            .read(storyRepositoryProvider)
                                            .hasUserWatchedAllStories(
                                              ownerId: currUser,
                                              currentUserId:
                                                  ref
                                                      .read(getUserProvider)
                                                      .value
                                                      ?.firebaseUID ??
                                                  "",
                                            ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          }
                                          if (snapshot.hasError) {
                                            return Text("error");
                                          }
                                          final hasWatchedAllStories =
                                              snapshot.data ?? false;

                                          return Stack(
                                            children: [
                                              Container(
                                                width:
                                                    80, // 2 * radius + border
                                                height:
                                                    80, // 2 * radius + border
                                                decoration: BoxDecoration(
                                                  color:
                                                      hasWatchedAllStories
                                                          ? const Color.fromARGB(
                                                            255,
                                                            200,
                                                            199,
                                                            199,
                                                          )
                                                          : null,
                                                  gradient:
                                                      !hasWatchedAllStories
                                                          ? LinearGradient(
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
                                                            begin:
                                                                Alignment
                                                                    .topLeft,
                                                            end:
                                                                Alignment
                                                                    .bottomRight,
                                                          )
                                                          : null,
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
                                                        currUser ==
                                                                ref
                                                                    .read(
                                                                      getUserProvider,
                                                                    )
                                                                    .value
                                                                    ?.firebaseUID
                                                            ? currUserProfile['dp']
                                                            : currUserProfile['dp'] ??
                                                                'https://www.pngitem.com/pimgs/m/150-1503941_user-profile-default-image-png-clipart-png-download.png',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Container(
                                                    padding: EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    SelectStoryImage(),
                                                          ),
                                                        );
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              currUserProfile?['username'],
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
