import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gacad_advmobprog_longexam1/services/comment_service.dart';
import 'package:gacad_advmobprog_longexam1/services/post_service.dart';
import 'package:gacad_advmobprog_longexam1/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('API services', () {
    test('PostService applies pagination and parses the feed', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/posts');
        expect(request.url.queryParameters, {'limit': '2', 'skip': '4'});
        return http.Response(
          jsonEncode({
            'posts': [
              {
                'id': 5,
                'userId': 2,
                'title': 'Hello',
                'body': 'World',
                'reactions': {'likes': 7, 'dislikes': 1},
              },
            ],
          }),
          200,
        );
      });

      final posts = await PostService(
        client: client,
      ).getPosts(limit: 2, skip: 4);
      expect(posts, hasLength(1));
      expect(posts.single.likes, 7);
    });

    test(
      'UserService sends credentials and returns the authenticated user',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/auth/login');
          expect(jsonDecode(request.body), containsPair('username', 'emilys'));
          return http.Response(
            jsonEncode({
              'id': 1,
              'username': 'emilys',
              'firstName': 'Emily',
              'lastName': 'Johnson',
              'email': 'emily@example.com',
              'image': 'https://example.com/avatar.png',
              'accessToken': 'token',
              'refreshToken': 'refresh',
            }),
            200,
          );
        });

        final user = await UserService(
          client: client,
        ).login(username: 'emilys', password: 'emilyspass');
        expect(user.fullName, 'Emily Johnson');
        expect(user.accessToken, 'token');
      },
    );

    test('CommentService submits a comment with post and user IDs', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/comments/add');
        expect(
          jsonDecode(request.body),
          containsPair('body', 'A useful comment'),
        );
        expect(jsonDecode(request.body), containsPair('postId', 12));
        expect(jsonDecode(request.body), containsPair('userId', 1));
        return http.Response(
          jsonEncode({
            'id': 341,
            'body': 'A useful comment',
            'postId': 12,
            'user': {
              'id': 1,
              'username': 'emilys',
              'fullName': 'Emily Johnson',
            },
          }),
          200,
        );
      });

      final comment = await CommentService(
        client: client,
      ).addComment(postId: 12, userId: 1, body: 'A useful comment');
      expect(comment.id, 341);
      expect(comment.user.username, 'emilys');
    });
  });
}
