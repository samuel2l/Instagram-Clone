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
                );
              },
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              fixedSize: Size(MediaQuery.sizeOf(context).width * 0.9, 60),

              backgroundColor: const Color.fromARGB(255, 1, 86, 242),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
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
    );
  }
}
