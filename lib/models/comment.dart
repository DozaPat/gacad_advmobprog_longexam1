class CommentAuthor {
  const CommentAuthor({
    required this.id,
    required this.username,
    required this.fullName,
  });

  final int id;
  final String username;
  final String fullName;

  factory CommentAuthor.fromJson(Map<String, dynamic> json) {
    return CommentAuthor(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      fullName:
          json['fullName'] as String? ??
          json['username'] as String? ??
          'Facebook user',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'fullName': fullName};
  }
}

class PostComment {
  const PostComment({
    required this.id,
    required this.body,
    required this.postId,
    required this.likes,
    required this.user,
  });

  final int id;
  final String body;
  final int postId;
  final int likes;
  final CommentAuthor user;

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      body: json['body'] as String? ?? '',
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      user: CommentAuthor.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'postId': postId,
      'likes': likes,
      'user': user.toJson(),
    };
  }
}
