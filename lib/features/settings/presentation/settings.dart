import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/widget_canvas.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = WidgetCanvasController([
      // App Settings - Left side
      WidgetCanvasChild(
        key: UniqueKey(),
        offset: const Offset(-200, -150),
        size: const Size(120, 140),
        child: _SettingCanvasItem(
          icon: Icons.language,
          title: 'Language',
          onTap: () {
            // TODO(dev): Implement language selection
          },
        ),
      ),
      WidgetCanvasChild(
        key: UniqueKey(),
        offset: const Offset(-200, 0),
        size: const Size(120, 140),
        child: _SettingCanvasItem(
          icon: Icons.dark_mode,
          title: 'Theme',
          onTap: () {
            // TODO(dev): Implement theme selection
          },
        ),
      ),
      WidgetCanvasChild(
        key: UniqueKey(),
        offset: const Offset(-200, 150),
        size: const Size(120, 140),
        child: _SettingCanvasItem(
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () {
            // TODO(dev): Implement notification settings
          },
        ),
      ),
      // Study Settings - Right side
      WidgetCanvasChild(
        key: UniqueKey(),
        offset: const Offset(80, -150),
        size: const Size(120, 140),
        child: _SettingCanvasItem(
          icon: Icons.timer,
          title: 'Session Timer',
          onTap: () {
            // TODO(dev): Implement session timer settings
          },
        ),
      ),
      WidgetCanvasChild(
        key: UniqueKey(),
        offset: const Offset(80, 0),
        size: const Size(120, 140),
        child: _SettingCanvasItem(
          icon: Icons.refresh,
          title: 'Reset Progress',
          onTap: () {
            // TODO(dev): Implement reset progress
          },
        ),
      ),
      WidgetCanvasChild(
        key: UniqueKey(),
        offset: const Offset(80, 150),
        size: const Size(120, 140),
        child: _SettingCanvasItem(
          icon: Icons.analytics,
          title: 'Statistics',
          onTap: () {
            // TODO(dev): Navigate to statistics
          },
        ),
      ),
    ]);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Allow normal back navigation since we're using page transitions
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Settings',
            style: context.textTheme.headlineSmall,
          ),
          backgroundColor: context.colorScheme.secondary,
          surfaceTintColor: context.colorScheme.secondary,
          elevation: 4,
        ),
        body: WidgetCanvas(controller: controller),
      ),
    );
  }
}

class _SettingCanvasItem extends StatelessWidget {
  const _SettingCanvasItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 120,
          height: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: context.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  icon,
                  color: context.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}
