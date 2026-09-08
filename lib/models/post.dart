class Post {
  const Post({
    required this.id,
    required this.postId,
    required this.userId,
    required this.title,
    required this.body,
    required this.likes,
    required this.dislikes,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.views = 0,
  });

  final int id;
  final int postId;
  final int userId;
  final String title;
  final String body;
  final int likes;
  final int dislikes;
  final String createdAt;
  final String updatedAt;
  final List<String> tags;
  final int views;

  factory Post.fromJson(Map<String, dynamic> json) {
    final reactions = json['reactions'] as Map<String, dynamic>?;
    final id =
        (json['id'] as num?)?.toInt() ??
        (json['postId'] as num?)?.toInt() ??
        (json['post_id'] as num?)?.toInt() ??
        0;

    return Post(
      id: id,
      postId:
          (json['postId'] as num?)?.toInt() ??
          (json['post_id'] as num?)?.toInt() ??
          id,
      userId:
          (json['userId'] as num?)?.toInt() ??
          (json['user_id'] as num?)?.toInt() ??
          0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      likes:
          (reactions?['likes'] as num?)?.toInt() ??
          (json['likes'] as num?)?.toInt() ??
          0,
      dislikes:
          (reactions?['dislikes'] as num?)?.toInt() ??
          (json['dislikes'] as num?)?.toInt() ??
          0,
      createdAt:
          json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      updatedAt:
          json['updatedAt'] as String? ?? json['updated_at'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(growable: false),
      views: (json['views'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'title': title,
      'body': body,
      'reactions': {'likes': likes, 'dislikes': dislikes},
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tags': tags,
      'views': views,
    };
  }
}
