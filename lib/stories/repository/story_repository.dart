import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository(firestore: FirebaseFirestore.instance);
});

class StoryRepository {
  final FirebaseFirestore firestore;

  StoryRepository({required this.firestore});
  Future<void> uploadStory(
    String userId, {
    required String mediaUrl,
    required String mediaType,
    String caption = "",
  }) async {
    final userDoc = firestore.collection('stories').doc(userId);


    await userDoc.set({
      'lastUpdated': FieldValue.serverTimestamp(),
      
    }, SetOptions(merge: true));

    await userDoc.collection('userStories').add({
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'timestamp': FieldValue.serverTimestamp(),
    });
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
        activeStories.add({
          'userId': userId,
          // Include username/profile info if stored at root level
          'storyList': validStories,
        });
      }
    }

    return activeStories;
  }
}
