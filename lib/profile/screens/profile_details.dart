import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/chat_screen.dart';
import 'package:instagram/posts/screens/user_posts.dart';
import 'package:instagram/profile/repository/profile_repository.dart';

class ProfileDetails extends ConsumerStatefulWidget {
  const ProfileDetails({super.key, required this.uid});
  final String uid;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends ConsumerState<ProfileDetails> {
  // Example dummy data. Replace with data from your provider or Firestore.
  final String name = "John Doe";
  final String bio = "Just a developer exploring the world.";
  final String email = "johndoe@example.com";
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Details")),
      body: FutureBuilder(
        future: ref
            .watch(profileRepositoryProvider)
            .getUserProfile(uid: widget.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("error loading user profile");
          }
          if (snapshot.hasData) {

            AppUserModel? profileData;
            if (snapshot.data != null) {
              profileData = AppUserModel.fromMap(snapshot.data!);
            }
            return profileData != null
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name: ${profileData.profile.name}",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Bio: ${profileData.profile.bio}",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Following: ${profileData.profile.following}",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Followers: ${profileData.profile.followers}",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () async {
                          final chatData = await ref
                              .watch(chatRepositoryProvider)
                              .getChatByParticipants([
                                FirebaseAuth.instance.currentUser!.uid,
                                profileData!.firebaseUID,
                              ], FirebaseAuth.instance.currentUser!.uid);


                          // if(chatData==null)
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatScreen(
                                  user: {
                                    "email": profileData!.email,
                                    "uid": profileData.firebaseUID,
                                  },
                                  chatData: chatData ?? {},
                                );
                              },
                            ),
                          );
                        },

                        child: Text("Message"),
                      ),
                    Expanded(child: UserPosts(userId: profileData.firebaseUID))
                    ],
                    
                  ),
                )
                : Center(child: Text("no profile data available"));
          
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
