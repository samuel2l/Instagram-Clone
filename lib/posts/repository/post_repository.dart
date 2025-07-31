import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/utils/utils.dart';

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class PostRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  PostRepository({required this.auth, required this.firestore});

  Future<void> createPost({
    required String caption,
    required List<String> imageUrls,
    required BuildContext context,
    String postType = "post",
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      final postRef = firestore.collection('posts').doc();

      await postRef.set({
        'postId': postRef.id,
        'uid': uid,
        'caption': caption,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
        "postType": postType,
      });
      showSnackBar(context: context, content: "posted successfully");
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  Future<List> getReels() async {
    try {
      final querySnapshot =
          await firestore
              .collection('posts')
              .where('postType', isEqualTo: 'reel')
              // .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => doc.data()["imageUrls"]??[]).toList();
    } catch (e) {
      throw Exception('Error fetching reels: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }

  Stream<int> getLikesCount(String postId) {
    DocumentReference postRef = firestore.collection('posts').doc(postId);
    return postRef.snapshots().map((doc) {
      List likes = doc['likes'] ?? [];
      return likes.length;
    });
  }

  Future<void> toggleLikePost(String postId) async {
    String uid = auth.currentUser!.uid;
    DocumentReference postRef = firestore.collection('posts').doc(postId);

    try {
      DocumentSnapshot snapshot = await postRef.get();

      List likes = snapshot['likes'] ?? [];

      if (likes.contains(uid)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      throw Exception('Error toggling like: $e');
    }
  }

  Future<bool> hasLikedPost(String postId) async {
    try {
      String uid = auth.currentUser!.uid;
      DocumentSnapshot snapshot =
          await firestore.collection('posts').doc(postId).get();
      List likes = snapshot['likes'] ?? [];

      return likes.contains(uid);
    } catch (e) {
      throw Exception('Error checking if user liked post: $e');
    }
  }

  Future<void> addCommentToPost({
    required String postId,
    required String email,
    required String dp,
    required String commentText,
  }) async {
    final commentData = {
      'text': commentText,
      'email': email,
      'dp': dp,
      'createdAt': FieldValue.serverTimestamp(),
      'uid': auth.currentUser!.uid,
    };

    await firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(commentData);
  }

  Stream<List<Map<String, dynamic>>> getPostComments(String postId) {
    return firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Stream<List<Map<String, dynamic>>> getUserPosts(String userId) {
  //   return firestore
  //       .collection('posts')
  //       .where('uid', isEqualTo: userId)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  // }

  Stream<List<Map<String, dynamic>>> getUserPosts(String userId) {
    return firestore
        .collection('posts')
        .where('uid', isEqualTo: userId)
        .where('postType', isEqualTo: 'post')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
