import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Env_File.dart';
import '../model/Home_Item.dart';

class ApiService {

  static Future<List<Item>> fetchItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/item'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }
}
