import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/chat/models/chat_data.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/chat_screen.dart';

class Chats extends ConsumerWidget {
  const Chats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: ref
          .watch(getUserProvider)
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
                  // GestureDetector(
                  //   onTap: () {
                  //     ref.read(authRepositoryProvider).logoutUser(context);
                  //     ref.invalidate(getUserProvider);
                  //   },
                  //   child: Text("Logout"),
                  // ),
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
                                      title: Text(receiver.email),
                                      subtitle: Text(chat.lastMessage!),
                                      trailing: Text(formattedTime),
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
