import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/chat/repository/chat_repository.dart';

class AddMember extends ConsumerStatefulWidget {
  const AddMember({super.key, required this.chatId});
  final String chatId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddMemberState();
}

class _AddMemberState extends ConsumerState<AddMember> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add member")),
      body: StreamBuilder<List<Map<String, dynamic>>> (
        stream: ref
            .watch(chatRepositoryProvider)
            .getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(child: Text("No users in app"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                onTap: () {
                  ref
                      .read(chatRepositoryProvider)
                      .addMemberToGroup(
                        userId: user["uid"]??user["id"],
                        chatId: widget.chatId,
                      );
                },
                title: Text(user["email"]),
              );
            },
          );
        },
      ),
    );
  }
}
