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

class GroupVideoCallScreen extends ConsumerStatefulWidget {
  const GroupVideoCallScreen({
    super.key,
    required this.channelId,
    required this.calleeId,

  });
  final String channelId;
  final String calleeId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupVideoCallScreenState();
}

class _GroupVideoCallScreenState extends ConsumerState<GroupVideoCallScreen> {
  final List<int> _remoteUids = [];
  bool _localUserJoined = false;
  RtcEngine? _engine; 
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

    await getToken(); 

    _engine = createAgoraRtcEngine(); 

    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine!.registerEventHandler(
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
            _remoteUids.add(remoteUid);
          });
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          // debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUids.remove(remoteUid);
          });
        },
        onTokenPrivilegeWillExpire: (connection, token) async {
          await getToken();
          await _engine!.renewToken(token);
        },
      ),
    );

    await _engine!.enableVideo();
    await _engine!.startPreview();

    final userId = FirebaseAuth.instance.currentUser!.uid;

    await _engine!.joinChannelWithUserAccount(
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
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
    }
  }

  Widget _buildVideoView(int uid) {
    if (_engine == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: uid),
        connection: RtcConnection(channelId: widget.channelId),
      ),
    );
  }

  Widget _buildLocalVideo() {
    if (_engine == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_engine == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final views = <Widget>[
      _buildLocalVideo(),
      ..._remoteUids.map(_buildVideoView),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Agora Group Video Call')),
      body: StreamBuilder(
        stream: ref
            .watch(videoCallRepositoryProvider)
            .checkCallEnded(widget.calleeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            showSnackBar(
              context: context,
              content: "An unexpected error occurred",
            );
          }
          final data = snapshot.data ?? {};

          if (data.isEmpty) {
            return Stack(
              children: [
                GridView.builder(
                  itemCount: views.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // adjust based on your layout design
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      child: views[index],
                    );
                  },
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
                        Navigator.of(context).pop("call ended");
                      },
                      icon: const Icon(Icons.call),
                    ),
                  ),
                ),
              ],
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
            return const Center(child: Text("Call ended"));
          }
        },
      ),
    );
  }
}
