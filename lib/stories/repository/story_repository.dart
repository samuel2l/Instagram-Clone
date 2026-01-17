import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/profile/models/profile.dart';
import 'package:instagram/stories/models/story.dart';
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

  Future<List<AppUserModel>> getUsersWithStories(String? currentUserId) async {
    if (currentUserId == null) return [];

    try {
      final firestore = FirebaseFirestore.instance;
      final List<AppUserModel> result = [];

      final currentUserDoc =
          await firestore.collection('users').doc(currentUserId).get();
      if (!currentUserDoc.exists) return [];

      final currentUserData = currentUserDoc.data()!;
      result.add(AppUserModel.fromMap(currentUserData));

      final List<String> following = List<String>.from(
        currentUserData['following'] ?? [],
      );

      if (following.isEmpty) return result;

      following.remove(currentUserId);
      // fetch followed users in chunks of 10 as firestore may throw error if query has contents of length>10
      for (var i = 0; i < following.length; i += 10) {
        final chunk = following.sublist(
          i,
          i + 10 > following.length ? following.length : i + 10,
        );

        final snapshot =
            await firestore
                .collection('users')
                .where('hasStory', isEqualTo: true)
                .where('uid', whereIn: chunk)
                .get();

        for (final doc in snapshot.docs) {
          result.add(AppUserModel.fromMap(doc.data()));
        }
      }

      return result;
    } catch (e) {
      print('Error fetching users with stories: $e');
      return [];
    }
  }

  Future<void> addStoryViewer({
    required String ownerId,
    required String storyId,
    required String viewerId,
  }) async {
    final storyRef = FirebaseFirestore.instance
        .collection('stories')
        .doc(ownerId)
        .collection('userStories')
        .doc(storyId);

    await storyRef.update({
      'watchers': FieldValue.arrayUnion([viewerId]),
    });
  }

Stream<bool> hasUserWatchedAllStories({
  required String ownerId,
  required String currentUserId,
}) {
  return firestore
      .collection('stories')
      .doc(ownerId)
      .collection('userStories')
      .snapshots()
      .map((storiesSnapshot) {
        // No stories → treated as all watched
        if (storiesSnapshot.docs.isEmpty) {
          return true;
        }

        for (final doc in storiesSnapshot.docs) {
          final data = doc.data();
          final watchers = List<String>.from(data['watchers'] ?? []);

          // If any story does NOT include the user
          if (!watchers.contains(currentUserId)) {
            return false;
          }
        }

        return true;
      })
      .handleError((e) {
        debugPrint("Error checking if all stories watched: $e");
        return false;
      });
}

  Future<UserStories> getUserStories(String userId) async {
    try {
      final userProfileDoc =
          await firestore.collection('users').doc(userId).get();

      if (!userProfileDoc.exists) {
        return UserStories(
          userId: userId,
          stories: [],
          profile: Profile(
            following: [],
            followers: [],
            name: "",
            bio: "",
            dp: "",
            username: "",
            hasStory: false,
            isLive: false
          ),
        );
      }

      final userProfile = userProfileDoc.data();

      final userStoriesSnapshot =
          await firestore
              .collection('stories')
              .doc(userId)
              .collection('userStories')
              .orderBy('timestamp', descending: true)
              .get();

      final List<Story> stories =
          userStoriesSnapshot.docs.map((storyDoc) {
            final story = {
              'storyId': storyDoc.id,
              ...storyDoc.data(),
              'userProfile': userProfile,
            };
            return Story.fromMap(story);
          }).toList();
      return UserStories(
        userId: userId,
        stories: stories,
        profile: Profile.fromMap(userProfile!),
      );
    } catch (e) {
      print('Error getting user stories: $e');
      return UserStories(
        userId: userId,
        stories: [],
        profile: Profile(
          following: [],
          followers: [],
          name: "",
          bio: "",
          dp: "",
          username: "",
          hasStory: false,
          isLive: false
        ),
      );
    }
  }Future<void> deleteExpiredStories() async {
  final cutoff = Timestamp.fromDate(
    DateTime.now().subtract(const Duration(hours: 24)),
  );

  final storiesUsersSnapshot =
      await firestore.collection('stories').get();

  for (final userDoc in storiesUsersSnapshot.docs) {
    final userId = userDoc.id;

    final expiredStoriesSnapshot = await firestore
        .collection('stories')
        .doc(userId)
        .collection('userStories')
        .where('timestamp', isLessThanOrEqualTo: cutoff)
        .get();

    if (expiredStoriesSnapshot.docs.isEmpty) continue;

    final batch = firestore.batch();

    for (final storyDoc in expiredStoriesSnapshot.docs) {
      batch.delete(storyDoc.reference);
    }

    await batch.commit();

    // 🔥 Check if user still has stories
    final remainingStories = await firestore
        .collection('stories')
        .doc(userId)
        .collection('userStories')
        .limit(1)
        .get();

    if (remainingStories.docs.isEmpty) {
      await firestore.collection('users').doc(userId).update({
        'hasStory': false,
      });
    }
  }
}
}
