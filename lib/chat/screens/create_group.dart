import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/chat_screen.dart';

class CreateGroup extends ConsumerStatefulWidget {
  const CreateGroup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateGroupState();
}

class _CreateGroupState extends ConsumerState<CreateGroup> {
  final groupNameController = TextEditingController();
  Set<String> selectedGroupMembers = {};

  @override
  Widget build(BuildContext context) {
    selectedGroupMembers.add(FirebaseAuth.instance.currentUser!.uid);
    return Scaffold(
      appBar: AppBar(title: Text("create new group")),
      body: Column(
        children: [
          TextField(controller: groupNameController),
          Expanded(
            child: StreamBuilder(
              stream: ref.watch(chatRepositoryProvider).getUsers(),
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
                        selectedGroupMembers.add(user["uid"]);

                      },
                      title: Text(user["email"]),
                    );
                  },
                );
              },
            ),
          ),
          TextButton(
            onPressed: ()async {
              final res=await ref
                  .read(chatRepositoryProvider)
                  .createGroupChat(
                    userIds: selectedGroupMembers.toList(),
                    groupName: groupNameController.text.trim(),
                  );

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ChatScreen(chatData:res ,user: {});
                  },
                ),
              );
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }
}
