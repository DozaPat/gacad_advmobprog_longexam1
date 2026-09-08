import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = context.watch<ThemeProvider>().notificationsEnabled;
    if (!enabled) {
      return const _EmptyNotifications(
        icon: Icons.notifications_off_outlined,
        title: 'Notifications are paused',
        message: 'Turn them back on from Settings whenever you are ready.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _notifications.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 80),
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: item.color.withValues(alpha: 0.14),
            foregroundColor: item.color,
            child: Icon(item.icon),
          ),
          title: Text(item.message),
          subtitle: Text(item.time),
          trailing: index == 0
              ? const CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFF1877F2),
                )
              : null,
        );
      },
    );
  }
}

class _NotificationItem {
  const _NotificationItem(this.icon, this.color, this.message, this.time);

  final IconData icon;
  final Color color;
  final String message;
  final String time;
}

const _notifications = [
  _NotificationItem(
    Icons.thumb_up,
    Color(0xFF1877F2),
    'A campus member liked your post.',
    'Just now',
  ),
  _NotificationItem(
    Icons.mode_comment,
    Color(0xFF42B72A),
    'Someone commented on a conversation you follow.',
    '15 minutes ago',
  ),
  _NotificationItem(
    Icons.people,
    Color(0xFFF5533D),
    'New people joined your campus community.',
    'Yesterday',
  ),
];

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
