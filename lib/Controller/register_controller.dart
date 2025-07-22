import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Env_File.dart'; // Replace with your baseUrl file

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

      // Ensure at least phone or email is provided
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

      // Conditionally add phone and email
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

  // Login existing user
  Future<bool> loginUser({
    required String identifier, // email or phone
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier.trim(),
          'password': password.trim(),
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Login successful: $data');
        // You can save token or user info here
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
