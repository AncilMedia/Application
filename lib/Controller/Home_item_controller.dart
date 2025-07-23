import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Env_File.dart';
import '../model/Home_Item.dart';

class ApiService {
  // 🔹 Fetch all top-level items (no filtering)
  static Future<List<Item>> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl/api/item'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  // 🔹 Fetch items by userId (with token auth)
  static Future<List<Item>> fetchItemsByUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null || userId.isEmpty) {
      throw Exception('Missing token or userId');
    }

    final uri = Uri.parse('$baseUrl/api/item/user/$userId'); // ← Double-check this path
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      print('❌ Failed to load items by user ID. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      throw Exception('Failed to load items by user ID');
    }
  }

  // 🔹 Fetch sub-items for a given parentId
  static Future<List<Item>> fetchSubItems(String parentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/lists/all?parentId=$parentId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sub-items');
    }
  }
}
