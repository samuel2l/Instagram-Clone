import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';

class Reels extends StatefulWidget {
  const Reels({super.key});

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  late PageController pageController;

  final List<String> reels = [
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
    "https://res.cloudinary.com/dvsd4zjxfyg87t78/video/upload/v1748286053/sama29571%40gmail.com/ayxcimjxxtwdwhemc0pb.mov",
  ];

  List<CachedVideoPlayerPlusController> controllers = [];

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    // Initialize controllers for all reels
    for (var url in reels) {
      final controller = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(url),
        httpHeaders: {'Connection': 'keep-alive'},
        invalidateCacheIfOlderThan: const Duration(days: 10),
      );
      controller.initialize().then((_) {
        controller.setLooping(true);
        setState(() {}); // Refresh UI after initialization
      });
      controllers.add(controller);
    }

    // Start playing the first video
    controllers[0].play();
  }

  @override
  void dispose() {
    pageController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: pageController,
        onPageChanged: (index) {
          for (int i = 0; i < controllers.length; i++) {
            if (i == index) {
              controllers[i].play();
            } else {
              controllers[i].pause();
            }
          }
        },
        itemCount: reels.length,
        itemBuilder: (context, index) {
          final controller = controllers[index];

          return controller.value.isInitialized
              ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedVideoPlayerPlus(controller),
                  Positioned(
                    bottom: 50,
                    left: 20,
                    child: Text(
                      'Reel ${index + 1}',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
