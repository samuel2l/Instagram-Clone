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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(selectedGroupMembersProvider.notifier);
      notifier.state = {
        ...notifier.state,
        FirebaseAuth.instance.currentUser!.uid,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("create new group")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                hintText: "Enter group name",
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 1, 86, 242),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
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
                          if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data ?? [];

                  if (users.isEmpty) {
                    return Center(
                      child: Text("No mutual followers to add to group"),
                    );
                  }

                  // final users = snapshot.data!;

                  return ListView.builder(
                    padding: EdgeInsets.all(0),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.all(0),
                        activeColor: const Color.fromARGB(255, 1, 86, 242),
                        checkboxShape: CircleBorder(),
                      
                        checkColor: Colors.white,
                        checkboxScaleFactor: 1.4,
                      
                        value: ref
                            .watch(selectedGroupMembersProvider)
                            .contains(user.firebaseUID),
                      
                        onChanged: (val) {
                          final notifier = ref.read(
                            selectedGroupMembersProvider.notifier,
                          );
                      
                          if (val == true) {
                            notifier.state = {
                              ...notifier.state,
                              user.firebaseUID,
                            };
                          } else {
                            notifier.state =
                                notifier.state
                                    .where((id) => id != user.firebaseUID)
                                    .toSet();
                          }
                        },
                        title: Text(user.profile.username),
                      );
                    },
                  );
                },
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fixedSize: Size(MediaQuery.sizeOf(context).width, 60),

                backgroundColor: const Color.fromARGB(255, 1, 86, 242),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (groupNameController.text.trim().isEmpty) {
                  return showDialog(
                    context: context,

                    builder: (context) {
                      return AlertDialog(
                        content: Text("Please enter a group name."),
                      );
                    },
                  );
                }
                final res = await ref
                    .read(chatRepositoryProvider)
                    .createGroupChat(
                      userIds: ref.read(selectedGroupMembersProvider).toList(),
                      groupName: groupNameController.text.trim(),
                    );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(chatData: res, user: null),
                  ),
                );
              },
              child: const Text(
                "Create Group Chat",
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
