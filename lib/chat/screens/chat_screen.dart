import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/chat/models/chat_data.dart';
import 'package:instagram/chat/models/message.dart';
import 'package:instagram/chat/models/message_to_reply.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/add_member.dart';
import 'package:instagram/chat/screens/remove_member.dart';
import 'package:instagram/chat/widgets/image_message.dart';
import 'package:instagram/chat/widgets/reply_widget.dart';
import 'package:instagram/chat/widgets/send_message.dart';
import 'package:instagram/chat/widgets/text_message.dart';
import 'package:instagram/chat/widgets/video_message.dart';
import 'package:instagram/utils/constants.dart';
import 'package:instagram/utils/utils.dart';
import 'package:instagram/video%20calls/repository/video_call_repository.dart';
import 'package:instagram/video%20calls/screens/group_video_call_screen.dart';
import 'package:instagram/video%20calls/screens/video_call_screen.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.user, required this.chatData});
  final AppUserModel? user;
  final ChatData chatData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController scrollController = ScrollController();
  late ChatData localChatData;

  bool showEmojis = false;
  FocusNode focusNode = FocusNode();

  late final bool isGroup;
  @override
  void initState() {
    super.initState();
    isGroup = widget.chatData.isGroup;

    localChatData = widget.chatData;

  
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGroup ? widget.chatData.groupName! : widget.user!.profile.name,
        ),
        actions:
            isGroup
                ? [
                  GestureDetector(
                    onDoubleTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return RemoveMember(
                              chatId: ref.watch(chatIdProvider),
                            );
                          },
                        ),
                      );
                    },
                    child: const Text("remove"),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onDoubleTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return AddMember(chatId: ref.watch(chatIdProvider));
                          },
                        ),
                      );
                    },
                    child: const Text("add"),
                  ),
                  StreamBuilder(
                    stream: ref
                        .watch(videoCallRepositoryProvider)
                        .checkIncomingCalls(ref.watch(chatIdProvider)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final callData = snapshot.data ?? {};
                      // print("$callData this is the group call Data");

                      if (callData.isEmpty) {
                        return IconButton(
                          onPressed: () async {
                            ref
                                .read(videoCallRepositoryProvider)
                                .sendCallData(
                                  calleeId: ref.watch(chatIdProvider),
                                  callType: "video",
                                  channelId:
                                      "${ref.watch(chatIdProvider)} ${widget.chatData.groupName}",
                                );

                            String? res;
                            res = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return GroupVideoCallScreen(
                                    channelId:
                                        "${ref.watch(chatIdProvider)} ${widget.chatData.groupName}",
                                    calleeId: ref.watch(chatIdProvider),
                                  );
                                },
                              ),
                            );
                            if (res == "call ended") {
                              showSnackBar(
                                context: context,
                                content: "Call ended",
                              );
                            }
                          },
                          icon: const Icon(Icons.call),
                        );
                      } else {
                        return IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return GroupVideoCallScreen(
                                    channelId: callData['channelId'],
                                    calleeId: ref.watch(chatIdProvider),
                                  );
                                },
                              ),
                            );
                            // }, // <-- Fixed missing comma
                            // title: Text(
                            //   "Incoming call from ${callData['callerId']}",
                            // ),
                            // subtitle: Text("Channel: ${callData['channelId']}"
                          },
                          icon: Icon(Icons.home),
                        );
                      }
                    },
                  ),
                ]
                : [
                  StreamBuilder(
                    stream: ref
                        .watch(videoCallRepositoryProvider)
                        .checkIncomingCalls(
                          FirebaseAuth.instance.currentUser!.uid,
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final callData = snapshot.data ?? {};
                      // print("$callData this is the call Data");

                      if (callData.isEmpty) {
                        return IconButton(
                          onPressed: () async {
                            ref
                                .read(videoCallRepositoryProvider)
                                .sendCallData(
                                  calleeId:
                                      widget.user != null
                                          ? widget.user!.firebaseUID
                                          : "",
                                  callType: "video",
                                  channelId:
                                      "${FirebaseAuth.instance.currentUser?.uid} ${widget.user?.firebaseUID}",
                                );

                            String? res;
                            res = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return VideoCallScreen(
                                    channelId:
                                        "${FirebaseAuth.instance.currentUser?.uid} ${widget.user?.firebaseUID}",
                                    calleeId:
                                        widget.user != null
                                            ? widget.user!.firebaseUID
                                            : "",
                                  );
                                },
                              ),
                            );
                            if (res == "call ended") {
                              showSnackBar(
                                context: context,
                                content: "Call ended",
                              );
                            }
                          },
                          icon: const Icon(Icons.call),
                        );
                      } else {
                        return IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return VideoCallScreen(
                                    channelId: callData['channelId'],
                                    calleeId:
                                        widget.user != null
                                            ? widget.user!.firebaseUID
                                            : "",
                                  );
                                },
                              ),
                            );
                            // title: Text(
                            //   "Incoming call from ${callData['callerId']}",
                            // ),
                            // subtitle: Text("Channel: ${callData['channelId']}"
                          },
                          icon: Icon(Icons.home),
                        );
                      }
                    },
                  ),
                ],
      ),
      body: FutureBuilder(
        future: ref
            .read(chatRepositoryProvider)
            .getUsersByIds(widget.chatData.participants, isGroup),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return Center(child: Text("error loading chat data"));
          }
          if (asyncSnapshot.hasData) {
            final participantData = asyncSnapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<Message>>(
                    stream: ref
                        .watch(chatRepositoryProvider)
                        .getMessages(ref.watch(chatIdProvider) ?? ""),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final messages = snapshot.data ?? [];
                      if (messages.isEmpty) {
                        return Center(
                          child: Text("No messages with this user"),
                        );
                      }
                      SchedulerBinding.instance.addPostFrameCallback((
                        timeStamp,
                      ) {
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
                          final currMessage = messages[index];
                          final currUserId =
                              ref.read(userProvider).value!.firebaseUID;
                          final isMyReplyMessage =
                              currMessage.repliedTo == currUserId;
                          final isSender = currMessage.senderId == currUserId;
                          if (!currMessage.isSeen &&
                              currUserId != currMessage.senderId) {
                            ref
                                .read(chatRepositoryProvider)
                                .updateSeen(
                                  ref.watch(chatIdProvider) ?? "123",
                                  currMessage.id,
                                );
                          }

                          return SwipeTo(
                            onLeftSwipe: (details) {
                              if (isSender) {
                                final messageToReply = {
                                  "senderId": currMessage.senderId,
                                  "text": currMessage.content,
                                  "type": currMessage.type,
                                };
                                ref.read(showReplyProvider.notifier).state =
                                    true;
                                ref
                                    .read(messageToReplyProvider.notifier)
                                    .state = MessageToReply.fromMap(
                                  messageToReply,
                                );
                              }
                            },
                            onRightSwipe: (details) {
                              if (!isSender) {
                                final messageToReply = {
                                  "senderId": currMessage.senderId,
                                  "text": currMessage.content,
                                  "type": currMessage.type,
                                };
                                ref.read(showReplyProvider.notifier).state =
                                    true;
                                ref
                                    .read(messageToReplyProvider.notifier)
                                    .state = MessageToReply.fromMap(
                                  messageToReply,
                                );
                              }
                            },
                            child: Align(
                              alignment:
                                  isSender
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,

                              child: Column(
                                crossAxisAlignment:
                                    isSender
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  currMessage.repliedTo.toString().isEmpty
                                      ? SizedBox.shrink()
                                      : ReplyWidget(
                                        isSender: isSender,
                                        isMyReplyMessage: isMyReplyMessage,
                                        currMessage: currMessage,
                                        participantData: participantData,
                                        user: widget.user,
                                        isGroup: isGroup,
                                      ),
                                  currMessage.type == image ||
                                          currMessage.type == GIF
                                      ? ImageMessage(
                                        currMessage: currMessage,
                                        isSender: isSender,
                                      )
                                      : currMessage.type == video
                                      ? VideoMessage(
                                        url: currMessage.content,
                                        isSender: isSender,
                                      )
                                      : TextMessage(
                                        currMessage: currMessage,
                                        isSender: isSender,
                                      ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Consumer(
                        // child: Container(),
                        builder: (context, ref, child) {
                          final showReply = ref.watch(showReplyProvider);
                          final messageToReply = ref.watch(
                            messageToReplyProvider,
                          );
                          return ClipRect(
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              heightFactor: showReply ? 1.0 : 0.0,
                              alignment: Alignment.topCenter,
                              child:
                                  showReply
                                      ? Container(
                                        color: Colors.lightGreenAccent,
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  ref
                                                              .read(
                                                                messageToReplyProvider,
                                                              )
                                                              ?.senderId ==
                                                          ref
                                                              .read(
                                                                userProvider,
                                                              )
                                                              .value
                                                              ?.firebaseUID
                                                      ? "Me"
                                                      : isGroup
                                                      ? participantData[ref
                                                              .read(
                                                                messageToReplyProvider,
                                                              )!
                                                              .senderId]!
                                                          .profile
                                                          .name
                                                      : widget
                                                          .user!
                                                          .profile
                                                          .name,
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                          showReplyProvider
                                                              .notifier,
                                                        )
                                                        .state = false;
                                                  },
                                                  icon: Icon(Icons.close),
                                                ),
                                              ],
                                            ),
                                            messageToReply?.type == image ||
                                                    messageToReply?.type == GIF
                                                ? SizedBox(
                                                  height: 70,
                                                  width: 70,
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        messageToReply!.text,
                                                  ),
                                                )
                                                : messageToReply?.type == video
                                                ? SizedBox(
                                                  height: 70,
                                                  width: 70,
                                                  child: VideoMessage(
                                                    url: messageToReply!.text,
                                                    isSender:
                                                        messageToReply
                                                            .senderId ==
                                                        FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid,
                                                  ),
                                                )
                                                : Text(messageToReply!.text),
                                          ],
                                        ),
                                      )
                                      : SizedBox.shrink(),
                            ),
                          );
                        },
                      ),
                      SendMessage(user: widget.user),
                    ],
                  ),
                ),
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
