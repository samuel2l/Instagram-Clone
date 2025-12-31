class MessageToReply {
  final String senderId;
  final String text;
  final String type;
  final String chatId;
  MessageToReply({
    required this.senderId,
    required this.text,
    required this.type,
    required this.chatId,
  });

  MessageToReply copyWith({String? senderId, String? text, String? type, String? chatId }) {
    return MessageToReply(
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      chatId: chatId ?? this.chatId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'senderId': senderId, 'text': text, 'type': type};
  }

  factory MessageToReply.fromMap(Map<String, dynamic> map) {
    return MessageToReply(
      senderId: map['senderId'] as String,
      text: map['text'] as String,
      type: map['type'] as String,
      chatId: map['chatId'] as String,
    );
  }

}
