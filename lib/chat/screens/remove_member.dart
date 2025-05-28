import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/chat/repository/chat_repository.dart';

class RemoveMember extends ConsumerStatefulWidget {
  const RemoveMember({super.key, required this.chatId});
  final String chatId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RemoveMemberState();
}

class _RemoveMemberState extends ConsumerState<RemoveMember> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Remove member")),
      body: FutureBuilder<List<String>>(
        future: ref
            .watch(chatRepositoryProvider)
            .getGroupMembers(chatId: widget.chatId),
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
                      .removeMemberFromGroup(
                        userId: user,
                        chatId: widget.chatId,
                      );
                },
                title: Text(user),
              );
            },
          );
        },
      ),
    );
  }
}
