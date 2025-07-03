import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/live%20stream/repository/livestream_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class LivestreamScreen extends ConsumerStatefulWidget {
  final ClientRoleType role;

  const LivestreamScreen({super.key, required this.role});

  @override
  ConsumerState<LivestreamScreen> createState() => _LivestreamScreenState();
}

class _LivestreamScreenState extends ConsumerState<LivestreamScreen> {
  String? appId = dotenv.env["AGORA_APP_ID"];
  String? token = dotenv.env["AGORA_TEMP_TOKEN"];
  String channel = "testt";
  List<int> watchers = [];
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _isEngineReady = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    print("Initializing Agora...");
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    print("Engine created.");

    await _engine.initialize(
      RtcEngineContext(
        appId: appId!,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    print("Engine initialized.");

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user ${connection.localUid} joined");
          if (mounted) {
            setState(() {
              _localUserJoined = true;
            });
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user $remoteUid joined");
          if (mounted) {
            setState(() {
              watchers.add(remoteUid);
              _remoteUid = remoteUid;
            });
          }
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          print("Remote user $remoteUid left channel");
          if (mounted) {
            setState(() {
              watchers.remove(remoteUid);
              if (_remoteUid == remoteUid) _remoteUid = null;
            });
          }
        },
        onLeaveChannel: (connection, stats) {
          print("Left channel: $stats");
          if (mounted) {
            setState(() {
              watchers.clear();
              _remoteUid = null;
            });
          }
        },
      ),
    );

    await _engine.setClientRole(role: widget.role);
    await _engine.enableVideo();

    if (widget.role == ClientRoleType.clientRoleBroadcaster) {
      if (mounted) await _engine.startPreview();
    }

    await _engine.joinChannelWithUserAccount(
      token: token!,
      channelId: channel,
      userAccount: FirebaseAuth.instance.currentUser!.uid,
    );

    if (mounted) {
      setState(() {
        _isEngineReady = true;
      });
    }
  }

  @override
  void dispose() {
    endStream();
    super.dispose();
  }

  Future<void> endStream() async {
    if (_isEngineReady) {
      await _engine.leaveChannel();
      await _engine.release();
      if (widget.role == ClientRoleType.clientRoleBroadcaster) {
        await ref.read(liveStreamRepositoryProvider).endLiveStream();
      }
    }
  }

  Widget _buildVideoView() {
    if (!_isEngineReady) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.role == ClientRoleType.clientRoleBroadcaster) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      if (_remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: channel),
          ),
        );
      } else {
        return const Center(child: Text("Waiting for the stream to start..."));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            print("Ending live stream");
            await endStream();
            if (mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          widget.role == ClientRoleType.clientRoleBroadcaster
              ? "You are Live"
              : "Live Stream",
        ),
        actions: [
          if (widget.role == ClientRoleType.clientRoleBroadcaster)
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: () {
                if (_isEngineReady) _engine.switchCamera();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildVideoView(),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Watchers: ${watchers.length}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: "Write a comment..."),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}