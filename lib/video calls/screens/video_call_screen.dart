import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/utils/utils.dart';
import 'package:instagram/video%20calls/repository/video_call_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({
    super.key,
    required this.channelId,
    required this.calleeId,
    required this.receiverDp,
    required this.receiverName,
  });
  final String channelId;
  final String calleeId;
  final String receiverDp;
  final String receiverName;
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
    final userId = ref.read(userProvider).value!.firebaseUID;
    final res = await http.get(
      Uri.parse(
        "$baseUrl/rtc/${widget.channelId}/publisher/userAccount/$userId/",
      ),
    );
    print("Response status: ${res.statusCode} ${res.body}");
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (mounted) {
        setState(() {
          token = data["rtcToken"];
        });
      }
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
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          // debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          // debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          // debugPrint("remote user $remoteUid left channel");
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

  bool isMuted = false;
  bool isVideoOff = false;
  bool isCameraFront = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
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
            //user has picked so put caller view in top right
            if (_remoteUid != null && _localUserJoined) {
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
                  videoCallManipulationIconsWidget(),
                ],
              );
            } else {
              //user has not yet picked so show your preview at center
              return Stack(
                children: [
                  Center(
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
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: CachedNetworkImageProvider(
                            widget.receiverDp,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.receiverName,
                          style: TextStyle(fontSize: 25),
                        ),
                        // SizedBox(height: 10),
                        Text("Calling..."),
                      ],
                    ),
                  ),
                  videoCallManipulationIconsWidget(),
                ],
              );
            }
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

  Widget videoCallManipulationIconsWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(200, 7, 7, 7),

          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                isVideoOff = !isVideoOff;
                _engine.muteLocalVideoStream(isVideoOff);
                setState(() {});
              },
              icon: Icon(
                isVideoOff
                    ? Icons.videocam_off_outlined
                    : Icons.videocam_outlined,
                color: Colors.white,
                size: 33,
              ),
            ),

            IconButton(
              onPressed: () {
                isMuted = !isMuted;
                _engine.muteLocalAudioStream(isMuted);
                setState(() {});
              },
              icon: Icon(
                isMuted ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 33,
              ),
            ),
            IconButton(
              onPressed: () {
                isCameraFront = !isCameraFront;
                _engine.switchCamera();
                setState(() {});
              },
              icon: Icon(
                isCameraFront ? Icons.camera_front : Icons.camera_rear,
                color: Colors.white,
                size: 33,
              ),
            ),

            GestureDetector(
              onTap: () {
                ref
                    .read(videoCallRepositoryProvider)
                    .endCall(
                      calleeId: widget.calleeId,
                      channelId: widget.channelId,
                    );
                Navigator.of(context).pop("call ended");
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 246, 20, 4),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.call_end, color: Colors.white, size: 33),
              ),
            ),
          ],
        ),
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
