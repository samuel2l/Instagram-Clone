import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:instagram/chat/repository/chat_repository.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? chatId;
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getChatId();
  }

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

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]["text"] ?? ""),
                      subtitle: Text(messages[index]["senderId"] ?? ""),
                    );
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
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = messageController.text.trim();
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
