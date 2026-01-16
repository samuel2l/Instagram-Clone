import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/chat/repository/chat_repository.dart';

class AddMember extends ConsumerStatefulWidget {
  const AddMember({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddMemberState();
}

class _AddMemberState extends ConsumerState<AddMember> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //invalidate the selected members provider
      ref.invalidate(selectedGroupMembersProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add member")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: ref
                    .read(chatRepositoryProvider)
                    .getMutualFollowers(
                      ref.watch(userProvider).value!.firebaseUID,
                      context,
                      chatId: ref.read(chatDataProvider)!.chatId,
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
                        enabled:
                            !ref
                                .read(chatDataProvider)!
                                .participants
                                .contains(user.firebaseUID),
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

            // ref.read(selectedGroupMembersProvider.notifier).state = {};
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
                await ref
                    .read(chatRepositoryProvider)
                    .addMembersToGroup(
                      chatId: ref.read(chatDataProvider)!.chatId,
                      userIds: ref.read(selectedGroupMembersProvider).toList(),
                      context: context,
                    );

                ref.read(selectedGroupMembersProvider.notifier).state = {};
              },
              child: const Text(
                "Add Member(s)",
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
