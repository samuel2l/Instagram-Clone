// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/utils/utils.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class ProfileRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  ProfileRepository({required this.auth, required this.firestore});
  Future<void> createOrUpdateUserProfile({
    required String uid,
    String? name,
    String? bio,
    BuildContext? context,
    bool isNew = true,
    String? dp,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {};

      if (name != null) dataToUpdate['name'] = name;
      if (bio != null) dataToUpdate['bio'] = bio;
      if (dp != null) dataToUpdate['dp'] = dp;

      if (isNew) {
        dataToUpdate["followers"] = [];
        dataToUpdate["following"] = [];
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(dataToUpdate, SetOptions(merge: true));

      if (context != null) {
        showSnackBar(
          context: context,
          content: 'Profile updated successfully.',
        );
      }
    } catch (e) {
      if (context != null) {
        print("profile update error: $e");  
        showSnackBar(context: context, content: 'Error updating profile: $e');
      }
    }
  }

  Stream<Map<String, dynamic>?> getUserProfile({
    required String uid,
    BuildContext? context,
  }) {
    final firestore = FirebaseFirestore.instance;
    print("Fetching profile for UID: $uid");

    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((docSnapshot) {
          if (docSnapshot.exists) {
            return docSnapshot.data();
          } else {
            if (context != null) {
              showSnackBar(
                context: context,
                content: 'User profile not found.',
              );
            }
            return null;
          }
        })
        .handleError((e) {
          if (context != null) {
            print("profile error: $e");
            print(e);
            showSnackBar(
              context: context,
              content: 'Error fetching profile: $e',
            );
          }
        });
  }

  Future<void> followUser({
    required String targetUserId,
    BuildContext? context,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final currentUserRef = firestore
          .collection('users')
          .doc(auth.currentUser!.uid);
      final targetUserRef = firestore.collection('users').doc(targetUserId);

      final batch = firestore.batch();

      batch.update(currentUserRef, {
        'following': FieldValue.arrayUnion([targetUserId]),
      });

      batch.update(targetUserRef, {
        'followers': FieldValue.arrayUnion([auth.currentUser!.uid]),
      });

      await batch.commit();

      if (context != null) {
        showSnackBar(
          context: context,
          content: "You are now following this user",
        );
      }
    } catch (e) {
      if (context != null) {
        showSnackBar(context: context, content: 'Error following user: $e');
      }
    }
  }

  Stream<bool> isFollowing({required String targetUid}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return false;

          final data = doc.data() as Map<String, dynamic>;
          final followers = List<String>.from(data['followers'] ?? []);
          return followers.contains(auth.currentUser!.uid);
        });
  }

  Future<void> unfollowUser({
    required String targetUserId,
    BuildContext? context,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final currentUserRef = firestore
          .collection('users')
          .doc(auth.currentUser!.uid);
      final targetUserRef = firestore.collection('users').doc(targetUserId);

      final batch = firestore.batch();

      batch.update(currentUserRef, {
        'following': FieldValue.arrayRemove([targetUserId]),
      });

      batch.update(targetUserRef, {
        'followers': FieldValue.arrayRemove([auth.currentUser!.uid]),
      });

      await batch.commit();

      if (context != null) {
        showSnackBar(
          context: context,
          content: "You have unfollowed this user",
        );
      }
    } catch (e) {
      if (context != null) {
        showSnackBar(context: context, content: 'Error unfollowing user: $e');
      }
    }
  }
}
