import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/widgets/video_message.dart';
import 'package:instagram/utils/constants.dart';
import 'package:instagram/utils/utils.dart';
import 'package:swipe_to/swipe_to.dart';

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
  bool showReply = false;
  Map<String, dynamic> messageToReply = {};
  Future<void> getChatId() async {
    final id = await ref.read(chatRepositoryProvider).getChatId([
      FirebaseAuth.instance.currentUser!.uid,
      widget.user["uid"],
    ]);
    setState(() {
      chatId = id;
    });
  }

  bool showEmojis = false;
  FocusNode focusNode = FocusNode();

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
                    } else if (messages[index]["type"] == image ||
                        messages[index]["type"] == GIF) {
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
                      return VideoMessage(
                        url: messages[index]["text"],
                        isSender:
                            messages[index]["senderId"] ==
                            FirebaseAuth.instance.currentUser!.uid,
                      );
                    } else {
                      return SwipeTo(
                        onLeftSwipe: (details) {
                          showReply = true;
                          messageToReply = {
                            "senderId": messages[index]["senderId"],
                            "text": messages[index]["text"],
                          };
                          setState(() {});
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              ListTile(
                                   tileColor:
                              messages[index]["senderId"] ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? const Color.fromARGB(255, 143, 207, 145)
                                  : Colors.white,
                                title: Column(
                                  children: [
                                    messages[index]["repliedTo"].toString().isEmpty
                                        ? SizedBox.shrink()
                                        : Text(messages[index]["repliedTo"]??""),

                                    messages[index]["reply"].toString().isEmpty
                                        ? SizedBox.shrink()
                                        : Container(


                                          child: Text(messages[index]["reply"]??""),
                                        ),
                                    Text(messages[index]["text"] ?? ""),
                                  ],
                                ),
                                subtitle: Text(
                                  messages[index]["senderId"] ?? "",
                                ),
                              ),
                            ],
                          ),
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
            child: Column(
              children: [
                showReply
                    ? Container(
                      color: Colors.lightGreenAccent,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                messageToReply["senderId"] ==
                                        FirebaseAuth.instance.currentUser?.uid
                                    ? "Me"
                                    : messageToReply["senderId"],
                              ),
                              IconButton(
                                onPressed: () {
                                  showReply = false;
                                  setState(() {});
                                },
                                icon: Icon(Icons.close),
                              ),
                            ],
                          ),
                          Text(messageToReply["text"]),
                        ],
                      ),
                    )
                    : SizedBox.shrink(),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showEmojis = !showEmojis;
                        if (showEmojis) {
                          focusNode.unfocus();
                        } else {
                          focusNode.requestFocus();
                        }
                        setState(() {});
                      },
                      icon: Icon(Icons.emoji_emotions_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        // inputFormatters: [EmojiSafeFormatter()],
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        file = await pickImageFromGallery(context);
                        if (file != "")
                          filePath = await uploadToCloudinary(file);
                      },
                      icon: Icon(Icons.photo),
                    ),

                    IconButton(
                      onPressed: () async {
                        GiphyGif? gif = await pickGIF(context);
                        if (gif != null) {}
                        if (gif != null) {
                          ref
                              .read(chatRepositoryProvider)
                              .sendFile(
                                receiverId: widget.user["uid"],
                                senderId:
                                    FirebaseAuth.instance.currentUser!.uid,
                                chatId: chatId ?? "",
                                messageType: GIF,
                                imageUrl: gif.images?.original?.url ?? "",
                              );
                        }
                      },
                      icon: Icon(Icons.gif),
                    ),
                    IconButton(
                      onPressed: () async {
                        file = await pickVideoFromGallery(context);
                        if (file != "") {
                          filePath = await uploadToCloudinary(file);
                        }
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
                                senderId:
                                    FirebaseAuth.instance.currentUser!.uid,
                                chatId: chatId ?? "",
                                messageType: video,
                                imageUrl: filePath!,
                              );
                        } else {
                          if (text.isNotEmpty) {
                            showReply
                                ? ref
                                    .read(chatRepositoryProvider)
                                    .sendMessage(
                                      receiverId: widget.user["uid"],
                                      senderId:
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
                                      messageText: text,
                                      chatId: chatId ?? "",
                                      repliedTo:
                                          FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      ?.uid ==
                                                  messageToReply["senderId"]
                                              ? "Me"
                                              : messageToReply["senderId"],
                                      reply: messageToReply["text"],
                                      replyType: text,
                                    )
                                : ref
                                    .read(chatRepositoryProvider)
                                    .sendMessage(
                                      receiverId: widget.user["uid"],
                                      senderId:
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
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
                showEmojis
                    ? SizedBox(
                      height: 250,
                      child: EmojiPicker(
                        onBackspacePressed: () {
                          final text = messageController.text;
                          final selection = messageController.selection;

                          if (selection.start <= 0) return;

                          final characters = text.characters;
                          int deleteOffset = selection.start;

                          int currentOffset = 0;
                          for (final char in characters) {
                            final nextOffset = currentOffset + char.length;
                            if (nextOffset >= deleteOffset) {
                              // Found the character to delete
                              final newText = text.replaceRange(
                                currentOffset,
                                nextOffset,
                                '',
                              );

                              // Update the text and cursor position
                              messageController.text = newText;
                              messageController
                                  .selection = TextSelection.collapsed(
                                offset: currentOffset,
                              );
                              return;
                            }
                            currentOffset = nextOffset;
                          }
                        },
                        onEmojiSelected: (category, emoji) {
                          final text = messageController.text;
                          final textSelection = messageController.selection;

                          // 🛡️ Prevent range error if selection is invalid
                          if (textSelection.start < 0 ||
                              textSelection.end < 0) {
                            messageController.text += emoji.emoji;
                            messageController
                                .selection = TextSelection.collapsed(
                              offset: messageController.text.length,
                            );
                            return;
                          }

                          final newText = text.replaceRange(
                            textSelection.start,
                            textSelection.end,
                            emoji.emoji,
                          );
                          final emojiLength = emoji.emoji.length;

                          messageController.text = newText;
                          messageController.selection = textSelection.copyWith(
                            baseOffset: textSelection.start + emojiLength,
                            extentOffset: textSelection.start + emojiLength,
                          );
                        },
                      ),
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
