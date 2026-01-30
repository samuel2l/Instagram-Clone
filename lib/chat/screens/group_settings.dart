import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/add_member.dart';
import 'package:instagram/chat/screens/create_group.dart';
import 'package:instagram/chat/screens/group_members.dart';
import 'package:instagram/chat/screens/remove_members.dart';

class GroupSettings extends ConsumerStatefulWidget {
  const GroupSettings({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends ConsumerState<GroupSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: CachedNetworkImageProvider(
                ref.read(chatDataProvider)!.isGroup
                    ? ref.read(chatDataProvider)!.dp
                    : ref.read(messageRecipientProvider)!.profile.dp,
              ),
            ),
            Text(
              ref.read(chatDataProvider)!.isGroup
                  ? ref.read(chatDataProvider)!.groupName!
                  : ref.read(messageRecipientProvider)!.profile.name,

              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                "change name and image",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AddMember();
                        },
                      ),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: Column(
                    children: [
                      Icon(Icons.person_add_outlined, size: 45),
                      SizedBox(height: 10),
                      Text("Add"),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return RemoveMembers();
                        },
                      ),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: Column(
                    children: [
                      Icon(Icons.person_remove_outlined, size: 45),
                      SizedBox(height: 10),
                      Text("Remove"),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: Column(
                    children: [
                      Icon(Icons.edit_outlined, size: 45),
                      SizedBox(height: 10),
                      Text("Edit"),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () async {
                    final members = await ref
                        .read(chatRepositoryProvider)
                        .getGroupMembers(
                          ref.read(chatDataProvider)!.chatId,
                          context,
                        );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return GroupMembers(members: members);
                        },
                      ),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: Column(
                    children: [
                      Icon(Icons.person_outline, size: 45),
                      SizedBox(height: 10),
                      Text("Members"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text("Something isn't working"),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: Icon(Icons.lock_outline_rounded),
              title: Text("Privacy and safety"),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),

            ListTile(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => CreateGroup()));
              },
              leading: Icon(Icons.group_add),
              title: Text("Create a new group chat"),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
