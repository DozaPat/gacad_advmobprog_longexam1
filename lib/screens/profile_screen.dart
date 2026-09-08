import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../providers/session_provider.dart';
import '../services/post_service.dart';
import '../widgets/custom_info.dart';
import '../widgets/post_card.dart';
import 'detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _postService = PostService();
  Future<List<Post>>? _posts;
  int? _loadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<SessionProvider>().user?.id;
    if (userId != null && userId != _loadedUserId) {
      _loadedUserId = userId;
      _posts = _postService.getPostsByUser(userId);
    }
  }

  Future<void> _refresh(User user) async {
    final next = _postService.getPostsByUser(user.id);
    setState(() => _posts = next);
    await next;
  }

  void _openPost(Post post, User user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DetailScreen(post: post, author: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;
    if (user == null || _posts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<Post>>(
      future: _posts,
      builder: (context, snapshot) {
        final posts = snapshot.data ?? const <Post>[];
        return RefreshIndicator(
          onRefresh: () => _refresh(user),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: posts.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _ProfileHeader(
                  user: user,
                  postCount: posts.length,
                  loading: snapshot.connectionState == ConnectionState.waiting,
                  error: snapshot.hasError,
                  onRetry: () => _refresh(user),
                );
              }
              final post = posts[index - 1];
              return PostCard(
                post: post,
                author: user,
                onCommentTap: () => _openPost(post, user),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.postCount,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final User user;
  final int postCount;
  final bool loading;
  final bool error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1877F2), Color(0xFF65A7FF)],
              ),
            ),
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, 48),
              child: CircleAvatar(
                radius: 54,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: CircleAvatar(
                  radius: 50,
                  foregroundImage: user.image.isEmpty
                      ? null
                      : CachedNetworkImageProvider(user.image),
                  child: Text(
                    user.firstName.isEmpty
                        ? '?'
                        : user.firstName.characters.first.toUpperCase(),
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 58),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            '@${user.username}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                CustomInfo(icon: Icons.email_outlined, label: user.email),
                if (user.phone.isNotEmpty)
                  CustomInfo(icon: Icons.phone_outlined, label: user.phone),
                if (user.university.isNotEmpty)
                  CustomInfo(
                    icon: Icons.school_outlined,
                    label: user.university,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _Stat(value: '$postCount', label: 'Posts'),
                ),
                const Expanded(
                  child: _Stat(value: '128', label: 'Friends'),
                ),
                const Expanded(
                  child: _Stat(value: '24', label: 'Following'),
                ),
              ],
            ),
          ),
          if (loading) const LinearProgressIndicator(minHeight: 2),
          if (error)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Retry profile posts'),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
