import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:5007/api/auth';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['message']?.toString() ?? 'Failed to login');
      } catch (_) {
        throw Exception('Failed to login (${response.statusCode}): ${response.body}');
      }
    }
  }
  

    Future<Map<String, dynamic>> register(
    String username, String email, String password) async {
  final url = Uri.parse('$baseUrl/register');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      'role': 'user', // ✅ Force 'user' role
    }),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    // ✅ Safe error handling
    throw Exception(json.decode(response.body)?['message']?.toString() ?? response.body.toString());
  }
}

}
