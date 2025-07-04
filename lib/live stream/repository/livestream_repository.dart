import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/models/livestream.dart';
import 'package:instagram/utils/utils.dart';
import 'package:uuid/uuid.dart';

final isLiveProvider = StreamProvider<bool>((ref) {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userDocStream =
      FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

  return userDocStream.map((snapshot) {
    final data = snapshot.data();
    if (data == null || data['isLive'] == null) {
      return false;
    }
    return data['isLive'] as bool;
  });
});

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
          .collection("livestreams")
          .doc(channelId)
          .set(livestream.toMap());
      await firestore.collection('users').doc(uid).update({'isLive': true});
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

  Future<void> deleteLivestreamComments(String channelId) async {
    try {
      final commentsCollection = firestore
          .collection('livestreams')
          .doc(channelId)
          .collection('comments');

      final snapshot = await commentsCollection.get();

      final batch = firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print(e);
    }
  }

  endLiveStream(String uid, String channelId, BuildContext context) async {
    await deleteLivestreamComments(channelId);
    await firestore.collection("livestreams").doc(channelId).delete();
    await firestore.collection('users').doc(uid).update({'isLive': false});
    showSnackBar(context: context, content: "Live Stream ended");
  }

  increaseViewerCount(String channelId) async {
    try {
      await firestore.collection("livestreams").doc(channelId).update({
        "viewerCount": FieldValue.increment(1),
      });
    } catch (e) {
      print(e);
    }
  }

  decreaseViewerCount(String channelId) async {
    try {
      await firestore.collection("livestreams").doc(channelId).update({
        "viewerCount": FieldValue.increment(-1),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> addLivestreamComment({
    required String channelId,
    required String email,
    required String commentText,
  }) async {
    final commentData = {
      'text': commentText,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('livestreams')
        .doc(channelId)
        .collection('comments')
        .add(commentData);
  }

  Stream<List<Map<String, dynamic>>> getLivestreamComments(String channelId) {
    return firestore
        .collection('livestreams')
        .doc(channelId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          // Print each comment for debugging
          for (var doc in snapshot.docs) {
            print('Comment: ${doc.data()}');
          }

          // Return as a list of maps
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }
}
