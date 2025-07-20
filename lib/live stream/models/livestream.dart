// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Livestream {
  final String email;
  final String uid;

  final  startedAt;
  final int viewerCount;
  final String channelId;
  Livestream({
    required this.email,
    required this.uid,
    required this.startedAt,
    required this.viewerCount,
    required this.channelId,
  });
  

  Livestream copyWith({
    String? email,
    String? uid,

    int? viewerCount,
    String? channelId,
  }) {
    return Livestream(
      email: email ?? this.email,
      uid: uid ?? this.uid,
      startedAt: startedAt ?? this.startedAt,
      viewerCount: viewerCount ?? this.viewerCount,
      channelId: channelId ?? this.channelId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'uid': uid,
      'viewerCount': viewerCount,
      'channelId': channelId,
    };
  }

  factory Livestream.fromMap(Map<String, dynamic> map) {
    return Livestream(
      email: map['email'] as String,
      uid: map['uid'] as String,
      viewerCount: map['viewerCount'] as int,
      channelId: map['channelId'] as String,
      startedAt: map["startedAt"]??"",
    );
  }

  String toJson() => json.encode(toMap());

  factory Livestream.fromJson(String source) => Livestream.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Livestream(email: $email, uid: $uid, viewerCount: $viewerCount, channelId: $channelId)';
  }

}
