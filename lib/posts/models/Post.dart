// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String userId;
  final String postId;
  final List<String> mediaUrls;
  final String caption;
  final String createdAt;

  Post({
    required this.userId,
    required this.postId,
    required this.mediaUrls,
    required this.caption,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "userId": userId,
      'postId': postId,
      'mediaUrls': mediaUrls,
      'caption': caption,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      userId: map['uid'] as String,
      postId: map['postId'] as String,
      mediaUrls: (map["imageUrls"] as List).map((e) => e.toString()).toList(),
      caption: map['caption'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate().toIso8601String(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);
}

// class Comments {
//   final String email;
//   final String content;
//   final
// }
