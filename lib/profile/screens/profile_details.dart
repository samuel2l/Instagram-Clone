import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/chat/repository/chat_repository.dart';
import 'package:instagram/chat/screens/chat_screen.dart';
import 'package:instagram/posts/repository/post_repository.dart';
import 'package:instagram/posts/screens/user_posts.dart';
import 'package:instagram/profile/repository/profile_repository.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DpStoryIndicator(user: widget.user),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.profile.name,
                      style: TextStyle(fontSize: 21),
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                              future: ref
                                  .read(postRepositoryProvider)
                                  .getPostCount(widget.user.firebaseUID),
                              builder: (context, asyncSnapshot) {
                                if (asyncSnapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Text(
                                    asyncSnapshot.data.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                return Text(
                                  "0",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            Text("Posts"),
                          ],
                        ),
                        SizedBox(width: 15),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.profile.followers.length.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Followers"),
                          ],
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.profile.following.length.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Following"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(widget.user.profile.bio, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 1, 86, 242),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      final chatData = await ref
                          .watch(chatRepositoryProvider)
                          .getChatByParticipants([
                            ref.read(userProvider).value!.firebaseUID,
                            widget.user.firebaseUID,
                          ], ref.read(userProvider).value!.firebaseUID);

                      // if(chatData==null)
                      ref.read(messageRecipientProvider.notifier).state =
                          widget.user;
                      ref.read(chatDataProvider.notifier).state = chatData;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ChatScreen();
                          },
                        ),
                      );
                    },

                    child: Text(
                      "Message",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: StreamBuilder(
                    stream: ref
                        .watch(profileRepositoryProvider)
                        .isFollowing(targetUid: widget.user.firebaseUID),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              1,
                              86,
                              242,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {},
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      bool? isFollowing = snapshot.data;
                      if (isFollowing != null) {
                        return TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              1,
                              86,
                              242,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            if (!isFollowing) {
                              ref
                                  .watch(profileRepositoryProvider)
                                  .followUser(
                                    targetUserId: widget.user.firebaseUID,
                                  );
                            } else {
                              ref
                                  .watch(profileRepositoryProvider)
                                  .unfollowUser(
                                    targetUserId: widget.user.firebaseUID,
                                  );
                            }
                          },
                          child: Text(
                            isFollowing ? "Following" : "Follow",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        );
                      } else {
                        return TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {},
                          child: Text(
                            "Follow",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            Expanded(child: UserPosts(userId: widget.user.firebaseUID)),
          ],
        ),
      ),
    );
  }
}
