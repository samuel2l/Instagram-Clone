import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/stories/screens/post_story.dart';
import 'package:instagram/utils/utils.dart';

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository(firestore: FirebaseFirestore.instance);
});

class StoryRepository {
  final FirebaseFirestore firestore;

  StoryRepository({required this.firestore});
  Future<bool> uploadStory(
    String userId, {
    required String mediaUrl,
    required List<EditableItem> storyData,
    required BuildContext context,
  }) async {
    try {
      final userDoc = firestore.collection('stories').doc(userId);

      final storyDataMap = storyData.map((item) => item.toMap()).toList();

      await userDoc.collection('userStories').add({
        'mediaUrl': mediaUrl,
        "storyData": storyDataMap,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getActiveStories() async {
    final snapshot = await firestore.collection('stories').get();
    final now = DateTime.now();
    final List<Map<String, dynamic>> activeStories = [];

    for (var userDoc in snapshot.docs) {
      final userId = userDoc.id;
      final storiesSnapshot =
          await userDoc.reference
              .collection('userStories')
              // .orderBy('timestamp', descending: true)
              .get();

      final validStories =
          storiesSnapshot.docs
              .where((storyDoc) {
                final timestamp = (storyDoc['timestamp'] as Timestamp).toDate();
                return now.difference(timestamp).inHours < 24;
              })
              .map((doc) {
                return doc.data();
              })
              .toList();

      if (validStories.isNotEmpty) {
        activeStories.add({'userId': userId, 'storyList': validStories});
      }
    }
    return activeStories;
  }
}
