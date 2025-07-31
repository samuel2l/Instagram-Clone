import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/posts/repository/post_repository.dart';

class Reels extends ConsumerStatefulWidget {
  const Reels({super.key});

  @override
  ConsumerState<Reels> createState() => _ConsumerReelsState();
}

class _ConsumerReelsState extends ConsumerState<Reels> {
  late PageController pageController;
  CachedVideoPlayerPlusController? controller;
  List<dynamic>? reelData;

  List<dynamic>? reels;

  int currentVideoIndex = 0;
  bool isHolding = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _initializeAndPlay(currentVideoIndex);
  }

  Future<void> _initializeAndPlay(int index) async {
    reelData = await ref.read(postRepositoryProvider).getReels();
    if (reelData != null) {
      for (int i = 0; i < reelData!.length; i++) {
        if (reels == null) {
          reels = [reelData![i]["imageUrls"][0]];
        } else {
          reels!.add(reelData![i]["imageUrls"][0]);
        }
      }
    }

    setState(() {});
    final newController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(reels![index]),
    );
    await newController.initialize();

    newController.addListener(() {
      if (newController.value.position >= newController.value.duration) {
        newController.seekTo(Duration.zero);
        newController.play();
      }
      setState(() {});
    });

    await newController.setLooping(false);
    await newController.play();

    controller?.dispose();

    setState(() {
      controller = newController;
      currentVideoIndex = index;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
          controller != null && controller!.value.isInitialized && reels != null
              ? GestureDetector(
                onLongPress: () {
                  controller?.pause();
                  setState(() {
                    isHolding = true;
                  });
                },
                onLongPressUp: () {
                  controller?.play();
                  setState(() {
                    isHolding = false;
                  });
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: pageController,
                      onPageChanged: (index) {
                        _initializeAndPlay(index);
                      },
                      itemCount: reels!.length,
                      itemBuilder: (context, index) {
                        return controller != null &&
                                controller!.value.isInitialized
                            ? Stack(
                              children: [
                                CachedVideoPlayerPlus(controller!),
                                Positioned(
                                  right: 0,
                                  bottom: 200,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          ref
                                              .read(postRepositoryProvider)
                                              .toggleLikePost(
                                                reelData![index]["postId"],
                                              );
                                          setState(() {});
                                        },
                                        icon: FutureBuilder<bool>(
                                          future: ref
                                              .watch(postRepositoryProvider)
                                              .hasLikedPost(
                                                "${reelData![index]["postId"]}",
                                              ),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return snapshot.data == true
                                                  ? Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  )
                                                  : Icon(
                                                    Icons.favorite_outline,
                                                    color: Colors.white,
                                                  );
                                            }
                                            return Icon(
                                              Icons.favorite_outline,
                                              color: Colors.black,
                                            );
                                          },
                                        ),
                                      ),

                                      StreamBuilder(
                                        stream: ref
                                            .watch(postRepositoryProvider)
                                            .getLikesCount(
                                              reelData![index]["postId"],
                                            ),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Text("${snapshot.data}",style: TextStyle(color: Colors.white),);
                                          }

                                          return Text(" ");
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            : const Center(child: CircularProgressIndicator());
                      },
                    ),

                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child:
                          controller != null
                              ? VideoProgressIndicator(
                                controller!,
                                key: ValueKey(controller),
                                allowScrubbing: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                colors: const VideoProgressColors(
                                  playedColor: Colors.red,
                                  bufferedColor: Colors.grey,
                                  backgroundColor: Colors.black26,
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    if (isHolding)
                      const Center(
                        child: Icon(
                          Icons.pause_circle_filled,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),

                    Positioned(
                      right: 0,
                      bottom: 150,
                      child: Icon(Icons.message, color: Colors.white),
                    ),
                  ],
                ),
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
