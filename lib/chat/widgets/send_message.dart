import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/utils/constants.dart';
import 'package:instagram/utils/utils.dart';

class SendMessage extends ConsumerStatefulWidget {
  final AppUserModel? user;

  const SendMessage({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SendMessageState();
}

class _SendMessageState extends ConsumerState<SendMessage> {
  String? file;
  String? mediaFilePath;

  FocusNode focusNode = FocusNode();
  bool showEmojis = false;
  final TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                decoration: InputDecoration(hintText: "Type a message..."),
              ),
            ),
            IconButton(
              onPressed: () async {
                file = await pickImageFromGallery(context);
                if (file != "") {
                  mediaFilePath = await uploadImageToCloudinary(file);

                  ref.watch(showReplyProvider.notifier).state
                      ? ref
                          .read(chatRepositoryProvider)
                          .sendFile(
                            receiverId:
                                widget.user != null
                                    ? widget.user!.firebaseUID
                                    : "",
                            senderId: FirebaseAuth.instance.currentUser!.uid,
                            chatId: ref.watch(chatIdProvider),
                            messageType: image,
                            imageUrl: mediaFilePath!,
                            repliedTo:
                                ref.read(messageToReplyProvider)!.senderId,
                            reply:
                                ref
                                    .read(messageToReplyProvider.notifier)
                                    .state!
                                    .text,
                            replyType:
                                ref
                                    .read(messageToReplyProvider.notifier)
                                    .state!
                                    .type,
                          )
                      : ref
                          .read(chatRepositoryProvider)
                          .sendFile(
                            receiverId:
                                widget.user != null
                                    ? widget.user!.firebaseUID
                                    : "",
                            senderId: FirebaseAuth.instance.currentUser!.uid,
                            chatId: ref.watch(chatIdProvider),
                            messageType: image,
                            imageUrl: mediaFilePath!,
                          );
                  mediaFilePath = "";
                  ref.watch(showReplyProvider.notifier).state = false;
                  setState(() {});
                }
              },
              icon: Icon(Icons.photo),
            ),

            IconButton(
              onPressed: () async {
                GiphyGif? gif = await pickGIF(context);
                if (gif != null) {
                  ref.watch(showReplyProvider.notifier).state
                      ? ref
                          .read(chatRepositoryProvider)
                          .sendFile(
                            receiverId:
                                widget.user != null
                                    ? widget.user!.firebaseUID
                                    : "",
                            senderId: FirebaseAuth.instance.currentUser!.uid,
                            chatId: ref.watch(chatIdProvider),
                            messageType: GIF,
                            imageUrl: gif.images?.original?.url ?? "",
                            repliedTo:
                                ref.read(messageToReplyProvider)!.senderId,
                            reply:
                                ref
                                    .read(messageToReplyProvider.notifier)
                                    .state!
                                    .text,
                            replyType:
                                ref
                                    .read(messageToReplyProvider.notifier)
                                    .state!
                                    .type,
                          )
                      : ref
                          .read(chatRepositoryProvider)
                          .sendFile(
                            receiverId:
                                widget.user != null
                                    ? widget.user!.firebaseUID
                                    : "",
                            senderId: FirebaseAuth.instance.currentUser!.uid,
                            chatId: ref.watch(chatIdProvider),
                            messageType: GIF,
                            imageUrl: gif.images?.original?.url ?? "",
                          );
                  ref.watch(messageToReplyProvider.notifier).state = null;
                  ref.watch(showReplyProvider.notifier).state = false;
                  setState(() {});
                }
              },
              icon: Icon(Icons.gif),
            ),
            IconButton(
              onPressed: () async {
                file = await pickVideoFromGallery(context);
                if (file != "" || file != null) {
                  mediaFilePath = await uploadVideoToCloudinary(file);
                  if (mediaFilePath != "") {
                    ref.watch(showReplyProvider.notifier).state
                        ? ref
                            .read(chatRepositoryProvider)
                            .sendFile(
                              receiverId:
                                  widget.user != null
                                      ? widget.user!.firebaseUID
                                      : "",
                              senderId: FirebaseAuth.instance.currentUser!.uid,
                              chatId: ref.watch(chatIdProvider),
                              messageType: video,
                              imageUrl: mediaFilePath!,
                              repliedTo:
                                  ref.read(messageToReplyProvider)!.senderId,

                              reply:
                                  ref
                                      .read(messageToReplyProvider.notifier)
                                      .state!
                                      .text,
                              replyType:
                                  ref
                                      .read(messageToReplyProvider.notifier)
                                      .state!
                                      .type,
                            )
                        : ref
                            .read(chatRepositoryProvider)
                            .sendFile(
                              receiverId:
                                  widget.user != null
                                      ? widget.user!.firebaseUID
                                      : "",
                              senderId: FirebaseAuth.instance.currentUser!.uid,
                              chatId: ref.watch(chatIdProvider),
                              messageType: video,
                              imageUrl: mediaFilePath!,
                            );
                    mediaFilePath = "";
                    ref.watch(showReplyProvider.notifier).state = false;
                    setState(() {});
                  }
                }
              },
              icon: Icon(Icons.attachment),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () async {
                final text = messageController.text.trim();

                if (text.isNotEmpty) {
                  final chatData =
                      ref.watch(showReplyProvider)
                          ? await ref
                              .read(chatRepositoryProvider)
                              .sendMessage(
                                receiverId:
                                    widget.user != null
                                        ? widget.user!.firebaseUID
                                        : "",
                                senderId:
                                    FirebaseAuth.instance.currentUser!.uid,
                                messageText: text,
                                chatId: ref.watch(chatIdProvider),
                                repliedTo:
                                    ref.read(messageToReplyProvider)!.senderId,
                                reply:
                                    ref
                                        .read(messageToReplyProvider.notifier)
                                        .state!
                                        .text,
                                replyType:
                                    ref
                                        .read(messageToReplyProvider.notifier)
                                        .state!
                                        .type,
                                
                              )
                          : await ref
                              .read(chatRepositoryProvider)
                              .sendMessage(
                                receiverId:
                                    widget.user != null
                                        ? widget.user!.firebaseUID
                                        : "",
                                senderId:
                                    FirebaseAuth.instance.currentUser!.uid,
                                messageText: text,
                                chatId: ref.watch(chatIdProvider),
                              );
                  messageController.clear();
                  if (ref.watch(chatIdProvider).isEmpty && chatData != "") {
                    ref.read(chatIdProvider.notifier).state = chatData;
                  }
                }
                ref.watch(messageToReplyProvider.notifier).state = null;
                ref.watch(showReplyProvider.notifier).state = false;
                setState(() {});
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
                      messageController.selection = TextSelection.collapsed(
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
                  if (textSelection.start < 0 || textSelection.end < 0) {
                    messageController.text += emoji.emoji;
                    messageController.selection = TextSelection.collapsed(
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
    );
  }
}
