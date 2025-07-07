// import 'dart:convert';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:instagram/utils/utils.dart';
// import 'package:permission_handler/permission_handler.dart';

// class VideoCallScreen extends StatefulWidget {
//   const VideoCallScreen({super.key, required this.channelId});
//   final String channelId;

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   late RtcEngine _engine;
//   String? appId = dotenv.env["AGORA_APP_ID"];

//   String baseUrl = "https://agora-token-generator-mtk5.onrender.com";
//   String? token;

//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//   }
//     getToken() async {
//     final res = await http.get(
//       Uri.parse(
//         "$baseUrl/rtc/${widget.channelId}/publisher/userAccount/${FirebaseAuth.instance.currentUser?.uid}/",
//       ),
//     );
//     if (res.statusCode == 200) {
//       setState(() {
//         token = res.body;
//         token = jsonDecode(token!)["rtcToken"];
//       });
//     } else {
//       token = "undefined";
//       showSnackBar(context: context, content: "Unable to join live");
//     }
//   }


//   Future<void> initAgora() async {
//     // retrieve permissions

//     await [Permission.microphone, Permission.camera].request();

//     //create the engine
//     _engine = createAgoraRtcEngine();
//         await getToken();

//     await _engine.initialize(
//       RtcEngineContext(
//         appId: appId,
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//       ),
//     );
//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint("local user ${connection.localUid} joined");
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint("remote user $remoteUid joined");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (
//           RtcConnection connection,
//           int remoteUid,
//           UserOfflineReasonType reason,
//         ) {
//           debugPrint("remote user $remoteUid left channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//         onTokenPrivilegeWillExpire: (connection, token) async {
//           await getToken();
//           await _engine.renewToken(token);
//         },
//       ),
//     );

//     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     await _engine.enableVideo();
//     await _engine.startPreview();

//     await _engine.joinChannelWithUserAccount(
//       token: token!,
//       channelId: widget.channelId,
//       userAccount: FirebaseAuth.instance.currentUser!.uid,
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();

//     _dispose();
//   }

//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.release();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Agora Video Call')),
//       body: Stack(
//         children: [
//           Center(child: _remoteVideo()),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SizedBox(
//               width: 100,
//               height: 150,
//               child: Center(
//                 child:
//                     _localUserJoined
//                         ? AgoraVideoView(
//                           controller: VideoViewController(
//                             rtcEngine: _engine,
//                             canvas: const VideoCanvas(uid: 0),
//                           ),
//                         )
//                         : const CircularProgressIndicator(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Display remote user's video
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: RtcConnection(channelId: widget.channelId),
//         ),
//       );
//     } else {
//       return const Text(
//         'Please wait for remote user to join',
//         textAlign: TextAlign.center,
//       );
//     }
//   }
// }

import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key, required this.channelId});
  final String channelId;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  String? appId = dotenv.env["AGORA_APP_ID"];

  String baseUrl = "https://agora-token-generator-mtk5.onrender.com";
  String? token;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> getToken() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final res = await http.get(
      Uri.parse(
        "$baseUrl/rtc/${widget.channelId}/publisher/userAccount/$userId/",
      ),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        token = data["rtcToken"];
      });
    } else {
      throw Exception("Unable to get token");
    }
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await getToken();

    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication, // ✅ changed
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
        onTokenPrivilegeWillExpire: (connection, token) async {
          await getToken();
          await _engine.renewToken(token);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    final userId = FirebaseAuth.instance.currentUser!.uid;

    await _engine.joinChannelWithUserAccount(
      token: token!,
      channelId: widget.channelId,
      userAccount: userId,
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
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
                child: _localUserJoined
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

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelId),
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