// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AppUserModel {
  final String email;
  final String firebaseUID;
  AppUserModel({
    required this.email,
    required this.firebaseUID,
  });



  AppUserModel copyWith({
    String? email,
    String? firebaseUID,
  }) {
    return AppUserModel(
      email: email ?? this.email,
      firebaseUID: firebaseUID ?? this.firebaseUID,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'uid': firebaseUID,
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      email: map['email'] as String,
      firebaseUID: map['uid'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUserModel.fromJson(String source) => AppUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

}
