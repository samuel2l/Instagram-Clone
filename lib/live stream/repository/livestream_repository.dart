import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/models/livestream.dart';
import 'package:instagram/utils/utils.dart';

final liveStreamRepositoryProvider = Provider((ref) {
  return LivestreamRepository(firestore: FirebaseFirestore.instance);
});

final hasStartedLivestreamProvider = StateProvider<bool>((ref) => false);

class LivestreamRepository {
  final FirebaseFirestore firestore;

  LivestreamRepository({required this.firestore});
  startLiveStream(
    String email,
    String uid,
    int viewerCount,

    BuildContext context,
  ) async {
    String channelId = "";
    try {
      channelId = "$uid $email";

      final livestream = Livestream(
        email: email,
        uid: uid,
        startedAt: DateTime.now(),
        viewerCount: viewerCount,
        channelId: channelId,
      );

      await firestore
          .collection("liveStreams")
          .doc(channelId)
          .set(livestream.toMap());
    } on FirebaseException {
      showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        content: "Unexpected error. Please try again later",
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
    return channelId;
  }

  endLiveStream(){
    
  }
}
