// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/utils/utils.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
   ));

class AuthRepository {
  Future<void> createUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      showSnackBar(
        context: context,
        content: "User created: ${userCredential.user?.uid}",
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(
          context: context,
          content: 'The password provided is too weak.',
        );
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(
          context: context,
          content: 'The account already exists for that email.',
        );
      } else {
        showSnackBar(context: context, content: 'Error: ${e.message}');
      }
    } catch (e) {
      showSnackBar(context: context, content: 'Unexpected error: $e');
    }
  }
}
