import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatData {
  final String chatId;
  final bool isGroup;
  final String? email;
  final String? name;
  final String? groupName;
  final String dp;
  final String? lastMessage;
  final String? lastMessageTime;
  final bool hasStory;
  final String? userId;
  final List<String> participants;
  ChatData({
    required this.chatId,
    required this.isGroup,
    this.email,
    this.name,
    this.groupName,
    required this.dp,
    this.lastMessage,
    this.lastMessageTime,
    this.userId,
    required this.participants,
    required this.hasStory,
  });

  ChatData copyWith({
    String? chatId,
    bool? isGroup,
    String? email,
    String? name,
    String? groupName,
    String? dp,
    String? lastMessage,
    String? lastMessageTime,
    String? userId,
    List<String>? participants,
    bool? hasStory,
  }) {
    return ChatData(
      chatId: chatId ?? this.chatId,
      isGroup: isGroup ?? this.isGroup,
      email: email ?? this.email,
      name: name ?? this.name,
      groupName: groupName ?? this.groupName,
      dp: dp ?? this.dp,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      participants: participants ?? this.participants,
      hasStory: hasStory ?? this.hasStory,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatId': chatId,
      'isGroup': isGroup,
      'email': email,
      'name': name,
      'groupName': groupName,
      'dp': dp,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'participants': participants,
      'hasStory': hasStory,
      'userid': userId,
    };
  }

  factory ChatData.fromMap(Map<String, dynamic> map) {
    // print("chat data map $map");
    return ChatData(
      chatId: map['chatId'] as String,
      isGroup: map['isGroup'] as bool,
      email: map['email'] != null ? map['email'] as String : "",
      name: map['name'] != null ? map['name'] as String : "",
      groupName: map['groupName'] != null ? map['groupName'] as String : "",
      dp: map['dp'] as String,
      lastMessage:
          map['lastMessage'] != null ? map['lastMessage'] as String : "",
      lastMessageTime:
          map['lastMessageTime'] != null
              ? (map['lastMessageTime'] as Timestamp).toDate().toIso8601String()
              : "",
      hasStory: map['hasStory']!=null ?map['hasStory'] as bool:false,
      userId: map["userId"] != null ? map["userId"] as String : "",
      participants:
          (map["participants"] as List).map((e) => e.toString()).toList(),
    );
  }

  String toJson() => json.encode(toMap());
}
