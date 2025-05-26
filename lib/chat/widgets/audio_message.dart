
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';

class AudioMessage extends ConsumerStatefulWidget {
  const AudioMessage({super.key, required this.url, required this.isSender});
  final String url;
  final bool isSender;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AudioMessageState();
}

class _AudioMessageState extends ConsumerState<AudioMessage> {
  bool isPlay = false;
  // FlutterSoundPlayer recorder = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();
    // recorder.openPlayer();
  }

  @override
  void dispose() {
    // recorder.closePlayer();
    super.dispose();
  }

  Future<void> playAudio(String url) async {
    // var status = await Permission.microphone.request();
    // if (status != PermissionStatus.granted) {
    //   throw RecordingPermissionException("Microphone permission not granted");
    // }

    // await recorder.startPlayer(
    //   fromURI: url,
    //   // codec: Codec,
    //   whenFinished: () {
    //     setState(() {
    //       isPlay = false;
    //     });
    //   },
    // );

    // setState(() {
    //   isPlay = true;
    // });
  }

  Future<void> pauseAudio() async {
    // await recorder.pausePlayer();
    // setState(() {
    //   isPlay = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    print("url given");
    print(widget.url);
    return Padding(
      padding: EdgeInsets.all(9),
      child: Container(
        width: 50,
        height: 50,
        color:
            widget.isSender
                ? const Color.fromARGB(255, 143, 207, 145)
                : Colors.white,
        child: GestureDetector(
          onTap: () async {
            if (isPlay) {
              await pauseAudio();
            } else {
              await playAudio(widget.url);
            }


            // isPlay = !isPlay;
            // setState(() {});
          },
          child: Center(
            child: isPlay ? Icon(Icons.pause) : Icon(Icons.play_arrow),
          ),
        ),
      ),
    );
  }
}
