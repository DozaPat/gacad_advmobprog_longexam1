import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/comment.dart';
import 'user_service.dart';

class CommentService {
  CommentService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<PostComment>> getCommentsByPost(int postId) async {
    final response = await _client.get(
      Uri.parse('$host/comments/post/$postId'),
      headers: const {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to load comments: ${response.statusCode}',
        response.statusCode,
      );
    }

    final data = _decodeObject(response.body);
    final commentsJson = data['comments'] as List<dynamic>? ?? const [];
    return commentsJson
        .whereType<Map<String, dynamic>>()
        .map(PostComment.fromJson)
        .toList(growable: true);
  }

  Future<PostComment> addComment({
    required int postId,
    required int userId,
    required String body,
  }) async {
    final response = await _client.post(
      Uri.parse('$host/comments/add'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'body': body.trim(),
        'postId': postId,
        'userId': userId,
      }),
    );
    final data = _decodeObject(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(
        data['message'] as String? ?? 'Failed to add your comment.',
        response.statusCode,
      );
    }
    return PostComment.fromJson(data);
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object response.');
    }
    return decoded;
  }
}
