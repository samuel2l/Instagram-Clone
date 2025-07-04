import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/live%20stream/repository/livestream_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class LivestreamScreen extends ConsumerStatefulWidget {
  final ClientRoleType role;
  final String channelId;

  const LivestreamScreen({
    super.key,
    required this.role,
    required this.channelId,
  });

  @override
  ConsumerState<LivestreamScreen> createState() => _LivestreamScreenState();
}

class _LivestreamScreenState extends ConsumerState<LivestreamScreen> {
  String? appId = dotenv.env["AGORA_APP_ID"];
  String? token = dotenv.env["AGORA_TEMP_TOKEN"];
  List<int> watchers = [];
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _isEngineReady = false;
  TextEditingController commentController = TextEditingController();
  // Added for mute/unmute
  bool _isMuted = false;
  bool _isVideoMuted = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      RtcEngineContext(
        appId: appId!,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

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
              ref
                  .read(liveStreamRepositoryProvider)
                  .increaseViewerCount(widget.channelId);
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
              ref
                  .read(liveStreamRepositoryProvider)
                  .decreaseViewerCount(widget.channelId);
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
      channelId: widget.channelId,
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
        await ref
            .read(liveStreamRepositoryProvider)
            .endLiveStream(
              FirebaseAuth.instance.currentUser?.uid ?? "",
              widget.channelId,
              context,
            );
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
            connection: RtcConnection(channelId: widget.channelId),
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
          if (widget.role == ClientRoleType.clientRoleBroadcaster) ...[
            IconButton(
              icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
              onPressed: () {
                if (_isEngineReady) {
                  _engine.muteLocalAudioStream(!_isMuted);
                  setState(() {
                    _isMuted = !_isMuted;
                  });
                }
              },
            ),
            IconButton(
              icon: Icon(_isVideoMuted ? Icons.videocam_off : Icons.videocam),
              onPressed: () {
                if (_isEngineReady) {
                  _engine.muteLocalVideoStream(!_isVideoMuted);
                  setState(() {
                    _isVideoMuted = !_isVideoMuted;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: () {
                if (_isEngineReady) _engine.switchCamera();
              },
            ),
          ],
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

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: ref
                          .read(liveStreamRepositoryProvider)
                          .getLivestreamComments(widget.channelId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "No comments yet",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        final comments = snapshot.data!;
                        return ListView.builder(
                          reverse: true, // newer comments at bottom
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return ListTile(
                              title: Text(
                                comment['email'] ?? 'Unknown',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                comment['text'] ?? '',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            );
                          },
                        );
                      },
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
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(hintText: "Write a comment..."),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(liveStreamRepositoryProvider)
                        .addLivestreamComment(
                          channelId: widget.channelId,
                          email: FirebaseAuth.instance.currentUser?.email??"",
                          commentText: commentController.text.trim(),
                        );
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
