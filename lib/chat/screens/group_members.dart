import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/profile/screens/profile_details.dart';

class GroupMembers extends ConsumerStatefulWidget {
  const GroupMembers({super.key, required this.members});
  final List<AppUserModel> members;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupMembersState();
}

class _GroupMembersState extends ConsumerState<GroupMembers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Group Members")),
      body: Expanded(
        child: ListView.builder(
          itemCount: widget.members.length,
          itemBuilder: (context, index) {
            final member = widget.members[index];
            return ListTile(
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ProfileDetails(user: member);
                    },
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundImage: NetworkImage(member.profile.dp),
              ),
              title: Text(member.profile.name),
              subtitle: Text("@${member.profile.username}"),
            );
          },
        ),
      ),
    );
  }
}
