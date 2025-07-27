import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostVideo extends ConsumerStatefulWidget {
  const PostVideo({super.key, required this.url});
  final String url;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostVideoState();
}

class _PostVideoState extends ConsumerState<PostVideo> {
  late CachedVideoPlayerPlusController controller;
  bool isMuted = false;

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      controller.setVolume(isMuted ? 0.0 : 1.0);
    });
  }

  bool isPlay = false;
  @override
  void initState() {
    super.initState();
    controller = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(widget.url),
        httpHeaders: {'Connection': 'keep-alive'},
        invalidateCacheIfOlderThan: const Duration(days: 10),
      )
      ..initialize().then((value) async {
        await controller.setLooping(true);
        controller.play();

        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? GestureDetector(
          onTap: () {
            toggleMute();
          },
          child: CachedVideoPlayerPlus(controller),
        )
        : const CircularProgressIndicator.adaptive();
  }
}
