import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/live%20stream/repository/livestream_repository.dart';
import 'livestream_screen.dart';

class StartLivestreamScreen extends ConsumerWidget {
  const StartLivestreamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start Livestream")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            TextButton.icon(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fixedSize: Size(MediaQuery.sizeOf(context).width, 60),

                backgroundColor: const Color.fromARGB(255, 1, 86, 242),
                foregroundColor: Colors.white,
              ),

              icon: const Icon(Icons.videocam),
              label: const Text("Start Live", style: TextStyle(fontSize: 20)),
              onPressed: () async {
                String channelId = await ref
                    .read(liveStreamRepositoryProvider)
                    .startLiveStream(
                      FirebaseAuth.instance.currentUser?.email ?? "",
                      FirebaseAuth.instance.currentUser?.uid ?? "",
                      0,
                      context,
                    );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (ctx) => LivestreamScreen(
                          role: ClientRoleType.clientRoleBroadcaster,
                          channelId: channelId,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
