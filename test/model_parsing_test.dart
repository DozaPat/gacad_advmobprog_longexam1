import 'package:flutter_test/flutter_test.dart';
import 'package:gacad_advmobprog_longexam1/models/comment.dart';
import 'package:gacad_advmobprog_longexam1/models/post.dart';
import 'package:gacad_advmobprog_longexam1/models/user.dart';

void main() {
  group('API model parsing', () {
    test('Post reads current DummyJSON reactions and compatibility fields', () {
      final post = Post.fromJson({
        'id': 7,
        'userId': 3,
        'title': 'Campus update',
        'body': 'A complete post body.',
        'tags': ['news', 'campus'],
        'reactions': {'likes': 11, 'dislikes': 2},
        'views': 42,
      });

      expect(post.id, 7);
      expect(post.postId, 7);
      expect(post.userId, 3);
      expect(post.likes, 11);
      expect(post.dislikes, 2);
      expect(post.tags, ['news', 'campus']);
      expect(post.views, 42);
    });

    test('User session fields survive JSON persistence', () {
      const original = User(
        id: 1,
        username: 'emilys',
        firstName: 'Emily',
        lastName: 'Johnson',
        email: 'emily@example.com',
        image: 'https://example.com/avatar.png',
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      final restored = User.fromJson(original.toJson());
      expect(restored.fullName, 'Emily Johnson');
      expect(restored.accessToken, 'access-token');
      expect(restored.refreshToken, 'refresh-token');
    });

    test('PostComment reads its nested author', () {
      final comment = PostComment.fromJson({
        'id': 341,
        'body': 'Looks good!',
        'postId': 9,
        'likes': 4,
        'user': {'id': 1, 'username': 'emilys', 'fullName': 'Emily Johnson'},
      });

      expect(comment.postId, 9);
      expect(comment.user.fullName, 'Emily Johnson');
      expect(comment.likes, 4);
    });
  });
}
