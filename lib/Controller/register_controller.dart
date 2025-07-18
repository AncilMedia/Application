import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Env_File.dart';

class RegisterController {
  Future<bool> registerUser({
    required String username,
    required String phone,
    required String password,
    required String email,
    required String packageName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'phone': phone,
          'password': password,
          'email': email,
          'isMobile': true,         // 👈 tell backend it's mobile registration
          'packageName': packageName, // 👈 required to generate unique appId
        }),
      );

      if (response.statusCode == 201) {
        print("✅ Registered: ${jsonDecode(response.body)}");
        return true;
      } else {
        print("❌ Registration failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error: $e");
      return false;
    }
  }
}
