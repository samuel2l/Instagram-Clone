// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MessageToReply {
  final String senderId;
  final String text;
  final String type;
  MessageToReply({
    required this.senderId,
    required this.text,
    required this.type,
  });
  

  MessageToReply copyWith({
    String? senderId,
    String? text,
    String? type,
  }) {
    return MessageToReply(
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'text': text,
      'type': type,
    };
  }

  factory MessageToReply.fromMap(Map<String, dynamic> map) {
    return MessageToReply(
      senderId: map['senderId'] as String,
      text: map['text'] as String,
      type: map['type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageToReply.fromJson(String source) => MessageToReply.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'MessageToReply(senderId: $senderId, text: $text, type: $type)';

  @override
  bool operator ==(covariant MessageToReply other) {
    if (identical(this, other)) return true;
  
    return 
      other.senderId == senderId &&
      other.text == text &&
      other.type == type;
  }

  @override
  int get hashCode => senderId.hashCode ^ text.hashCode ^ type.hashCode;
}
