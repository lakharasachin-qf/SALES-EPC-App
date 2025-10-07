import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String status;
  String message;
  User user;

  LoginModel({required this.status, required this.message, required this.user});

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    status: json["status"],
    message: json["message"],
    user: User.fromJson(json["user"]),
    // user: User.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "user": user.toJson(),
  };
}

class User {
  int userId;
  String username;
  String email;
  int role;
  List<String> rights;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.rights,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["user_id"],
    username: json["username"],
    email: json["email"],
    role: json["role"],
    rights: List<String>.from(json["rights"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "email": email,
    "role": role,
    "rights": List<dynamic>.from(rights.map((x) => x)),
  };
}
