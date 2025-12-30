import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/chat_screen.dart';

class CreateGroup extends ConsumerStatefulWidget {
  const CreateGroup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateGroupState();
}

//
class _CreateGroupState extends ConsumerState<CreateGroup> {
  final groupNameController = TextEditingController();
  final Set<String> selectedGroupMembers = {};

  @override
  void initState() {
    super.initState();
    selectedGroupMembers.add(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("create new group")),
      body: Column(
        children: [
          TextField(controller: groupNameController),
          Expanded(
            child: FutureBuilder(
              future: ref
                  .read(chatRepositoryProvider)
                  .getMutualFollowers(
                    ref.read(userProvider).value!.firebaseUID,
                  ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return Center(
                    child: Text("No mutual followers to add to group"),
                  );
                }

                // final users = snapshot.data!;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Consumer(
                      builder: (context, ref, child) {
                        return CheckboxListTile(
                          checkboxShape: CircleBorder(),

                          checkColor: Colors.black,
                          checkboxScaleFactor: 1.4,
                          visualDensity: const VisualDensity(
                            horizontal: -1,
                            vertical: -1,
                          ),
                          value: selectedGroupMembers.contains(
                            user.firebaseUID,
                          ),

                          onChanged: (bool? val) {
                            setState(() {
                              if (val == false) {
                                selectedGroupMembers.remove(user.firebaseUID);
                              } else {
                                selectedGroupMembers.add(user.firebaseUID);
                              }
                            });
                          },
                          title: Text(user.profile.username),
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
              final res = await ref
                  .read(chatRepositoryProvider)
                  .createGroupChat(
                    userIds: selectedGroupMembers.toList(),
                    groupName: groupNameController.text.trim(),
                  );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(chatData: res, user: null),
                ),
              );
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
