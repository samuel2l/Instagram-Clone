import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_get/l10n.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/auth/screens/sign_up.dart';
import 'package:instagram/firebase_options.dart';
import 'package:instagram/home/screens/home.dart';
import 'package:permission_handler/permission_handler.dart';

import "package:flutter_dotenv/flutter_dotenv.dart";

String? appId = dotenv.env["AGORA_APP_ID"];
String? token = dotenv.env["AGORA_TEMP_TOKEN"];
String channel = "testtt";

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',

      locale: Locale("fr"),
      localizationsDelegates: [
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale("en"), Locale("fr")],

      // home: DraggableCaption(caption: "my drag"),
      // home: Story(),
      home: ref
          .watch(getUserProvider)
          .when(
            data: (data) {
              return data == null ? const SignUp() : Home();
            },
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
      // home: VideoCallScreen(channelId: "mych",),
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    initAgora();
    super.initState();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text("widget.title"),
      ),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child:
                    localUserJoined
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

  late RtcEngine _engine;
  int? _remoteUid;
  bool localUserJoined = false;

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    // Initialize RtcEngine and set the channel profile to communication
    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
    // Enable the video module
    await _engine.enableVideo();
    // Enable local video preview
    await _engine.startPreview();
    await _engine.joinChannel(
      // Join a channel using a temporary token and channel name
      token: token!,
      channelId: channel,
      options: const ChannelMediaOptions(
        // Automatically subscribe to all video streams
        autoSubscribeVideo: true,
        // Automatically subscribe to all audio streams
        autoSubscribeAudio: true,
        // Publish camera video
        publishCameraTrack: true,
        // Publish microphone audio
        publishMicrophoneTrack: true,
        // Set user role to clientRoleBroadcaster (broadcaster) or clientRoleAudience (audience)
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid:
          0, // When you set uid to 0, a user name is randomly generated by the engine
    );
    // Add an event handler
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        // Occurs when the local user joins the channel successfully
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            localUserJoined = true;
          });
        },
        // Occurs when a remote user join the channel
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        // Occurs when a remote user leaves the channel
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
      ),
    );
  }

  // Widget to display remote video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel(); // Leave the channel
    await _engine.release(); // Release resources
  }
}
