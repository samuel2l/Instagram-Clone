// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import "package:flutter_gen/gen_l10n/app_localizations.dart";
// import "package:flutter_localizations/flutter_localizations.dart";
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:instagram/auth/repository/auth_repository.dart';
// import 'package:instagram/auth/screens/sign_up.dart';
// import 'package:instagram/firebase_options.dart';
// import 'package:instagram/home/screens/home.dart';

// // import 'package:agora_rtc_engine/rtc_engine.dart';
// // import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// // import "package:agora_rtc_engine/agora_rtc_engine.dart";

// // import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

// // import 'package:permission_handler/permission_handler.dart';
// //channel name was testt
// void main() async {
//   await dotenv.load();
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(ProviderScope(child: const MyApp()));
// }

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return MaterialApp(
//       title: 'Flutter Demo',

//       locale: Locale("fr"),
//       localizationsDelegates: [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: [Locale("en"), Locale("fr")],

//       // home: DraggableCaption(caption: "my drag"),
//       // home: Story(),
//       home: ref
//           .watch(getUserProvider)
//           .when(
//             data: (data) {
//               return data == null ? const SignUp() : Home();
//             },
//             error: (error, stackTrace) => Center(child: Text(error.toString())),
//             loading: () => Center(child: CircularProgressIndicator()),
//           ),
//     );
//   }
// }

// class Story extends StatefulWidget {
//   const Story({super.key});

//   @override
//   State<Story> createState() => _StoryState();
// }

// class _StoryState extends State<Story> {
//   TextEditingController captionController = TextEditingController();
//   List<String> captions = [];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("draggable story template")),
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           SizedBox(
//             height: double.infinity,
//             width: double.infinity,
//             child: Image.asset("assets/images/IMG_3846.JPG", fit: BoxFit.cover),
//           ),
//           // Icon(Icons.headphones, color: Colors.red),
//           for (var caption in captions)
//             Text(caption, style: TextStyle(fontSize: 20, color: Colors.white)),

//           Form(
//             child: TextFormField(
//               controller: captionController,
//               onFieldSubmitted: (value) {
//                 captions.add(value);
//                 captionController.text = "";
//                 setState(() {});
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DraggableCaption extends StatefulWidget {
//   final String caption;
//   // final Function(Offset) onPositionChanged;

//   const DraggableCaption({
//     super.key,
//     required this.caption,
//     // required this.onPositionChanged,
//   });

//   @override
//   _DraggableCaptionState createState() => _DraggableCaptionState();
// }

// class _DraggableCaptionState extends State<DraggableCaption> {
//   Offset position = Offset(100, 100); // default starting point
//   void updatePosition(Offset newPosition) {
//     position = newPosition;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: position.dx,
//       top: position.dy,
//       child: GestureDetector(
//         onPanUpdate: (details) {
//           setState(() {
//             position += details.delta;
//             updatePosition(position);
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           color: Colors.black54,
//           child: Text(
//             widget.caption,
//             style: TextStyle(color: Colors.white, fontSize: 16),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_get/l10n.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/auth/screens/sign_up.dart';
import 'package:instagram/firebase_options.dart';
import 'package:instagram/home/screens/home.dart';
import 'package:instagram/live%20stream/screens/start_livestream.dart';
import 'package:permission_handler/permission_handler.dart';

import "package:flutter_dotenv/flutter_dotenv.dart";

String? appId = dotenv.env["AGORA_APP_ID"];
String? token = dotenv.env["AGORA_TEMP_TOKEN"];
String channel = "testt";

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',

      locale: Locale("fr"),
      localizationsDelegates: [
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale("en"), Locale("fr")],

      // home: DraggableCaption(caption: "my drag"),
      // home: Story(),
      home: ref
          .watch(getUserProvider)
          .when(
            data: (data) {
              return data == null ? const SignUp() : Home();
            },
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => Center(child: CircularProgressIndicator()),
          ),

    );
  }
}

class ChooseVideoCallScreen extends StatelessWidget {
  const ChooseVideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return MyApp();
              },
            ),
          );
        },
        child: Center(child: Text("go to video call")),
      ),
    );
  }
}

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token!,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agora Video Call')),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child:
                    _localUserJoined
                        ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                        : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
