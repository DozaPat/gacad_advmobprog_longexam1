import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../providers/session_provider.dart';
import '../services/comment_service.dart';
import '../widgets/post_card.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({required this.post, this.author, super.key});

  final Post post;
  final User? author;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _commentService = CommentService();
  final _commentController = TextEditingController();
  final _commentFocus = FocusNode();

  List<PostComment> _comments = [];
  bool _loading = true;
  bool _sending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final comments = await _commentService.getCommentsByPost(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Comments could not be loaded.';
      });
    }
  }

  Future<void> _submitComment(User user) async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final added = await _commentService.addComment(
        postId: widget.post.id,
        userId: user.id,
        body: body,
      );
      if (!mounted) return;
      final normalized = PostComment(
        id: added.id,
        body: added.body,
        postId: added.postId,
        likes: added.likes,
        user: CommentAuthor(
          id: user.id,
          username: user.username,
          fullName: user.fullName,
        ),
      );
      setState(() {
        _comments.insert(0, normalized);
        _sending = false;
      });
      _commentController.clear();
      _commentFocus.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added to this post.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your comment could not be added.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<SessionProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadComments,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  PostCard(
                    post: widget.post,
                    author: widget.author,
                    showFullBody: true,
                    onCommentTap: _commentFocus.requestFocus,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      'Comments (${_comments.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(_errorMessage!),
                          const SizedBox(height: 10),
                          FilledButton.tonal(
                            onPressed: _loadComments,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    )
                  else if (_comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: Text('No comments yet. Start the conversation.'),
                      ),
                    )
                  else
                    ..._comments.map(
                      (comment) => _CommentTile(comment: comment),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (currentUser != null)
            _CommentComposer(
              controller: _commentController,
              focusNode: _commentFocus,
              sending: _sending,
              onSend: () => _submitComment(currentUser),
            ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final PostComment comment;

  @override
  Widget build(BuildContext context) {
    final initial = comment.user.fullName.isEmpty
        ? '?'
        : comment.user.fullName.characters.first.toUpperCase();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(initial),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(comment.body),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 3),
                  child: Text(
                    '${comment.likes} likes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  enabled: !sending,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment…',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                tooltip: 'Send comment',
                onPressed: sending ? null : onSend,
                icon: sending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
