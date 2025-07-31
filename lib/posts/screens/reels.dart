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
    List reelData = await ref.read(postRepositoryProvider).getReels();
    reels = reelData.expand((innerList) => innerList).toList();

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
                            ? CachedVideoPlayerPlus(controller!)
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
                      
                  ],
                ),
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
