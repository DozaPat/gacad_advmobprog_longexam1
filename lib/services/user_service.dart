import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/user.dart';

class UserService {
  UserService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$host/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'password': password,
        'expiresInMins': 60,
      }),
    );

    final data = _decodeObject(response.body);
    if (response.statusCode != 200) {
      throw ApiException(
        data['message'] as String? ?? 'Unable to sign in. Please try again.',
        response.statusCode,
      );
    }
    return User.fromJson(data);
  }

  Future<User> getAuthenticatedUser(String accessToken) async {
    final response = await _client.get(
      Uri.parse('$host/auth/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final data = _decodeObject(response.body);
    if (response.statusCode != 200) {
      throw ApiException(
        data['message'] as String? ?? 'Your session is no longer valid.',
        response.statusCode,
      );
    }
    return User.fromJson(data).copyWith(accessToken: accessToken);
  }

  Future<User> getUser(int userId) async {
    final response = await _client.get(Uri.parse('$host/users/$userId'));
    if (response.statusCode != 200) {
      throw ApiException('Failed to load user.', response.statusCode);
    }
    return User.fromJson(_decodeObject(response.body));
  }

  Future<Map<int, User>> getUsers() async {
    final uri = Uri.parse(
      '$host/users?limit=0&select=id,username,firstName,lastName,email,image',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Failed to load post authors.', response.statusCode);
    }

    final data = _decodeObject(response.body);
    final usersJson = data['users'] as List<dynamic>? ?? const [];
    final users = <int, User>{};
    for (final item in usersJson) {
      if (item is Map<String, dynamic>) {
        final user = User.fromJson(item);
        users[user.id] = user;
      }
    }
    return users;
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object response.');
    }
    return decoded;
  }
}

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
