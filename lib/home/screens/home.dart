import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/chat_screen.dart';
import 'package:instagram/chat/screens/create_group.dart';
import 'package:instagram/home/screens/find_users.dart';
import 'package:instagram/stories/repository/story_repository.dart';
import 'package:instagram/utils/constants.dart';
import 'package:instagram/utils/utils.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: ref
          .watch(getUserProvider)
          .when(
            data: (user) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(authRepositoryProvider).logoutUser(context);
                    },
                    child: Text("Logout"),
                  ),

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
                        MaterialPageRoute(builder: (context) => FindUsers()),
                      );
                    },
                    child: Text("Connect with others"),
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
                        print("chats gotten in home??? $chats");
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
                            print("a chat is$chat ${chat["chatId"]}");


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
                                      .getUserById( (chat["participants"][0] ==
                                        FirebaseAuth.instance.currentUser!.uid)
                                    ? chat["participants"][1]
                                    : chat["participants"][0]),
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
                      final imgPath = await pickImageFromGallery(context);
                      if (imgPath != null && imgPath.isNotEmpty) {
                        var mediaUrl = await uploadImageToCloudinary(imgPath);

                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        ref
                            .watch(storyRepositoryProvider)
                            .uploadStory(
                              uid!,
                              caption: "first story upload",
                              mediaType: image,
                              mediaUrl: "mediaUrl",
                            );
                      }
                    },
                    child: Text("Add Image"),
                  ),
                  TextButton(
                    onPressed: () async {
                      // final imgPath = await pickImageFromGallery(context);
                      // if (imgPath != null && imgPath.isNotEmpty) {
                      //   var mediaUrl = await uploadImageToCloudinary(imgPath);

                      //   final uid = FirebaseAuth.instance.currentUser?.uid;
                      //   ref
                      //       .watch(storyRepositoryProvider)
                      //       .uploadStory(
                      //         uid!,
                      //         caption: "first story upload",
                      //         mediaType: image,
                      //         mediaUrl: mediaUrl,
                      //       );
                      // }
                    },
                    child: Text("Add Image"),
                  ),
                  TextButton(
                    onPressed: () {
                      // ref.read(storyRepositoryProvider).getActiveStories();
                    },
                    child: Text("see stories"),
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
