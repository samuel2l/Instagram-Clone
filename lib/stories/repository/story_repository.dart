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

Future<Map<String, List<Map<String, dynamic>>>> getValidStories() async {
  final firestore = FirebaseFirestore.instance;

  Map<String, List<Map<String, dynamic>>> allStories = {};

  try {
    // Get all users with stories
    final storiesSnapshot = await firestore.collection('stories').get();

    for (final userDoc in storiesSnapshot.docs) {
      // Fetch user profile once
      final userProfileDoc = await firestore.collection('users').doc(userDoc.id).get();

      Map<String, dynamic>? userProfile = userProfileDoc.exists ? userProfileDoc.data() : null;
      print("user profile doc? $userProfile"); 

      // Get all userStories for this user, ordered by timestamp descending
      final userStoriesSnapshot = await userDoc.reference
          .collection('userStories')
          .orderBy('timestamp', descending: true)
          .get();

      for (final storyDoc in userStoriesSnapshot.docs) {
        final storyData = {
          'storyId': storyDoc.id,
          ...storyDoc.data(),
          'userProfile': userProfile, // attach user profile here
        };

        if (allStories.containsKey(userDoc.id)) {
          allStories[userDoc.id]!.add(storyData);
        } else {
          allStories[userDoc.id] = [storyData];
        }
      }
    }

    return allStories;
  } catch (e) {
    print('Error fetching stories with user details: $e');
    return {};
  }
}
}
