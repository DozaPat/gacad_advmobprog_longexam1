import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import 'custom_inkwell_button.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    required this.post,
    required this.onCommentTap,
    this.author,
    this.showFullBody = false,
    super.key,
  });

  final Post post;
  final User? author;
  final VoidCallback onCommentTap;
  final bool showFullBody;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _liked = false;

  int get _visibleLikes => widget.post.likes + (_liked ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final author = widget.author;
    final authorName = author?.fullName.isNotEmpty == true
        ? author!.fullName
        : 'Campus member ${widget.post.userId}';

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
            child: Row(
              children: [
                _AuthorAvatar(author: author),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Suggested for you · Public',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Post options',
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.post.title.isNotEmpty) ...[
                  Text(
                    widget.post.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  widget.post.body,
                  maxLines: widget.showFullBody ? null : 5,
                  overflow: widget.showFullBody ? null : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15.5, height: 1.35),
                ),
                if (widget.post.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.post.tags.map((tag) => '#$tag').join('  '),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 9,
                  backgroundColor: Color(0xFF1877F2),
                  child: Icon(Icons.thumb_up, size: 11, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Text('$_visibleLikes'),
                const Spacer(),
                if (widget.post.views > 0) Text('${widget.post.views} views'),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Row(
            children: [
              Expanded(
                child: CustomInkWellButton(
                  label: 'Like',
                  icon: _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  active: _liked,
                  onTap: () => setState(() => _liked = !_liked),
                ),
              ),
              Expanded(
                child: CustomInkWellButton(
                  label: 'Comment',
                  icon: Icons.mode_comment_outlined,
                  onTap: widget.onCommentTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.author});

  final User? author;

  @override
  Widget build(BuildContext context) {
    final imageUrl = author?.image ?? '';
    final fallback = author?.firstName.isNotEmpty == true
        ? author!.firstName.characters.first.toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 22,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundImage: imageUrl.isEmpty
          ? null
          : CachedNetworkImageProvider(imageUrl),
      child: Text(
        fallback,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
