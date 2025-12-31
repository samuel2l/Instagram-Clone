// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/chat/models/chat_data.dart';
import 'package:instagram/chat/models/message.dart';
import 'package:instagram/chat/models/message_to_reply.dart';
import 'package:instagram/utils/constants.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(firestore: FirebaseFirestore.instance);
});

final chatIdProvider = StateProvider<String>((ref) => '');
final showReplyProvider = StateProvider<bool>((ref) => false);
final messageToReplyProvider = StateProvider<MessageToReply?>((ref) => null);
final selectedGroupMembersProvider = StateProvider<Set<String>>((ref) => {});

class ChatRepository {
  FirebaseFirestore firestore;
  ChatRepository({required this.firestore});
  Stream<List<ChatData>> getUserChats(String userId) {
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
                  // print("user data at chat repo? $userData");
                  chatData['email'] = userData['email'];
                  chatData['name'] = userData['name'];
                  chatData['dp'] = userData['dp'];
                  chatData['hasStory'] = userData['hasStory'];
                  chatData["userId"] = userData["uid"];
                }
              }
              return chatData;
            }).toList(),
          );

          return enrichedChats.map((chat) => ChatData.fromMap(chat)).toList();
        });
  }

  Future<ChatData> getChatByParticipants(
    List<String> userIds,
    String currentUserId,
  ) async {
    userIds.sort();
    final querySnap =
        await firestore
            .collection('chats')
            .where('participants', isEqualTo: userIds)
            .limit(1)
            .get();

    if (querySnap.docs.isNotEmpty) {
      final doc = querySnap.docs.first;
      final chatData = doc.data();
      chatData['chatId'] = doc.id;

      if (chatData["isGroup"]) {
        return ChatData.fromMap(chatData);
      } else {
        String otherUserId = userIds.firstWhere((id) => id != currentUserId);

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
          chatData['dp'] = userData['dp'];
        }

        return ChatData.fromMap(chatData);
      }
    } else {
      //if no participants are found matching given ids it means that is the first time a message is being sent
      //but to send to chatscreen we need chat data so dummy chat data will be provided

      String otherUserId = userIds.firstWhere((id) => id != currentUserId);

      final userSnap =
          await firestore
              .collection('users')
              .where('uid', isEqualTo: otherUserId)
              .limit(1)
              .get();

      if (userSnap.docs.isNotEmpty) {
        final userData = userSnap.docs.first.data();
        final AppUserModel user = AppUserModel.fromMap(userData);
        return ChatData(
          chatId: "",
          isGroup: false,
          dp: user.profile.dp,
          participants: userIds,
          name: user.profile.name,
          hasStory: user.profile.hasStory,
        );
      }
    }
    return ChatData(
      chatId: "",
      isGroup: false,
      dp: "",
      participants: [],
      hasStory: false,
    );
  }

  Stream<List<Map<String, dynamic>>> getUsers() {
    var users = firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    return users;
  }

  Future<AppUserModel?> getUserById(String uid) async {
    final snapshot =
        await firestore
            .collection('users')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return AppUserModel.fromMap(snapshot.docs.first.data());
  }

  Future<List<AppUserModel>> getMutualFollowers(String currentUid) async {
    final userDoc = await firestore.collection('users').doc(currentUid).get();

    if (!userDoc.exists) return [];

    final data = userDoc.data()!;
    final List<String> following = List<String>.from(data['following'] ?? []);
    final List<String> followers = List<String>.from(data['followers'] ?? []);

    // intersection
    final mutualUids =
        following.where((uid) => followers.contains(uid)).toList();

    if (mutualUids.isEmpty) return [];

    // Firestore whereIn limit handling
    const batchSize = 10;
    final List<AppUserModel> users = [];

    for (int i = 0; i < mutualUids.length; i += batchSize) {
      final batch = mutualUids.sublist(
        i,
        i + batchSize > mutualUids.length ? mutualUids.length : i + batchSize,
      );

      final snapshot =
          await firestore
              .collection('users')
              .where('uid', whereIn: batch)
              .get();

      users.addAll(
        snapshot.docs.map((doc) => AppUserModel.fromMap(doc.data())),
      );
    }

    return users;
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

  Future<ChatData> createGroupChat({
    required List<String> userIds,
    required String groupName,
    required String groupDp,
  }) async {
    final newChatDoc = firestore.collection('chats').doc();

    final data = {
      'participants': userIds,
      'isGroup': true,
      'groupName': groupName,
      'dp':groupDp,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    };

    await newChatDoc.set(data);

    final snapshot = await newChatDoc.get();
    final docData = snapshot.data() ?? {};

    final chatData = {'chatId': newChatDoc.id, ...docData};

    return ChatData.fromMap(chatData);
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

  Future<String> sendMessage({
    required String receiverId,
    required String senderId,
    required String messageText,
    required String chatId,
    String repliedTo = "",
    String reply = "",
    String replyType = "",

    bool isGroup = false,
    String groupName = "",
  }) async {
    try {
      if (chatId.isEmpty) {
        //if it is a group this condiiton will never be true as chat id is created for group when group's created
        chatId = await getOrCreateChatId([senderId, receiverId]);
      }
      final messageDoc =
          firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .doc();

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
      return chatId;
    } catch (e) {
      // showSnackBar(context: context, content: content)
      print("error come $e");
      return "";
    }
  }

  Future<Map<String, AppUserModel>> getUsersByIds(
    List<String> uids,
    bool isGroup,
  ) async {
    if (uids.isEmpty || !isGroup) return {};

    final Map<String, AppUserModel> usersMap = {};

    const int batchSize = 10;

    for (int i = 0; i < uids.length; i += batchSize) {
      final batch = uids.sublist(
        i,
        i + batchSize > uids.length ? uids.length : i + batchSize,
      );

      final snapshot =
          await firestore
              .collection('users')
              .where('uid', whereIn: batch)
              .get();

      for (final doc in snapshot.docs) {
        final user = AppUserModel.fromMap(doc.data());
        usersMap[user.firebaseUID] = user; // uid → model
      }
    }

    return usersMap;
  }

  Stream<List<Message>> getMessages(String chatId) {
    if (chatId.isEmpty) {
      return firestore
          .collection('chats')
          .doc("123")
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Message.fromMap(doc.data()))
                    .toList(),
          );
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
                return Message.fromMap(data);
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
