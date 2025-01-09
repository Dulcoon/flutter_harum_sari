import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      "https://52e8-36-81-70-227.ngrok-free.app/api"; // Sesuaikan URL backend Anda

  Future<Map<String, dynamic>> register(String name, String email,
      String password, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    return _processResponse(response);
  }

  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to logout");
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'An error occurred');
    }
  }
}
