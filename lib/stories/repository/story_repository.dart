import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/stories/models/user_stories.dart';
import 'package:instagram/stories/screens/post_story.dart';
import 'package:instagram/utils/utils.dart';
import 'dart:convert';

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
        'watchers': <String>[],
      });
      await firestore.collection('users').doc(userId).update({
        'hasStory': true,
      });
      return true;
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      return false;
    }
  }

  dynamic normalizeFirestoreData(dynamic data) {
    if (data is Timestamp) {
      return data.toDate().toIso8601String();
    }

    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(key, normalizeFirestoreData(value)),
      );
    }

    if (data is List) {
      return data.map((e) => normalizeFirestoreData(e)).toList();
    }

    return data;
  }

  void logDeep(dynamic data) {
    final normalized = normalizeFirestoreData(data);
    const encoder = JsonEncoder.withIndent('  ');
    debugPrint(encoder.convert(normalized), wrapWidth: 2048);
  }

  Future<List<UserStories>> getValidStories(
    String? currentUserId,
  ) async {
    print("GETTING VALID STORIES IN REPO $currentUserId");
    final firestore = FirebaseFirestore.instance;

    Map<String, List<Map<String, dynamic>>> allStories = {};

    try {
      if (currentUserId == null) return [];

      final currentUserDoc =
          await firestore.collection('users').doc(currentUserId).get();

      final List<String> following = List<String>.from(
        currentUserDoc.data()?['following'] ?? [],
      );

      final storiesSnapshot = await firestore.collection('stories').get();

      for (final userDoc in storiesSnapshot.docs) {
        if (userDoc.id != currentUserId && !following.contains(userDoc.id)) {
          continue;
        }

        final userStoriesSnapshot =
            await userDoc.reference
                .collection('userStories')
                .orderBy('timestamp', descending: true)
                .get();

        final userStoryList =
            userStoriesSnapshot.docs.map((storyDoc) {
              print("story doc data? ${storyDoc.data()["watchers"]} ");
              return {'storyId': storyDoc.id, ...storyDoc.data()};
            }).toList();

        allStories[userDoc.id] = userStoryList;
      }

      // add current user is first
          final userProfileDoc =
              await firestore.collection('users').doc(currentUserId).get();
      Map<String, dynamic> orderedStories = {
        currentUserId: {"stories":allStories[currentUserId] ?? [],"userProfile":userProfileDoc.data()!},
      };
      // List<Map<String, dynamic>>

      allStories.forEach((userId, stories) async {
        if (userId != currentUserId) {
          final userProfileDoc =
              await firestore.collection('users').doc(userId).get();

          orderedStories[userId] = {
            "stories":stories, 
            "userProfile":userProfileDoc.data()!
            };
        }
      });
      print("the sotries??");
      List<UserStories> parsedStories = [];
      logDeep(orderedStories);
      orderedStories.keys.toList().map((userId) {
        final userStoriesList = orderedStories[userId] ?? [];
        print("parsing stories for user $userId with stories $userStoriesList");
        logDeep(orderedStories[userId]);

        for (int i = 0; i < userStoriesList.length; i++) {
          final userStories = UserStories.fromMap(
            orderedStories[userId],
            userId,
          );
          parsedStories.add(userStories);
        }
        // parsedStories.add(userStories);
      }).toList();
      print("the parsed stories??");
      print(parsedStories);

      // UserStories parsedStories

      return parsedStories;
    } catch (e) {
      print('Error fetching stories with user details: $e');
      return [];
    }
  }

  Future<void> addStoryViewer({
    required String ownerId,
    required String storyId,
    required String viewerId,
  }) async {
    print("ADDING VIEWER TO STORY IN REPO $ownerId $storyId $viewerId");
    final storyRef = FirebaseFirestore.instance
        .collection('stories')
        .doc(ownerId)
        .collection('userStories')
        .doc(storyId);

    await storyRef.update({
      'watchers': FieldValue.arrayUnion([viewerId]),
    });
  }

  Future<bool> hasUserWatchedAllStories({
    required String ownerId,
    required String currentUserId,
  }) async {
    try {
      final storiesSnapshot =
          await firestore
              .collection('stories')
              .doc(ownerId)
              .collection('userStories')
              .get();

      // No stories? Then nothing to watch
      if (storiesSnapshot.docs.isEmpty) {
        return true;
      }

      for (final doc in storiesSnapshot.docs) {
        final data = doc.data();
        final watchers = List<String>.from(data['watchers'] ?? []);

        // If any story does NOT include the current user
        if (!watchers.contains(currentUserId)) {
          return false;
        }
      }

      // All stories contained the user
      return true;
    } catch (e) {
      debugPrint("Error checking if all stories watched: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserStories(String userId) async {
    try {
      final userProfileDoc =
          await firestore.collection('users').doc(userId).get();

      if (!userProfileDoc.exists) return [];

      final userProfile = userProfileDoc.data();

      final userStoriesSnapshot =
          await firestore
              .collection('stories')
              .doc(userId)
              .collection('userStories')
              .orderBy('timestamp', descending: true)
              .get();

      return userStoriesSnapshot.docs.map((storyDoc) {
        return {
          'storyId': storyDoc.id,
          ...storyDoc.data(),
          'userProfile': userProfile,
        };
      }).toList();
    } catch (e) {
      print('Error getting user stories: $e');
      return [];
    }
  }
}
