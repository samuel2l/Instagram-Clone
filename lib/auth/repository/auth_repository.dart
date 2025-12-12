// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/auth/screens/sign_up.dart';
import 'package:instagram/home/screens/home.dart';
import 'package:instagram/profile/repository/profile_repository.dart';
import 'package:instagram/utils/utils.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref: ref,
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

final getUserProvider = FutureProvider<AppUserModel?>((ref) {
  return ref.watch(authRepositoryProvider).getUser();
});

class AuthRepository {
  final Ref ref;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
    required this.ref,
  });
  Future<void> createUser(
    String email,
    String password,
    String username,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("created user? ${userCredential.user?.uid}");

      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        "username": username,

        'createdAt': FieldValue.serverTimestamp(),
      });
      await ref
          .read(profileRepositoryProvider)
          .createOrUpdateUserProfile(
            uid: FirebaseAuth.instance.currentUser!.uid,
            bio: " Hey I am a user of this app",
            name: username,
            dp:
                "https://plus.unsplash.com/premium_photo-1764435536930-c93558fa72c6?q=80&w=3023&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            context: context,
          );

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => Home()));
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

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(
          context: context,
          content: 'No user found for that email.',
        );
      } else if (e.code == 'wrong-password') {
        showSnackBar(context: context, content: 'Wrong password provided.');
      } else {
        showSnackBar(
          context: context,
          content: 'Authentication error: ${e.message}',
        );
      }
    } catch (e) {
      showSnackBar(context: context, content: 'Unexpected error: $e');
    }
  }

  // Future<void> signUp(
  //   String email,
  //   String password,
  //   BuildContext context,
  // ) async {
  //   try {
  //     final res = await auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     print("signed up a user? ");
  //     print(res.user?.uid);

  //     Navigator.of(
  //       context,
  //     ).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       showSnackBar(
  //         context: context,
  //         content: 'No user found for that email.',
  //       );
  //     } else if (e.code == 'wrong-password') {
  //       showSnackBar(context: context, content: 'Wrong password provided.');
  //     } else {
  //       showSnackBar(
  //         context: context,
  //         content: 'Authentication error: ${e.message}',
  //       );
  //     }
  //   } catch (e) {
  //     showSnackBar(context: context, content: 'Unexpected error: $e');
  //   }
  // }

  Future<AppUserModel?> getUser() async {
    final curr = auth.currentUser;
    if (curr == null) {
      return null;
    }

    var userData =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();

    print("user data?? ${userData.data()}");
    AppUserModel? user;
    if (userData.data() != null) {
      user = AppUserModel.fromMap(userData.data()!);
    }

    return user;
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      final auth = FirebaseAuth.instance;
      // print(auth.currentUser);
      await auth.signOut();
      // print("ah logout??? ${auth.currentUser}");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return SignUp();
          },
        ),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
