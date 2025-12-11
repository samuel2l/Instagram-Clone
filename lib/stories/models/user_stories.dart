import 'dart:convert';
import 'package:instagram/profile/models/profile.dart';
import 'package:instagram/stories/models/story.dart';

class UserStories {
  final String userId;
  final List<Story> stories;
  final Profile profile;
  UserStories({
    required this.userId,
    required this.stories,
    required this.profile,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'stories': stories.map((x) => x.toMap()).toList(),
      'profile': profile.toMap(),
    };
  }

  factory UserStories.fromMap(Map<String, dynamic> map,String userId) {
    return UserStories(
      userId: userId,
      stories: List<Story>.from(
        (map['stories'] as List<Map<String,dynamic>>).map<Story>(
          (x) => Story.fromMap(x),
        ),
      ),
      profile: Profile.fromMap(map['userProfile'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

}
