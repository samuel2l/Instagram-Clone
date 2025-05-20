// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  final String email;
  final String firebaseUID;
  final String createdAt;
  AppUserModel({
    required this.email,
    required this.firebaseUID,
    required this.createdAt,
  });

  AppUserModel copyWith({
    String? email,
    String? firebaseUID,
    String? createdAt,
  }) {
    return AppUserModel(
      email: email ?? this.email,
      firebaseUID: firebaseUID ?? this.firebaseUID,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'uid': firebaseUID,
      'createdAt': createdAt,
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      email: map['email'] as String,
      firebaseUID: map['uid'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate().toIso8601String(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUserModel.fromJson(String source) =>
      AppUserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
