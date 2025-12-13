// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Message {
  final String id;
  final bool isSeen;
  final String senderId;
  final String type;
  final String repliedTo;
  final String replyType;
  final String reply;
  final String content;
  Message({
    required this.id,
    required this.isSeen,
    required this.senderId,
    required this.type,
    required this.repliedTo,
    required this.replyType,
    required this.reply,
    required this.content,
  });

  Message copyWith({
    String? id,
    bool? isSeen,
    String? senderId,
    String? type,
    String? repliedTo,
    String? replyType,
    String? reply,
    String? content,
  }) {
    return Message(
      id: id ?? this.id,
      isSeen: isSeen ?? this.isSeen,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      repliedTo: repliedTo ?? this.repliedTo,
      replyType: replyType ?? this.replyType,
      reply: reply ?? this.reply,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isSeen': isSeen,
      'senderId': senderId,
      'type': type,
      'repliedTo': repliedTo,
      'replyType': replyType,
      'reply': reply,
      'content': content,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      isSeen: map['isSeen'] as bool,
      senderId: map['senderId'] as String,
      type: map['type'] as String,
      repliedTo: map['repliedTo'] as String,
      replyType: map['replyType'] as String,
      reply: map['reply'] as String,
      content: map['text'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);
}
