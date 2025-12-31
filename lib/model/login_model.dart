class LoginModel {
  final int status;
  final String message;
  final String userId;
  final String name;
  final String email;
  final String gender;

  LoginModel({
    required this.status,
    required this.message,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final user = json['data'][0];

    return LoginModel(
      status: json['status'],
      message: json['message'],
      userId: user['usersrno'],
      name: user['name'],
      email: user['email'],
      gender: user['gender'],
    );
  }
}
