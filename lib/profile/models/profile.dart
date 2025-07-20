class Profile {
  final List<String> followers;
  final List<String> following;
  final List<String> posts;
  final String name;
  final String bio;

  Profile({
    required this.following,
    required this.followers,
    required this.posts,
    required this.name,
    required this.bio,
  });
}
