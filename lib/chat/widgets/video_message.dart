import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoMessage extends ConsumerStatefulWidget {
  const VideoMessage({
    super.key,
    required this.url,
    required this.isSender,
    this.playOnInit = false,
  });
  final String url;
  final bool isSender;
  final bool playOnInit;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoMessageState();
}

class _VideoMessageState extends ConsumerState<VideoMessage> {
  late CachedVideoPlayerPlusController controller;
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
        await controller.setLooping(false);
        
        if (widget.playOnInit==true){
controller.play();
        }
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
    return Center(
      child:
          controller.value.isInitialized
              ? Stack(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 17, vertical: 7),
                    height: 250,
                    width: double.infinity,
                    color:
                        widget.isSender
                            ? const Color.fromARGB(255, 143, 207, 145)
                            : Colors.white,

                    child: CachedVideoPlayerPlus(controller),
                  ),
                  GestureDetector(
                    onTap: () {
                      isPlay = !isPlay;
                      isPlay ? controller.play() : controller.pause();
                      setState(() {});
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 120),
                      alignment: Alignment.bottomCenter,
                      child: Icon(
                        isPlay ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
              : const CircularProgressIndicator.adaptive(),
    );
  }
}
