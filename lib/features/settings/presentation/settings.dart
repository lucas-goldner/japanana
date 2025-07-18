import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopScope(
        onPopInvokedWithResult: (didPop, result) {
          // Allow normal back navigation since we're using page transitions
        },
        child: Stack(
          children: [
            const NoteBackground(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  'Settings',
                  style: context.textTheme.headlineSmall,
                ),
                backgroundColor: context.colorScheme.secondary,
                surfaceTintColor: context.colorScheme.secondary,
                elevation: 4,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'App Settings',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SettingsItem(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'Change app language',
                      onTap: () {
                        // TODO(dev): Implement language selection
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.dark_mode,
                      title: 'Theme',
                      subtitle: 'Light or dark theme',
                      onTap: () {
                        // TODO(dev): Implement theme selection
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        // TODO(dev): Implement notification settings
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Study Settings',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SettingsItem(
                      icon: Icons.timer,
                      title: 'Session Timer',
                      subtitle: 'Set study session duration',
                      onTap: () {
                        // TODO(dev): Implement session timer settings
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.refresh,
                      title: 'Reset Progress',
                      subtitle: 'Clear all study progress',
                      onTap: () {
                        // TODO(dev): Implement reset progress
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(
            icon,
            color: context.colorScheme.primary,
            size: 28,
          ),
          title: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: context.colorScheme.primary.withValues(alpha: 0.5),
            size: 18,
          ),
          onTap: onTap,
        ),
      );
}
