// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// // import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
// import 'package:record/record.dart';

// class Testingg extends StatefulWidget {
//   const Testingg({super.key});

//   @override
//   State<Testingg> createState() => _TestinggState();
// }

// class _TestinggState extends State<Testingg> {
//   final record = AudioRecorder();
//   final player = AudioPlayer();
//   bool isRecording = false;

//   String? path;
//   bool isPlaying = false;
//   void testSimpleRecording() async {
//     final record = AudioRecorder();

//     if (await record.hasPermission()) {
//       final dir = await getApplicationDocumentsDirectory();
//       final path = join(dir.path, 'test_recording.mp4');

//       // print('Recording to: $path');

//       await record.start(
//         RecordConfig(
//           encoder: AudioEncoder.aacLc,
//           sampleRate: 44100,
//           bitRate: 128000,
//         ),
//         path: path,
//       );

//       await Future.delayed(Duration(seconds: 5)); // Give it time to record

//       final result = 
//       await record.stop();
//       // print('Recording stopped. File path: $result');
//     } else {
//       // print('No mic permission');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: IconButton(
//         onPressed: () async {
//           if (isRecording) {
//             String? filePath = await record.stop();
//             if (filePath != null) {
//               isRecording = false;
//               path = filePath;
//               final file = File(path!);
//               // print("File size: ${await file.length()} bytes");

//               setState(() {});
//             }
//           } else {
//             if (await record.hasPermission()) {
//               final Directory dir = await getApplicationDocumentsDirectory();
//               // print("gotten dirr $dir");
//               final String audioPath = join(dir.path, "vn.aac");

//               // print("audio path $audioPath");

//               // await record.start(RecordConfig(), path: audioPath);
//               await record.start(
//                 RecordConfig(
//                   encoder: AudioEncoder.aacLc, // good iOS support
//                   bitRate: 128000,
//                   // samplingRate: 44100,
//                   sampleRate: 44100,
//                 ),
//                 path: audioPath,
//               );
//               isRecording = true;
//               path = null;
//               setState(() {});
//             }
//           }
//           // testSimpleRecording();
//         },
//         icon: isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
//       ),
//       body: Center(
//         child: TextButton(
//           // height: 200,
//           onPressed: () async {
//             // print("plkayinf this file: $path");
//             if (player.playing) {
//               await player.pause();
//             } else {
//               await player.setFilePath(path!);
//               await player.play();
//             }
//             isPlaying = !isPlaying;
//             setState(() {});
//           },
//           child:
//               path != null
//                   ? Text(isPlaying ? "STOP" : "Play recorded audio")
//                   : Text("No audio to play"),
//         ),
//       ),
//     );
//   }
// }
