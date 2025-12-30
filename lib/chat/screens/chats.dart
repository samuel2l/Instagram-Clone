import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/chat/models/chat_data.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/chat_screen.dart';
import 'package:instagram/chat/screens/create_group.dart';
import 'package:instagram/stories/repository/story_repository.dart';
import 'package:instagram/stories/screens/user_stories.dart';
import 'package:instagram/utils/utils.dart';

class Chats extends ConsumerWidget {
  const Chats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => CreateGroup()));
            },
          ),
        ],
      ),

      body: ref
          .watch(userProvider)
          .when(
            data: (user) {
              return Column(
                children: [
                  // StreamBuilder(
                  //   stream:
                  //       ref.watch(liveStreamRepositoryProvider).getLiveUsers(),
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return const Center(child: CircularProgressIndicator());
                  //     }

                  //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  //       return const Center(child: Text("No users are live"));
                  //     }

                  //     final liveUsers = snapshot.data!;

                  //     return SizedBox(
                  //       height: 100,
                  //       child: ListView.builder(
                  //         scrollDirection: Axis.horizontal,
                  //         itemCount: liveUsers.length,
                  //         itemBuilder: (context, index) {
                  //           final user = liveUsers[index];

                  //           // print("${user["uid"]} ${user["email"]}");
                  //           return SingleChildScrollView(
                  //             child: Container(
                  //               width: 100,
                  //               margin: const EdgeInsets.symmetric(
                  //                 horizontal: 8,
                  //               ),
                  //               child: GestureDetector(
                  //                 onTap: () {
                  //                   Navigator.of(context).push(
                  //                     MaterialPageRoute(
                  //                       builder: (context) {
                  //                         ref.read(
                  //                           liveStreamRepositoryProvider,
                  //                         );
                  //                         return LivestreamScreen(
                  //                           role:
                  //                               ClientRoleType
                  //                                   .clientRoleAudience,
                  //                           channelId:
                  //                               "${user["uid"]} ${user["email"]}",
                  //                         );
                  //                       },
                  //                     ),
                  //                   );
                  //                 },
                  //                 child: Card(
                  //                   child: Center(
                  //                     child: Column(
                  //                       mainAxisAlignment:
                  //                           MainAxisAlignment.center,
                  //                       children: [
                  //                         Icon(
                  //                           Icons.videocam,
                  //                           color: Colors.red,
                  //                         ),
                  //                         const SizedBox(height: 8),
                  //                         Text(
                  //                           user['email'] ?? 'Unknown',
                  //                           textAlign: TextAlign.center,
                  //                         ),
                  //                         const Text(
                  //                           'Live',
                  //                           style: TextStyle(color: Colors.red),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //     );
                  //   },
                  // ),
                  GestureDetector(
                    onTap: () {
                      ref.read(authRepositoryProvider).logoutUser(context);
                      ref.invalidate(userProvider);
                    },
                    child: Text("Logout"),
                  ),

                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(builder: (context) => CreateGroup()),
                  //     );
                  //   },
                  //   child: Text("Create Group"),
                  // ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(builder: (context) => FindUsers()),
                  //     );
                  //   },
                  //   child: Text("Connect with others"),
                  // ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return StartLivestreamScreen();
                  //         },
                  //       ),
                  //     );
                  //   },
                  //   child: Text("Start Live stream"),
                  // ),
                  Expanded(
                    child: StreamBuilder<List<ChatData>>(
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

                            String formattedTime = chat.lastMessageTime!;

                            return chat.isGroup
                                ? ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  horizontalTitleGap: 0,

                                  splashColor: Colors.transparent,
                                  leading: CircleAvatar(
                                    radius: 37,
                                    backgroundImage: CachedNetworkImageProvider(
                                      chat.dp,
                                    ),
                                  ),
                                  title: Text(chat.groupName!),
                                  subtitle: Text(chat.lastMessage!),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ChatScreen(
                                              chatData: chat,
                                              user: null,
                                            ),
                                      ),
                                    );
                                  },
                                  trailing: Text(formattedTime),
                                )
                                : FutureBuilder<AppUserModel?>(
                                  future: ref
                                      .read(chatRepositoryProvider)
                                      .getUserById(
                                        (chat.participants[0] ==
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid)
                                            ? chat.participants[1]
                                            : chat.participants[0],
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

                                    return GestureDetector(
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
                                      child: Container(
                                        //wrapping the row with a container is important cos GestureDetector only receives taps on areas that have a hit-testable render box.
                                        //A Row by itself:
                                        // 	•	Has no background
                                        // 	•	Only hit-tests where its children paint pixels
                                        // So:
                                        // 	•	Tapping empty space inside the row means there's nothing to hit
                                        // This does two important things:
                                        // 	1.	Forces the widget to paint a box
                                        // 	2.	Makes the entire rectangular area hit-testable
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Container(
                                              //chats with stories and without will have different sizes for their avatars + story indicator
                                              //sp center needs to be used to center it nicely even with varying sizes
                                              //also set a width as container will only use space it needs. giving fixed size means all elements center the same
                                              width: 86,
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 11,
                                              ),
                                              child: Center(
                                                child:
                                                    !chat.hasStory
                                                        ? CircleAvatar(
                                                          radius: 37,

                                                          backgroundImage:
                                                              CachedNetworkImageProvider(
                                                                chat.dp,
                                                              ),
                                                        )
                                                        : GestureDetector(
                                                          onTap: () async {
                                                            final userStories = await ref
                                                                .read(
                                                                  storyRepositoryProvider,
                                                                )
                                                                .getUserStories(
                                                                  chat.userId!,
                                                                );

                                                            Navigator.of(
                                                              context,
                                                            ).push(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => UserStories(
                                                                      userStories:
                                                                          userStories,
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: FutureBuilder(
                                                            future: ref
                                                                .read(
                                                                  storyRepositoryProvider,
                                                                )
                                                                .hasUserWatchedAllStories(
                                                                  ownerId:
                                                                      chat.userId!,
                                                                  currentUserId:
                                                                      ref
                                                                          .read(
                                                                            userProvider,
                                                                          )
                                                                          .value!
                                                                          .firebaseUID,
                                                                ),
                                                            builder: (
                                                              context,
                                                              asyncSnapshot,
                                                            ) {
                                                              if (asyncSnapshot
                                                                  .hasData) {
                                                                final hasWatched =
                                                                    asyncSnapshot
                                                                        .data!;
                                                                if (hasWatched) {
                                                                  return Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          3,
                                                                        ),

                                                                    decoration: const BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                      color:
                                                                          Color.fromARGB(
                                                                            255,
                                                                            211,
                                                                            211,
                                                                            211,
                                                                          ),
                                                                    ),
                                                                    child: Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            3,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            Colors.white,
                                                                        shape:
                                                                            BoxShape.circle,
                                                                      ),
                                                                      child: CircleAvatar(
                                                                        radius:
                                                                            37,
                                                                        backgroundImage:
                                                                            CachedNetworkImageProvider(
                                                                              chat.dp,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              }
                                                              return Container(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      3,
                                                                    ),
                                                                decoration: const BoxDecoration(
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Color(
                                                                        0xFF833AB4,
                                                                      ),
                                                                      Color(
                                                                        0xFFFD1D1D,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                child: Container(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        3,
                                                                      ),

                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                  ),
                                                                  child: CircleAvatar(
                                                                    radius: 37,
                                                                    backgroundImage:
                                                                        CachedNetworkImageProvider(
                                                                          chat.dp,
                                                                        ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  receiver.profile.name,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.65,
                                                  child: Row(
                                                    children: [
                                                      chat.lastMessage!.length <
                                                              40
                                                          ? Text(
                                                            chat.lastMessage ??
                                                                '',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                          )
                                                          : Expanded(
                                                            child: Text(
                                                              chat.lastMessage ??
                                                                  '',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                            ),
                                                          ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        timeAgoFromIso(
                                                          chat.lastMessageTime!,
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                          },
                        );
                      },
                    ),
                  ),

                  // TextButton(
                  //   onPressed: () async {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return Reels();
                  //         },
                  //       ),
                  //     );
                  //   },
                  //   child: Text("Watch reels"),
                  // ),
                ],
              );
            },
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
