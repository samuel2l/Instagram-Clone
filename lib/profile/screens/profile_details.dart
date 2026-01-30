import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/profile/widgets/dp_story_indicator.dart';

class ProfileDetails extends ConsumerStatefulWidget {
  const ProfileDetails({super.key, required this.user});
  final AppUserModel user;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends ConsumerState<ProfileDetails> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Details")),
      body: Column(
        children: [
          DpStoryIndicator(user: widget.user)
          
                  ],
      ),
    );
  }
}
