// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/utils/constants.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(firestore: FirebaseFirestore.instance);
});

class ChatRepository {
  FirebaseFirestore firestore;
  ChatRepository({required this.firestore});
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final enrichedChats = await Future.wait(
            snapshot.docs.map((doc) async {
              final chatData = doc.data();

              chatData['chatId'] = doc.id;

              if (chatData["isGroup"]) {
                return chatData;
              } else {
                List participants = chatData['participants'];
                String otherUserId = participants.firstWhere(
                  (id) => id != userId,
                );
                final userSnap =
                    await firestore
                        .collection('users')
                        .where('uid', isEqualTo: otherUserId)
                        .limit(1)
                        .get();

                if (userSnap.docs.isNotEmpty) {
                  final userData = userSnap.docs.first.data();
                  chatData['email'] = userData['email'];
                  chatData['name'] = userData['name'];
                  chatData['profilePic'] = userData['profilePic'];
                }
              }
              return chatData;
            }).toList(),
          );

          return enrichedChats;
        });
  }

  Stream<List<Map<String, dynamic>>> getUsers() {
    var users = firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    return users;
  }

  Future<Map<String, dynamic>> getUserById(String uid) async {
    final snapshot =
        await firestore
            .collection('users')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();

    return snapshot.docs.first.data();
  }
  Future<String> getOrCreateChatId(
    List<String> userIds, {
    bool isGroup = false,
  }) async {
    userIds.sort();
    final chatQuery =
        await firestore
            .collection('chats')
            .where('participants', isEqualTo: userIds)
            .limit(1)
            .get();

    if (chatQuery.docs.isNotEmpty) {
      return chatQuery.docs.first.id;
    }

    final newChatDoc = firestore.collection('chats').doc();
    await newChatDoc.set({
      'participants': userIds,
      'isGroup': isGroup,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return newChatDoc.id;
  }

  Future<Map<String, dynamic>> createGroupChat({
    required List<String> userIds,
    required String groupName,
  }) async {
    final newChatDoc = firestore.collection('chats').doc();

    final data = {
      'participants': userIds,
      'isGroup': true,
      'groupName': groupName,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    };

    await newChatDoc.set(data);

    final snapshot = await newChatDoc.get();
    final docData = snapshot.data() ?? {};

    return {'chatId': newChatDoc.id, ...docData};
  }

  Future<List<String>> getGroupMembers({required String chatId}) async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('participants')) {
        List<dynamic> participants = data['participants'];
        return participants.cast<String>();
      }
    }

    return [];
  }

  Future<void> addMemberToGroup({
    required String userId,
    required String chatId,
  }) async {
    final doc = await firestore.collection('chats').doc(chatId).get();

    if (doc.exists) {
      final data = doc.data();
      final List<dynamic> participants = data?['participants'] ?? [];

      if (!participants.contains(userId)) {
        await firestore.collection('chats').doc(chatId).update({
          'participants': FieldValue.arrayUnion([userId]),
        });
      }
    }
  }

  Future<void> removeMemberFromGroup({
    required String userId,
    required String chatId,
  }) async {
    final doc = await firestore.collection('chats').doc(chatId).get();

    if (doc.exists) {
      final data = doc.data();
      final List<dynamic> participants = data?['participants'] ?? [];

      if (participants.contains(userId)) {
        await firestore.collection('chats').doc(chatId).update({
          'participants': FieldValue.arrayRemove([userId]),
        });
      }
    }
  }

  Future<void> sendMessage({
    required String receiverId,
    required String senderId,
    required String messageText,
    required String chatId,
    String repliedTo = "",
    String reply = "",
    String replyType = "",

    bool isGroup = false,
    List<String> participants = const [],
    String groupName = "",
  }) async {
    if (chatId.isEmpty) {
      chatId = await getOrCreateChatId([senderId, receiverId]);
    }
    final messageDoc =
        firestore.collection('chats').doc(chatId).collection('messages').doc();

    final messageData = {
      'senderId': senderId,
      'text': messageText,
      "type": text,
      "repliedTo": repliedTo,
      "reply": reply,
      "replyType": replyType,
      "isSeen": false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await messageDoc.set(messageData);

    await firestore.collection('chats').doc(chatId).update({
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    if (chatId.isEmpty) {
      return firestore
          .collection('chats')
          .doc("123")
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    }
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id; // add the document ID into the map
                return data;
              }).toList(),
        );
  }

  Future<void> updateSeen(String chatId, String messageId) async {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({"isSeen": true});
  }

  Future<void> sendFile({
    //generic function to send audio,images,gifs,files etc
    required String receiverId,
    required String senderId,
    required String chatId,
    required String messageType,
    required String imageUrl,
    String repliedTo = "",
    String reply = "",
    String replyType = "",
  }) async {
    if (chatId.isEmpty) {
      chatId = await getOrCreateChatId([senderId, receiverId]);
    }
    final messageDoc =
        firestore.collection('chats').doc(chatId).collection('messages').doc();
    final messageData = {
      'senderId': senderId,
      'text': imageUrl,
      "type": messageType,
      "repliedTo": repliedTo,
      "reply": reply,
      "replyType": replyType,
      "isSeen": false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await messageDoc.set(messageData);

    if (messageType == image) {
      await firestore.collection('chats').doc(chatId).update({
        'lastMessage': "🌄 Image",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } else if (messageType == video) {
      await firestore.collection('chats').doc(chatId).update({
        'lastMessage': "🎥 Video",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } else if (messageType == audio) {
      await firestore.collection('chats').doc(chatId).update({
        'lastMessage': "🎵 Audio",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } else if (messageType == GIF) {
      await firestore.collection('chats').doc(chatId).update({
        'lastMessage': "📽️ GIF",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } else {
      await firestore.collection('chats').doc(chatId).update({
        'lastMessage': "🗂️ File",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
  }
}
