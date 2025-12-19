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
    required this.participants,
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
    List<String>? participants,
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
    };
  }

  factory ChatData.fromMap(Map<String, dynamic> map) {
    print("chat data map $map");
    return ChatData(
      chatId: map['chatId'] as String,
      isGroup: map['isGroup'] as bool,
      email: map['email'] != null ? map['email'] as String : "",
      name: map['name'] != null ? map['name'] as String : "",
      groupName: map['groupName'] != null ? map['groupName'] as String : "",
      dp: map['dp'] as String,
      lastMessage:
          map['lastMessage'] != null ? map['lastMessage'] as String : "",
      lastMessageTime:map['lastMessageTime']!=null? (map['lastMessageTime'] as Timestamp).toDate().toIso8601String():"",
      participants:
          (map["participants"] as List).map((e) => e.toString()).toList(),
    );
  }

  String toJson() => json.encode(toMap());
}
