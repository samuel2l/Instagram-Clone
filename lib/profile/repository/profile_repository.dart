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
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {};

      if (name != null) dataToUpdate['name'] = name;
      if (bio != null) dataToUpdate['bio'] = bio;

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
        showSnackBar(context: context, content: 'Error updating profile: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> getUserProfile({
    required String uid,
    BuildContext? context,
  }) async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        if (context != null) {
          showSnackBar(context: context, content: 'User profile not found.');
        }
        return null;
      }
    } catch (e) {
      if (context != null) {
        showSnackBar(context: context, content: 'Error fetching profile: $e');
      }
      return null;
    }
  }
}
