import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.hive.blog/';

  /// Fetch posts from the Hive API
  static Future<List<dynamic>> fetchPosts() async {
    const body = {
      "id": 1,
      "jsonrpc": "2.0",
      "method": "bridge.get_ranked_posts",
      "params": {"sort": "trending", "tag": "", "observer": "hive.blog"}
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] is List) {
          return data['result'];
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to fetch posts');
      }
    } catch (error) {
      print('Error fetching posts: $error');
      throw error;
    }
  }
}
