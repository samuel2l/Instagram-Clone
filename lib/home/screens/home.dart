import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/chat_screen.dart';
import 'package:instagram/chat/screens/create_group.dart';
import 'package:instagram/home/screens/find_users.dart';
import 'package:instagram/live%20stream/repository/livestream_repository.dart';
import 'package:instagram/live%20stream/screens/livestream_screen.dart';
import 'package:instagram/live%20stream/screens/start_livestream.dart';
import 'package:instagram/posts/screens/create_post.dart';
import 'package:instagram/profile/repository/profile_repository.dart';
import 'package:instagram/reels/screens/reels.dart';
import 'package:instagram/stories/repository/story_repository.dart';
import 'package:instagram/stories/screens/select_story_image.dart';
import 'package:instagram/stories/screens/user_stories.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Map<String, dynamic> stories = {};

    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: ref
          .watch(getUserProvider)
          .when(
            data: (user) {
              return Column(
                children: [
                  // Container(
                  //   height: 160,
                  //   color: Colors.red,
                  //   child: StreamBuilder(
                  //     stream:
                  //         ref.watch(liveStreamRepositoryProvider).getLiveUsers(),
                  //     builder: (context, snapshot) {
                  //       if (snapshot.connectionState == ConnectionState.waiting) {
                  //         return const Center(child: CircularProgressIndicator());
                  //       }

                  //       if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  //         return const Center(child: Text("No users are live"));
                  //       }

                  //       final liveUsers = snapshot.data!;
                  //       print("ah users $liveUsers");

                  //       return Expanded(
                  //         child: ListView.builder(

                  //           // scrollDirection: Axis.horizontal,
                  //           itemCount: liveUsers.length,
                  //           itemBuilder: (context, index) {
                  //             final user = liveUsers[index];
                  //             return ListTile(
                  //               title: Text(user['email'] ?? 'Unknown'),
                  //               subtitle: const Text('Live'),
                  //               onTap: () {
                  //                 Navigator.of(context).push(
                  //                   MaterialPageRoute(
                  //                     builder: (context) {
                  //                       return LivestreamScreen(
                  //                         role: ClientRoleType.clientRoleAudience,
                  //                         channelId:
                  //                             "${user["uid"]} ${user["email"]}", // replace with your correct field
                  //                       );
                  //                     },
                  //                   ),
                  //                 );
                  //               },
                  //             );
                  //           },
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  StreamBuilder(
                    stream:
                        ref.watch(liveStreamRepositoryProvider).getLiveUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No users are live"));
                      }

                      final liveUsers = snapshot.data!;

                      return SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: liveUsers.length,
                          itemBuilder: (context, index) {
                            final user = liveUsers[index];

                            // print("${user["uid"]} ${user["email"]}");
                            return SingleChildScrollView(
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          ref.read(
                                            liveStreamRepositoryProvider,
                                          );
                                          return LivestreamScreen(
                                            role:
                                                ClientRoleType
                                                    .clientRoleAudience,
                                            channelId:
                                                "${user["uid"]} ${user["email"]}",
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Card(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.videocam,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            user['email'] ?? 'Unknown',
                                            textAlign: TextAlign.center,
                                          ),
                                          const Text(
                                            'Live',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(authRepositoryProvider).logoutUser(context);
                      ref.invalidate(getUserProvider);
                    },
                    child: Text("Logout"),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      await ref
                          .read(profileRepositoryProvider)
                          .createOrUpdateUserProfile(
                            uid: FirebaseAuth.instance.currentUser!.uid,
                            bio: "seventh user of app",
                            name: "Saani Deishini",
                            context: context,
                          );
                    },
                    child: Text("Create profile sharp sharp"),
                  ),

                  // GestureDetector(
                  //   onTap: () async {
                  //     await ref
                  //         .read(profileRepositoryProvider)
                  //         .getUserProfile(
                  //           uid: FirebaseAuth.instance.currentUser!.uid,
                  //           context: context,
                  //         );
                  //   },
                  //   child: Text("see prpfile"),
                  // ),
                  FutureBuilder(
                    future: ref.read(authRepositoryProvider).getUser(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("error fetching profile");
                      }
                      if (snapshot.hasData) {
                        final userData = snapshot.data;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text("Followers"),
                                    Text(
                                      "${userData!.profile.followers.length}",
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("Following"),
                                    Text(
                                      "${userData.profile.following.length}",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(userData.profile.bio),
                            CircleAvatar(
                              // minRadius: 50,
                              backgroundImage: NetworkImage(
                                userData.profile.dp,
                              ),
                            ),
                          ],
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),

                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CreateGroup()),
                      );
                    },
                    child: Text("Create Group"),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreatePost(),
                        ),
                      );
                    },
                    child: Text("Post"),
                  ),
                  // UserPosts(userId: FirebaseAuth.instance.currentUser!.uid),

                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => FindUsers()),
                      );
                    },
                    child: Text("Connect with others"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return StartLivestreamScreen();
                          },
                        ),
                      );
                    },
                    child: Text("Start Live stream"),
                  ),
                  Text(user?.email ?? ""),
                  Text(user?.firebaseUID ?? ""),
                  SizedBox(height: 20),
                  Text("CHATS", style: TextStyle(fontSize: 22)),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: ref
                          .watch(chatRepositoryProvider)
                          .getUserChats(user?.firebaseUID ?? ""),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        final chats = snapshot.data ?? [];

                        if (chats.isEmpty) {
                          return Center(
                            child: Text(
                              "You have no chats. Connect with users.",
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];

                            Timestamp? timestamp = chat["lastMessageTime"];
                            String formattedTime = '';
                            if (timestamp != null) {
                              formattedTime = timestamp.toDate().toString();
                            }

                            return chat["isGroup"]
                                ? ListTile(
                                  title: Text(chat["groupName"]),
                                  subtitle: Text(chat["lastMessage"]),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ChatScreen(
                                              chatData: chat,
                                              user: {},
                                            ),
                                      ),
                                    );
                                  },
                                  trailing: Text(formattedTime),
                                )
                                : FutureBuilder<Map<String, dynamic>>(
                                  future: ref
                                      .read(chatRepositoryProvider)
                                      .getUserById(
                                        (chat["participants"][0] ==
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid)
                                            ? chat["participants"][1]
                                            : chat["participants"][0],
                                      ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ListTile(
                                        title: Text("Loading..."),
                                        subtitle: Text("Fetching user info"),
                                      );
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.hasError) {
                                      return ListTile(
                                        title: Text("Unknown User"),
                                        subtitle: Text("Error loading user"),
                                      );
                                    }

                                    final receiver = snapshot.data!;

                                    return ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ChatScreen(
                                                  chatData: chat,
                                                  user: receiver,
                                                ),
                                          ),
                                        );
                                      },
                                      title: Text(receiver["email"]),
                                      subtitle: Text(chat["lastMessage"] ?? ""),
                                      trailing: Text(formattedTime),
                                    );
                                  },
                                );
                          },
                        );
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
     
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return SelectStoryImage();
                          },
                        ),
                      );
                    },
                    child: Text("add imgs"),
                  ),
                  TextButton(
                    onPressed: () async {
     
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return Reels();
                          },
                        ),
                      );
                    },
                    child: Text("Watch reels"),
                  ),
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
                        return Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.red,
                          child: ListView.builder(
                            itemCount: users.length,
                            scrollDirection: Axis.horizontal,

                            itemBuilder: (context, index) {
                              final currUser = users[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return UserStories(
                                          userStories: stories[currUser],
                                        );
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
                                  child: Center(child: Text(currUser)),
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
              );
            },
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
