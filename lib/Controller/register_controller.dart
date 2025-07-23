import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Env_File.dart';

class AuthController {
  // Register a new user
  Future<bool> registerUser({
    required String username,
    required String phone,
    required String password,
    required String email,
    required String packageName,
  }) async {
    try {
      final trimmedPhone = phone.trim();
      final trimmedEmail = email.trim();

      if (trimmedPhone.isEmpty && trimmedEmail.isEmpty) {
        print("⚠️ Registration failed: Phone or Email required.");
        return false;
      }

      final Map<String, dynamic> body = {
        'username': username.trim(),
        'password': password.trim(),
        'isMobile': true,
        'packageName': packageName.trim(),
      };

      if (trimmedPhone.isNotEmpty && trimmedPhone != '0000000000') {
        body['phone'] = trimmedPhone;
      }

      if (trimmedEmail.isNotEmpty && trimmedEmail != 'contact@app.com') {
        body['email'] = trimmedEmail.toLowerCase();
      }

      final response = await http
          .post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        print("✅ Registered: ${jsonDecode(response.body)}");
        return true;
      } else {
        print("❌ Registration failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error during registration: $e");
      return false;
    }
  }

  // Login and store token/user info
  Future<bool> loginUser({
    required String identifier, // email or phone
    required String password,
    required String packageName,
    String? appName, // optional
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'identifier': identifier.trim(),
        'password': password.trim(),
        'packageName': packageName.trim(),
      };

      if (appName != null && appName.trim().isNotEmpty) {
        requestBody['appName'] = appName.trim();
      }

      final response = await http
          .post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Login successful: $data');

        // Store tokens and user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);
        await prefs.setString('userId', data['user']['userId']);
        await prefs.setString('role', data['user']['role']);
        await prefs.setBool('isLoggedIn', true);

        return true;
      } else {
        print('❌ Login failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error during login: $e');
      return false;
    }
  }
}
