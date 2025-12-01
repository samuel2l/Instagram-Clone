// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/profile/models/profile.dart';

class AppUserModel {
  final String email;
  final String firebaseUID;
  final String username;
  final String createdAt;
  final Profile profile;

  AppUserModel({
    required this.email,
    required this.firebaseUID,
    required this.createdAt,
    required this.username,
    required this.profile,
  });

  AppUserModel copyWith({
    String? email,
    String? firebaseUID,
    String? createdAt,
    String? username,
    Profile? profile,
  }) {
    return AppUserModel(
      email: email ?? this.email,
      firebaseUID: firebaseUID ?? this.firebaseUID,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'uid': firebaseUID,
      "profile":  profile.toMap(),
      'createdAt': createdAt,
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    print("map in fromMap? $map");  

    return AppUserModel(
      email: map['email'] as String,
      firebaseUID: map['uid'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate().toIso8601String(),
      username: map['username'] ?? "",
      profile: Profile(
        bio: map["bio"] ?? "",
        name: map["name"] ?? "",
        followers:  List<String>.from(map["followers"]??[]) ,
        following: List<String>.from(map["following"]??[]),
        dp:
            map["dp"] ??
            "https://plus.unsplash.com/premium_photo-1669748157617-a3a83cc8ea23?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8YmVhdXRpZnVsJTIwdmlld3N8ZW58MHx8MHx8fDA%3D",
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUserModel.fromJson(String source) =>
      AppUserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
