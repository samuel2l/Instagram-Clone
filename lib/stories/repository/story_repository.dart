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
      await userDoc.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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

  Future<Map<String, dynamic>> getValidStories() async {
    final firestore = FirebaseFirestore.instance;

    Map<String, List> allStories = {};

    try {
      // Get all users with stories
      final storiesSnapshot = await firestore.collection('stories').get();
      print("get stories???");
      print(storiesSnapshot.docs);

      for (final userDoc in storiesSnapshot.docs) {
        print("ah? $userDoc");
        // Get all userStories for this user, ordered by timestamp descending
        final userStoriesSnapshot =
            await userDoc.reference
                .collection('userStories')
                .orderBy('timestamp', descending: true)
                .get();
        print("user snapshot? $userStoriesSnapshot");

        for (final storyDoc in userStoriesSnapshot.docs) {
          if (allStories.containsKey(userDoc.id)) {
            allStories[userDoc.id]!.add({
              'storyId': storyDoc.id,
              ...storyDoc.data(),
            });
          } else {
            allStories[userDoc.id] = [
              {
                'storyId': storyDoc.id,
                ...storyDoc.data(),
              },
            ];
          }
        }
      }
      print("eiI?? $allStories");
      return allStories;
    } catch (e) {
      print('Error fetching stories: $e');
      return {};
    }
  }
}
