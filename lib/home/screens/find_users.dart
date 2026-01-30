import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/profile/repository/profile_repository.dart';
import 'package:instagram/profile/screens/profile_details.dart';

class FindUsers extends ConsumerStatefulWidget {
  const FindUsers({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FindUsersState();
}

class _FindUsersState extends ConsumerState<FindUsers> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search users by username",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
      body: StreamBuilder<List<AppUserModel>>(
        stream: ref
            .watch(profileRepositoryProvider)
            .searchUsersByUsername(searchController.text.trim().toLowerCase()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(child: Text("No users match input search"));
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
                        return ProfileDetails(user: user);
                      },
                    ),
                  );
                },
                title: Text(user.profile.username),
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(user.profile.dp),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
