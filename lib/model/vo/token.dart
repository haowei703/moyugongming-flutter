class JWT {
  final String accessToken;
  final String id;
  final String username;
  JWT({required this.accessToken, required this.id, required this.username});

  factory JWT.fromJson(Map<String, dynamic> json) {
    return JWT(
        accessToken: json['access_token'] as String,
        id: json['id'] as String,
        username: json['username'] as String);
  }
}
