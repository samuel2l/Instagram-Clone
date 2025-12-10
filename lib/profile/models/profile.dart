class Profile {
  final List<String> followers;
  final List<String> following;
  final String name;
  final String bio;
  final String dp;
  final String username;
  bool hasStory=false;

  Profile({
    required this.following,
    required this.followers,
    required this.name,
    required this.bio,
    required this.dp,
    required this.username,
    required this.hasStory,
  });
  Map<String, dynamic> toMap() {
    return {
      'followers': followers,
      'following': following,
      'name': name,
      'bio': bio,
      'dp': dp,
      'username': username,
      'hasStory': hasStory,
    };
  }
}
