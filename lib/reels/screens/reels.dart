import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';

class Reels extends StatefulWidget {
  const Reels({super.key});

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  late PageController pageController;
  CachedVideoPlayerPlusController? controller;

  final List<String> reels = [
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
  ];
  
  int currentVideoIndex = 0;
  bool isHolding = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _initializeAndPlay(currentVideoIndex);
  }

  Future<void> _initializeAndPlay(int index) async {
    final newController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(reels[index]),
    );
    await newController.initialize();

    newController.addListener(() {
      if (newController.value.position >= newController.value.duration) {
        // Restart video when finished
        newController.seekTo(Duration.zero);
        newController.play();
      }
      setState(() {}); // Ensures progress bar updates in real-time
    });

    await newController.setLooping(false);
    await newController.play();

    // Dispose old controller if exists
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
      body: controller != null && controller!.value.isInitialized
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
                    itemCount: reels.length,
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
                    child: controller != null
                        ? VideoProgressIndicator(
                            controller!,
                            key: ValueKey(controller), // forces rebuild on controller change
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 5),
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