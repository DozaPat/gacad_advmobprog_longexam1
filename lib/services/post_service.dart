import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/post.dart';
import 'user_service.dart';

class PostService {
  PostService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Post>> getPosts({int limit = 30, int skip = 0}) async {
    final uri = Uri.parse('$host/posts?limit=$limit&skip=$skip');
    return _fetchPosts(uri);
  }

  Future<List<Post>> getPostsByUser(
    int userId, {
    int limit = 30,
    int skip = 0,
  }) async {
    final uri = Uri.parse('$host/posts/user/$userId?limit=$limit&skip=$skip');
    return _fetchPosts(uri);
  }

  Future<List<Post>> _fetchPosts(Uri uri) async {
    final response = await _client.get(
      uri,
      headers: const {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to load posts: ${response.statusCode}',
        response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object response.');
    }
    final postsJson = decoded['posts'] as List<dynamic>? ?? const [];
    return postsJson
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList(growable: false);
  }
}
