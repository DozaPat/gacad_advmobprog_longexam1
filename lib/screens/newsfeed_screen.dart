import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/post_card.dart';
import 'detail_screen.dart';

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  final _postService = PostService();
  final _userService = UserService();
  late Future<_FeedData> _feed;

  @override
  void initState() {
    super.initState();
    _feed = _loadFeed();
  }

  Future<_FeedData> _loadFeed() async {
    final results = await Future.wait<Object>([
      _postService.getPosts(limit: 30),
      _userService.getUsers(),
    ]);
    return _FeedData(
      posts: results[0] as List<Post>,
      users: results[1] as Map<int, User>,
    );
  }

  Future<void> _refresh() async {
    final next = _loadFeed();
    setState(() => _feed = next);
    await next;
  }

  void _openPost(Post post, User? author) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DetailScreen(post: post, author: author),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FeedData>(
      future: _feed,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _FeedError(onRetry: _refresh);
        }

        final data = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.posts.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _FeedHeader(users: data.users.values.take(10).toList());
              }
              final post = data.posts[index - 1];
              final author = data.users[post.userId];
              return PostCard(
                post: post,
                author: author,
                onCommentTap: () => _openPost(post, author),
              );
            },
          ),
        );
      },
    );
  }
}

class _FeedData {
  const _FeedData({required this.posts, required this.users});

  final List<Post> posts;
  final Map<int, User> users;
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.person),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text("What's on your mind?"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (users.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CarouselSlider.builder(
                itemCount: users.length,
                options: CarouselOptions(
                  height: 170,
                  viewportFraction: 0.34,
                  padEnds: false,
                  enableInfiniteScroll: users.length > 3,
                ),
                itemBuilder: (context, index, pageIndex) {
                  return _StoryCard(user: users[index]);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        image: user.image.isEmpty
            ? null
            : DecorationImage(
                image: CachedNetworkImageProvider(user.image),
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Color(0x55000000),
                  BlendMode.darken,
                ),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: CircleAvatar(
                radius: 17,
                foregroundImage: user.image.isEmpty
                    ? null
                    : CachedNetworkImageProvider(user.image),
                child: Text(user.firstName.characters.first),
              ),
            ),
            const Spacer(),
            Text(
              user.fullName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52),
            const SizedBox(height: 14),
            const Text(
              'The news feed could not be loaded.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
