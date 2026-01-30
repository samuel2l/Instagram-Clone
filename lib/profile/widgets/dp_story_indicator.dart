import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/live%20stream/screens/livestream_screen.dart';
import 'package:instagram/stories/repository/story_repository.dart';
import 'package:instagram/stories/screens/user_stories.dart';

class DpStoryIndicator extends ConsumerStatefulWidget {
  const DpStoryIndicator({super.key, required this.user});
  final AppUserModel user;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DpStoryIndicatorState();
}

class _DpStoryIndicatorState extends ConsumerState<DpStoryIndicator> {
  @override
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () async {
                  if (!widget.user.profile.isLive) {
                    final userStories = await ref
                        .read(storyRepositoryProvider)
                        .getUserStories(widget.user.firebaseUID);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => UserStories(userStories: userStories),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return LivestreamScreen(
                            role: ClientRoleType.clientRoleAudience,
                            channelId:
                                "${widget.user.firebaseUID} ${widget.user.email}",
                          );
                        },
                      ),
                    );
                  }
                },

                child:
                   
                            !widget.user.profile.hasStory &&
                            !widget.user.profile.isLive
                        ? Container(
                          width: 80, // 2 * radius + border
                          height: 80,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: CachedNetworkImageProvider(
                              widget.user.profile.dp,
                            ),
                          ),
                        )
                        :
                        //trick to create the gradient border around the avatar
                        //use 2 containers, the outer one with gradient and inner one with circle avatar
                        //use first containers padding to create the border thickness effect
                        //essentially it is a rounded container with color of thhe gradient given but we put an element in it(the child container) with a padding which gives us the desired effect
                        widget.user.profile.hasStory
                        ? StreamBuilder(
                          stream: ref
                              .watch(storyRepositoryProvider)
                              .hasUserWatchedAllStories(
                                ownerId: widget.user.firebaseUID,
                                currentUserId:
                                    ref
                                        .watch(userProvider)
                                        .value
                                        ?.firebaseUID ??
                                    "",
                              ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Text("error");
                            }
                            final hasWatchedAllStories = snapshot.data ?? false;

                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color:
                                    hasWatchedAllStories
                                        ? const Color.fromARGB(
                                          255,
                                          200,
                                          199,
                                          199,
                                        )
                                        : null,
                                gradient:
                                    !hasWatchedAllStories
                                        ? LinearGradient(
                                          colors: [
                                            const Color.fromARGB(
                                              255,
                                              103,
                                              1,
                                              121,
                                            ),
                                            const Color.fromARGB(
                                              255,
                                              255,
                                              64,
                                              50,
                                            ),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                        : null,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  5,
                                ), // border thickness

                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(
                                    5,
                                  ), // border thickness trick again
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundImage: CachedNetworkImageProvider(
                                      widget.user.firebaseUID ==
                                              ref
                                                  .read(userProvider)
                                                  .value
                                                  ?.firebaseUID
                                          ? widget.user.profile.dp
                                          : widget.user.profile.dp,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                        : StreamBuilder(
                          stream: ref
                              .read(storyRepositoryProvider)
                              .hasUserWatchedAllStories(
                                ownerId: widget.user.firebaseUID,
                                currentUserId:
                                    ref
                                        .watch(userProvider)
                                        .value
                                        ?.firebaseUID ??
                                    "",
                              ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Text("error");
                            }
                            final hasWatchedAllStories = snapshot.data ?? false;

                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color:
                                        hasWatchedAllStories
                                            ? const Color.fromARGB(
                                              255,
                                              200,
                                              199,
                                              199,
                                            )
                                            : null,
                                    gradient:
                                        !hasWatchedAllStories
                                            ? LinearGradient(
                                              colors: [
                                                const Color.fromARGB(
                                                  255,
                                                  103,
                                                  1,
                                                  121,
                                                ),
                                                const Color.fromARGB(
                                                  255,
                                                  255,
                                                  64,
                                                  50,
                                                ),
                                              ],

                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                            : null,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      5,
                                    ), // border thickness

                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(
                                        5,
                                      ), // border thickness trick again
                                      child: CircleAvatar(
                                        radius: 32,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                              widget.user.firebaseUID ==
                                                      ref
                                                          .read(userProvider)
                                                          .value
                                                          ?.firebaseUID
                                                  ? widget.user.profile.dp
                                                  : widget.user.profile.dp,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
              ),
              widget.user.profile.isLive ? Text("LIVE!") : SizedBox.shrink(),

            ],
          ),
        ],
      );
  }
}
