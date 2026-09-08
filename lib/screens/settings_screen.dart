import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dialogs.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await CustomDialogs.confirm(
      context,
      title: 'Log out?',
      message: 'You will need to enter your DummyJSON credentials again.',
      confirmLabel: 'Log out',
    );
    if (!confirmed || !context.mounted) return;

    await context.read<SessionProvider>().signOut();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<ThemeProvider>();
    final user = context.watch<SessionProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: CircleAvatar(
                foregroundImage: user.image.isEmpty
                    ? null
                    : NetworkImage(user.image),
                child: Text(
                  user.firstName.isEmpty
                      ? '?'
                      : user.firstName.characters.first.toUpperCase(),
                ),
              ),
              title: Text(
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('@${user.username}'),
            ),
          const SizedBox(height: 14),
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  subtitle: const Text(
                    'Use a darker theme throughout the app.',
                  ),
                  value: preferences.darkMode,
                  onChanged: preferences.setDarkMode,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text('Show campus activity notifications.'),
                  value: preferences.notificationsEnabled,
                  onChanged: preferences.setNotificationsEnabled,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          CustomButton(
            label: 'Log out',
            icon: Icons.logout,
            backgroundColor: Theme.of(context).colorScheme.error,
            onPressed: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
