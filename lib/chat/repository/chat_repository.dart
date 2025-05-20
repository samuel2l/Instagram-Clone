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

              // Add chat ID
              chatData['chatId'] = doc.id;

              // Get the other participant's UID
              List participants = chatData['participants'];
              String otherUserId = participants.firstWhere(
                (id) => id != userId,
              );

              // Fetch other user's data
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

  Future<String> getChatId(List<String> userIds, {bool isGroup = false}) async {
    final chatQuery =
        await firestore
            .collection('chats')
            .where('participants', isEqualTo: userIds)
            .limit(1)
            .get();

    if (chatQuery.docs.isNotEmpty) {
      return chatQuery.docs.first.id;
    }
    return "";
  }

  Future<String> getOrCreateChatId(
    List<String> userIds, {
    bool isGroup = false,
  }) async {
    final chatQuery =
        await firestore
            .collection('chats')
            .where('participants', isEqualTo: userIds)
            .limit(1)
            .get();

    if (chatQuery.docs.isNotEmpty) {
      return chatQuery.docs.first.id;
    }

    // Create a new chat if not found
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

  Future<void> sendMessage({
    required String receiverId,
    required String senderId,
    required String messageText,
    required String chatId,
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
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> sendFile({
    //generic function to send audio,images,gifs,files etc
    required String receiverId,
    required String senderId,

    required String chatId,

    required String messageType,
    required String imageUrl,
  }) async {
    print("gotten imng url");
    print(imageUrl);
    if (chatId.isEmpty) {
      chatId = await getOrCreateChatId([senderId, receiverId]);
    }
    final messageDoc =
        firestore.collection('chats').doc(chatId).collection('messages').doc();
    final messageData = {
      'senderId': senderId,
      'text': imageUrl,
      "type": messageType,
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
    } else if (messageType == gif) {
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

  // void sendFile({
  //   required BuildContext context,
  //   required File file,
  //   required UserModel receiver,
  //   required UserModel sender,
  //   required ProviderRef ref,
  //   required MessageType messageType,
  // }) async {
  //   try {
  //     var timeSent = DateTime.now();
  //     var messageId = const Uuid().v1();

  //     String fileUrl =
  //         await ref.read(firebaseStorageRepositoryProvider).storeFileToFirebase(
  //               'chat/${messageType.type}/${sender.uid}/${receiver.uid}/$messageId',
  //               file,
  //             );

  //     String displayMessage;

  //     switch (messageType) {
  //       case MessageType.image:
  //         displayMessage = '🎞️ Image';
  //         break;
  //       case MessageType.video:
  //         displayMessage = '🎥 Video';
  //         break;
  //       case MessageType.audio:
  //         displayMessage = '🎵 Audio';
  //         break;
  //       case MessageType.gif:
  //         displayMessage = ' GIF';
  //         break;
  //       default:
  //         displayMessage = '';
  //     }
  //     saveChatDataToContactCollection(
  //         sender: sender,
  //         receiver: receiver,
  //         text: displayMessage,
  //         timeSent: timeSent);

  //     saveMessage(
  //         sender: sender,
  //         receiver: receiver,
  //         text: fileUrl,
  //         timeSent: timeSent,
  //         messageId: messageId,
  //         messageType: messageType, reply: null);
  //   } catch (e) {
  //     showSnackBar(context: context, content: e.toString());
  //   }
  // }
}
