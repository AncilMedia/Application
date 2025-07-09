import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Env_File.dart';
import '../model/Home_Item.dart';

class ApiService {
  // Fetch top-level items from old /api/item
  static Future<List<Item>> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl/api/item'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  // Fetch sub-items for a given parentId from unified /api/lists/all
  static Future<List<Item>> fetchSubItems(String parentId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/lists/all?parentId=$parentId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sub-items');
    }
  }
}
