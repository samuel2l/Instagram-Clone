import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/voice_calls/repository/voice_call_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceCallScreen extends ConsumerStatefulWidget {
  const VoiceCallScreen({
    super.key,
    required this.channelId,
    required this.calleeId,
    required this.receiverDp,
    required this.receiverName,
    this.isGroup = false,
  });

  final String channelId;
  final String calleeId;
  final String receiverDp;
  final String receiverName;
  final bool isGroup;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen> {
  bool _localUserJoined = false;
  final List<int> _remoteUids = [];
  RtcEngine? _engine;
  String? appId = dotenv.env["AGORA_APP_ID"];
  String baseUrl = "https://agora-token-generator-mtk5.onrender.com";
  String? token;

  bool isMuted = false;

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
    await [Permission.microphone].request();
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
          setState(() {
            _remoteUids.add(remoteUid);
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUids.remove(remoteUid);
          });
        },
        onTokenPrivilegeWillExpire: (connection, token) async {
          await getToken();
          await _engine?.renewToken(token);
        },
      ),
    );

    await _engine?.enableAudio();
    await _engine?.joinChannelWithUserAccount(
      token: token ?? "",
      channelId: widget.channelId,
      userAccount: FirebaseAuth.instance.currentUser!.uid,
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    if (_engine != null) {
      await _engine?.leaveChannel();
      await _engine?.release();
    }
  }

  Widget _remoteUserList() {
    if (_remoteUids.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: CachedNetworkImageProvider(widget.receiverDp),
          ),
          const SizedBox(height: 10),
          Text(
            widget.receiverName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text("Calling...", style: TextStyle(fontSize: 18)),
        ],
      );
    }
    return ListView.builder(
      itemCount: _remoteUids.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text("User ID: ${_remoteUids[index]}"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: StreamBuilder(
        stream: ref
            .watch(voiceCallRepositoryProvider)
            .checkCallEnded(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          if (data.isEmpty) {
            return Stack(
              children: [
                Center(child: _remoteUserList()),
                _voiceCallControls(),
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

  Widget _voiceCallControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                isMuted = !isMuted;
                _engine?.muteLocalAudioStream(isMuted);
                setState(() {});
              },
              icon: Icon(
                isMuted ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
            GestureDetector(
              onTap: () async {
                print("about to end call??? ");
                await ref
                    .read(voiceCallRepositoryProvider)
                    .endCall(
                      calleeId: widget.calleeId,
                      channelId: widget.channelId,
                      isGroup: widget.isGroup,
                    );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
