import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voiceCallRepositoryProvider = Provider((ref) {
  return VoiceCallRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class VoiceCallRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  VoiceCallRepository({required this.auth, required this.firestore});

  Future<void> sendCallData({
    required String calleeId,
    required String channelId,
    bool isGroup = false,
  }) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception("No authenticated user found.");
    }

    final callData = {
      'channelId': channelId,
      'callerId': currentUser.uid,
      'calleeId': calleeId,
      'callType': 'voice',
      'timestamp': FieldValue.serverTimestamp(),
      'hasDialled': true,
    };

    if (!isGroup) {
      await firestore.collection('calls').doc(calleeId).set(callData);
      await firestore.collection('calls').doc(currentUser.uid).set(callData);
    } else {
      await firestore.collection('calls').doc(calleeId).set(callData);
    }

    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('call_logs')
        .add({
          'channelId': channelId,
          'callType': 'voice',
          'calleeId': calleeId,
          'timestamp': FieldValue.serverTimestamp(),
          'direction': 'outgoing',
        });

    await firestore
        .collection('users')
        .doc(calleeId)
        .collection('call_logs')
        .add({
          'channelId': channelId,
          'callType': 'voice',
          'callerId': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'direction': 'incoming',
        });
  }

  Future<void> endCall({
    required String calleeId,
    required String channelId,
    bool isGroup = false,
  }) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception("No authenticated user found.");
    }
    print("ENDING THE CALL?");
    print(calleeId);
    print(channelId);
    print(isGroup);


      await firestore.collection('calls').doc(calleeId).update({
        "hasDialled": false,
      });
      await firestore.collection('calls').doc(currentUser.uid).update({
        "hasDialled": false,
      });
  }

  Stream<Map<String, dynamic>?> checkIncomingCalls(String uid) {
    return firestore.collection('calls').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['hasDialled'] && data['callType'] == 'voice') {
          return {
            'callerId': data['callerId'],
            'channelId': data['channelId'],
            'timestamp': data['timestamp'],
          };
        }
      }
      return null;
    });
  }

  Stream<Map<String, dynamic>?> checkCallEnded(String uid) {
    return firestore.collection('calls').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null &&
            !data['hasDialled'] &&
            data['callType'] == 'voice') {
          return {
            'callerId': data['callerId'],
            'channelId': data['channelId'],
            'timestamp': data['timestamp'],
          };
        }
      }
      return null;
    });
  }
}
