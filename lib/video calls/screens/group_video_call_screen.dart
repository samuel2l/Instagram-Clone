import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/video%20calls/repository/video_call_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupVideoCallScreen extends ConsumerStatefulWidget {
  const GroupVideoCallScreen({
    super.key,
    required this.channelId,
    required this.calleeId,
    required this.receiverName,
    required this.receiverDp,
  });

  final String channelId;
  final String calleeId;
  final String receiverName;
  final String receiverDp;

  @override
  ConsumerState<GroupVideoCallScreen> createState() =>
      _GroupVideoCallScreenState();
}

class _GroupVideoCallScreenState extends ConsumerState<GroupVideoCallScreen> {
  RtcEngine? _engine;

  final List<int> _remoteUids = [];
  bool _localUserJoined = false;

  String? appId = dotenv.env["AGORA_APP_ID"];
  String baseUrl = "https://agora-token-generator-mtk5.onrender.com";
  String? token;

  bool isMuted = false;
  bool isVideoOff = false;
  bool isCameraFront = true;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> getToken() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final res = await http.get(
      Uri.parse(
        "$baseUrl/rtc/${widget.channelId}/publisher/userAccount/$userId/",
      ),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (!mounted) return;
      setState(() {
        token = data["rtcToken"];
      });
    } else {
      throw Exception("Unable to get token");
    }
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    await getToken();

    _engine = createAgoraRtcEngine();

    await _engine?.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          if (!_remoteUids.contains(remoteUid)) {
            setState(() {
              _remoteUids.add(remoteUid);
            });
          }
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUids.remove(remoteUid);
          });
        },
        onTokenPrivilegeWillExpire: (connection, _) async {
          await getToken();
          await _engine?.renewToken(token!);
        },
      ),
    );

    await _engine?.enableVideo();
    await _engine?.startPreview();

    final userId = FirebaseAuth.instance.currentUser!.uid;

    await _engine?.joinChannelWithUserAccount(
      token: token!,
      channelId: widget.channelId,
      userAccount: userId,
    );
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  Widget _buildLocalVideo() {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      ),
    );
  }

  Widget _buildRemoteVideo(int uid) {
    return Container(
              decoration: BoxDecoration(
          border: BoxBorder.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(10),
        ),

      child: AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: uid),
          connection: RtcConnection(channelId: widget.channelId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final views = <Widget>[
      if (_localUserJoined) _buildLocalVideo(),
      ..._remoteUids.map(_buildRemoteVideo),
    ];

    int crossAxisCount = views.length <= 2 ? 1 : 2;

    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: ref
            .watch(videoCallRepositoryProvider)
            .checkCallEnded(widget.channelId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};

          if (data.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
            return const Center(child: Text("Call ended"));
          }

          return Stack(
            children: [
              GridView.builder(
                itemCount: views.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: views[index],
                  );
                },
              ),
              videoCallManipulationIconsWidget(),
            ],
          );
        },
      ),
    );
  }

  Widget videoCallManipulationIconsWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(20),
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
                _engine?.enableLocalVideo(!isVideoOff);
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
                _engine?.muteLocalAudioStream(isMuted);
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
                _engine?.switchCamera();
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
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 246, 20, 4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
