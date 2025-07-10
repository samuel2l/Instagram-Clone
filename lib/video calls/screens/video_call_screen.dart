import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/utils/utils.dart';
import 'package:instagram/video%20calls/repository/video_call_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({
    super.key,
    required this.channelId,
    required this.calleeId,
  });
  final String channelId;
  final String calleeId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
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
        channelProfile:
            ChannelProfileType.channelProfileCommunication, // ✅ changed
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
      body: StreamBuilder(
        stream: ref
            .watch(videoCallRepositoryProvider)
            .checkCallEnded(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            showSnackBar(
              context: context,
              content: "An unexpected error occured",
            );
          }
          final data = snapshot.data ?? {};
          if (data.isEmpty) {
            return Stack(
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
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child: IconButton(
                      onPressed: () {
                        ref
                            .read(videoCallRepositoryProvider)
                            .endCall(
                              calleeId: widget.calleeId,
                              channelId: widget.channelId,
                            );
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.call),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // showSnackBar(context: context, content: "Call ended");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
            return const Center(child: Text("Call ended"));
          }
        },
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
