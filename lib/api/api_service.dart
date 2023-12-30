import 'dart:convert';
import 'package:flutter_lab/api/post_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String apiUrl = "https://jsonplaceholder.typicode.com/posts";

  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<PostModel> posts =
            data.map((json) => PostModel.fromJson(json)).toList();
        return posts;
      } else {
        throw ApiRequestException(
            'Không thể tải bài đăng. Mã trạng thái: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiRequestException('Không thể tải bài đăng. Lỗi: $e');
    }
  }
}

class ApiRequestException implements Exception {
  final String message;

  ApiRequestException(this.message);

  @override
  String toString() => 'Lỗi khi thực hiện yêu cầu API: $message';
}
