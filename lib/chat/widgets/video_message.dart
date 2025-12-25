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

        if (widget.playOnInit == true) {
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 7),
      margin: EdgeInsets.only(
        right: widget.isSender ? 3 : 0,
        bottom: 2,
        left: !widget.isSender ? 3 : 0,
      ),
      

      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.76,
      ),
      decoration: BoxDecoration(
        color:
            widget.isSender
                ? Colors.deepPurpleAccent
                : const Color.fromARGB(255, 59, 59, 59),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),

      child:
          controller.value.isInitialized
              ? Stack(
                children: [
                  SizedBox(
                    height: 250,
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
