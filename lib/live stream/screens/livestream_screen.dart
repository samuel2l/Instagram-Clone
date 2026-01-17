import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/live%20stream/repository/livestream_repository.dart';
import 'package:instagram/live%20stream/widgets/comments_list.dart';
import 'package:instagram/utils/utils.dart';
import 'package:instagram/widgets/unified_text_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

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

  String baseUrl = "https://agora-token-generator-mtk5.onrender.com";
  String? token;
  List<int> watchers = [];
  int? _remoteUid;
  // ignore: unused_field
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

  getToken() async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/rtc/${widget.channelId}/publisher/userAccount/${FirebaseAuth.instance.currentUser?.uid}/",
      ),
    );
    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)["rtcToken"];
      });
    } else {
      token = "undefined";
      showSnackBar(context: context, content: "Unable to join live");
    }
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await getToken();

    await _engine.initialize(
      RtcEngineContext(
        appId: appId!,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          // print("Local user ${connection.localUid} joined");
          // if (mounted) {
          setState(() {
            _localUserJoined = true;
          });
          // }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          // print("Remote user $remoteUid joined");
          // if (mounted) {
          setState(() {
            watchers.add(remoteUid);
            _remoteUid = remoteUid;
            ref
                .read(liveStreamRepositoryProvider)
                .increaseViewerCount(widget.channelId);
          });
          // }
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          // print("Remote user $remoteUid left channel");
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
        onLeaveChannel: (connection, stats) async {
          // print("Left channel: $stats");
          if (mounted) {
            setState(() {
              watchers.clear();
              _remoteUid = null;
            });

            await endStream();
          }
        },
        onTokenPrivilegeWillExpire: (connection, token) async {
          await getToken();
          await _engine.renewToken(token);
        },
      ),
    );

    await _engine.setClientRole(role: widget.role);
    await _engine.enableVideo();

    if (widget.role == ClientRoleType.clientRoleBroadcaster) {
      if (mounted) {
        await _engine.startPreview();
      }
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
    // endStream();
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
      return Container(
        decoration: BoxDecoration(
          border: BoxBorder.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(10),
        ),

        child: AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _engine,
            canvas: const VideoCanvas(uid: 0),
          ),
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
                    child: StreamBuilder<int>(
                      stream: ref
                          .read(liveStreamRepositoryProvider)
                          .getViewerCount(widget.channelId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            "Watchers: ...",
                            style: TextStyle(color: Colors.white),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Text(
                            "Watchers: 0",
                            style: TextStyle(color: Colors.white),
                          );
                        }
                        return Text(
                          "Watchers: ${snapshot.data}",
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),

                // Replace the Positioned widget for comments (around line 220) with this:
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: const BoxDecoration(
                      // gradient: LinearGradient(
                      //   begin: Alignment.bottomCenter,
                      //   end: Alignment.topCenter,
                      //   colors: [
                      //     Colors.black54,
                      //     Colors.transparent,
                      //   ],
                      // ),
                    ),
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: ref
                          .read(liveStreamRepositoryProvider)
                          .getLivestreamComments(widget.channelId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return AnimatedCommentsList(comments: snapshot.data!);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   color: Colors.transparent,
          //   padding: const EdgeInsets.all(8),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: TextField(
          //           controller: commentController,
          //           decoration: InputDecoration(hintText: "Write a comment..."),
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: () {
          //           ref
          //               .read(liveStreamRepositoryProvider)
          //               .addLivestreamComment(
          //                 channelId: widget.channelId,
          //                 email: FirebaseAuth.instance.currentUser?.email ?? "",
          //                 commentText: commentController.text.trim(),
          //               );
          //           commentController.clear();
          //         },
          //         icon: const Icon(Icons.send),
          //       ),
          //     ],
          //   ),
          // ),
          UnifiedTextField(
            user: ref.read(userProvider).value,
            hintText: "Add a comment..",
            onSendMessage: (String gifUrl)async {
                  // await ref
                  //     .read(liveStreamRepositoryProvider)
                  //     .sendStickerOrGif(
                  //       channelId: widget.channelId!,
                  //       email: FirebaseAuth.instance.currentUser?.email ?? "",
                  //       commentText: gifUrl,
                  //     );

            },
            onSendGifOrSticker: ()async{
                  //     await ref
                  // .read(liveStreamRepositoryProvider)
                  // .sendStickerOrGif(
                  //   channelId: widget.channelId,
                  //   email: FirebaseAuth.instance.currentUser?.email ?? "",
                  //   commentText: ,
                  // );
            },
            channelId:widget.channelId
          ),
        ],
      ),
    );
  }
}
