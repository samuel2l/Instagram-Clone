// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Post {
  final String postId;
  final List<String> mediaUrls;
  Post({required this.postId, required this.mediaUrls});

  Post copyWith({String? postId, List<String>? mediaUrls}) {
    return Post(
      postId: postId ?? this.postId,
      mediaUrls: mediaUrls ?? this.mediaUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'postId': postId, 'mediaUrls': mediaUrls};
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    print("postt map: $map");
    
    return Post(
      postId: map['postId'] as String,
      mediaUrls:(map["imageUrls"] as List).map((e) => e.toString()).toList(),
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
