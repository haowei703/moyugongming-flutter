enum Sex {
  male,
  female,
}

class User {
  final int userid;
  final Sex sex;
  final String username;
  final String avatarUrl;

  const User(
      {required this.userid,
      required this.username,
      required this.sex,
      required this.avatarUrl});
}
