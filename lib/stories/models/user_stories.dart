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

  factory UserStories.fromMap(Map<String, dynamic> map) {
    print("from map in user stories $map");
    print("the stories part ${map['stories']}");
    return UserStories(
      userId: map['userId'] as String,
      stories: List<Story>.from(
        (map['stories'] as List<int>).map<Story>(
          (x) => Story.fromMap(x as Map<String, dynamic>),
        ),
      ),
      profile: Profile.fromMap(map['profile'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserStories.fromJson(String source) =>
      UserStories.fromMap(json.decode(source) as Map<String, dynamic>);
}
