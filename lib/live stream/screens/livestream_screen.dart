import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/live%20stream/repository/livestream_repository.dart';
import 'package:instagram/utils/utils.dart';
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

  late RtcEngine _engine;
  bool _isEngineReady = false;
  bool _localUserJoined = false;

  int? _remoteUid;
  List<int> watchers = [];

  bool _isMuted = false;
  bool _isVideoMuted = false;

  TextEditingController commentController = TextEditingController();

  /// 🔥 COMMENT STATE
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/rtc/${widget.channelId}/publisher/userAccount/${FirebaseAuth.instance.currentUser?.uid}/",
      ),
    );

    if (res.statusCode == 200) {
      token = jsonDecode(res.body)["rtcToken"];
    } else {
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
        onJoinChannelSuccess: (_, __) {
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (_, uid, __) {
          setState(() {
            watchers.add(uid);
            _remoteUid = uid;
            ref
                .read(liveStreamRepositoryProvider)
                .increaseViewerCount(widget.channelId);
          });
        },
        onUserOffline: (_, uid, __) {
          setState(() {
            watchers.remove(uid);
            if (_remoteUid == uid) _remoteUid = null;
            ref
                .read(liveStreamRepositoryProvider)
                .decreaseViewerCount(widget.channelId);
          });
        },
        onTokenPrivilegeWillExpire: (_, __) async {
          await getToken();
          await _engine.renewToken(token!);
        },
      ),
    );

    await _engine.setClientRole(role: widget.role);
    await _engine.enableVideo();

    if (widget.role == ClientRoleType.clientRoleBroadcaster) {
      await _engine.startPreview();
    }

    await _engine.joinChannelWithUserAccount(
      token: token!,
      channelId: widget.channelId,
      userAccount: FirebaseAuth.instance.currentUser!.uid,
    );

    setState(() => _isEngineReady = true);
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    commentController.dispose();
    super.dispose();
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
        return const Center(child: Text("Waiting for live..."));
      }
    }
  }

  /// 🔥 Animated comments list
  Widget _buildAnimatedComments() {
    return AnimatedList(
      key: _listKey,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      initialItemCount: _comments.length,
      itemBuilder: (context, index, animation) {
        final comment = _comments[index];
        return _animatedCommentItem(comment, animation);
      },
    );
  }

  Widget _animatedCommentItem(
    Map<String, dynamic> comment,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.4),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${comment['email'] ?? 'User'}: ",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: comment['text'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.role == ClientRoleType.clientRoleBroadcaster
              ? "You are Live"
              : "Live Stream",
        ),
      ),
      body: Stack(
        children: [
          _buildVideoView(),

          Positioned(
            top: 16,
            right: 16,
            child: StreamBuilder<int>(
              stream: ref
                  .read(liveStreamRepositoryProvider)
                  .getViewerCount(widget.channelId),
              builder: (_, snapshot) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "👀 ${snapshot.data ?? 0}",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: ref
                    .read(liveStreamRepositoryProvider)
                    .getLivestreamComments(widget.channelId),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final incoming = snapshot.data!;
                  if (incoming.length > _comments.length) {
                    final diff = incoming.length - _comments.length;
                    for (int i = 0; i < diff; i++) {
                      _comments.insert(0, incoming[i]);
                      _listKey.currentState?.insertItem(0);
                    }
                  }

                  return _buildAnimatedComments();
                },
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: "Write a comment...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (commentController.text.trim().isEmpty) return;
                      ref
                          .read(liveStreamRepositoryProvider)
                          .addLivestreamComment(
                            channelId: widget.channelId,
                            email: FirebaseAuth
                                    .instance.currentUser?.email ??
                                "User",
                            commentText:
                                commentController.text.trim(),
                          );
                      commentController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}