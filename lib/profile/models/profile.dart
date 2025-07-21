class Profile {
  final List<String> followers;
  final List<String> following;
  final String name;
  final String bio;
  final String dp;

  Profile({
    required this.following,
    required this.followers,
    required this.name,
    required this.bio,
    required this.dp,
  });
}
