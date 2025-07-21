import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/chat_screen.dart';
import 'package:instagram/profile/screens/profile_details.dart';

class FindUsers extends ConsumerStatefulWidget {
  const FindUsers({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FindUsersState();
}

class _FindUsersState extends ConsumerState<FindUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connect with others")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        // return ChatScreen(chatData: {},user: user);
                        return ProfileDetails(uid: user["uid"]);
                      },
                    ),
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
