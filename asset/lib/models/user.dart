import 'dart:convert';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'role': role,
      };

  // ✅ Encode properly
  String toJsonString() => jsonEncode(toJson());

  // ✅ Decode properly
 
  static UserModel fromJsonString(String jsonString) {
  final jsonMap = jsonDecode(jsonString);
  return UserModel.fromJson(jsonMap);
}

}
