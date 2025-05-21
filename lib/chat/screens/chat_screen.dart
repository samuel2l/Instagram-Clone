import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/widgets/video_message.dart';
import 'package:instagram/utils/constants.dart';
import 'package:instagram/utils/utils.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? chatId;
  String? file;
  String? filePath;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Future<void> getChatId() async {
    final id = await ref.read(chatRepositoryProvider).getChatId([
      FirebaseAuth.instance.currentUser!.uid,
      widget.user["uid"],
    ]);
    setState(() {
      chatId = id;
    });
  }

  @override
  void initState() {
    super.initState();
    getChatId();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user["email"])),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ref
                  .watch(chatRepositoryProvider)
                  .getMessages(chatId ?? ""),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(child: Text("No messages with this user"));
                }
                // scroll to bottom on new message ie everytime new messag new message is added to the stream
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  scrollController.jumpTo(
                    scrollController.position.minScrollExtent,
                  );
                });

                return ListView.builder(
                  //observed that if i do not sort the messages in descending firebase returns in ascending
                  //to prevent this manipulation you could just sort
                  //another way is to make the list view reversed allowing it to show elements in the opposite
                  //and for the schenduler binding it should be to max scroll extent in the normal case but since its reversed its min scroll extent and will will rather go to the bottom not to the top
                  reverse: true,
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    if (messages[index]["type"] == null) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor:
                              messages[index]["senderId"] ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? const Color.fromARGB(255, 143, 207, 145)
                                  : Colors.white,
                          title: Text(messages[index]["text"] ?? ""),
                          subtitle: Text(messages[index]["senderId"] ?? ""),
                        ),
                      );
                    } else if (messages[index]["type"] == image) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          color:
                              messages[index]["senderId"] ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? const Color.fromARGB(255, 143, 207, 145)
                                  : Colors.white,
                          height: 250,
                          width: 250,
                          child: CachedNetworkImage(
                            imageUrl: messages[index]["text"],
                            placeholder:
                                (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                            errorWidget:
                                (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      );
                    } else if (messages[index]["type"] == video) {
                      return VideoMessage(url: messages[index]["text"],isSender:messages[index]["senderId"] ==
                                  FirebaseAuth.instance.currentUser!.uid);
                    } else {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(messages[index]["text"] ?? ""),
                          subtitle: Text(messages[index]["senderId"] ?? ""),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    file = await pickImageFromGallery(context);
                    filePath = await uploadToCloudinary(file);
                  },
                  icon: Icon(Icons.photo),
                ),

                IconButton(
                  onPressed: () async {
                    file = await pickVideoFromGallery(context);
                    filePath = await uploadToCloudinary(file);
                  },
                  icon: Icon(Icons.attachment),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = messageController.text.trim();

                    if (filePath != null) {
                      ref
                          .read(chatRepositoryProvider)
                          .sendFile(
                            receiverId: widget.user["uid"],
                            senderId: FirebaseAuth.instance.currentUser!.uid,
                            chatId: chatId ?? "",
                            messageType: video,
                            imageUrl: filePath!,
                          );
                    } else {
                      if (text.isNotEmpty) {
                        ref
                            .read(chatRepositoryProvider)
                            .sendMessage(
                              receiverId: widget.user["uid"],
                              senderId: FirebaseAuth.instance.currentUser!.uid,
                              messageText: text,
                              chatId: chatId ?? "",
                            );
                        messageController.clear();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
