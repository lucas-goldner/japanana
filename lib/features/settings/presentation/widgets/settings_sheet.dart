import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/settings/domain/setting_type.dart';
import 'package:japanana/features/settings/presentation/widgets/sheets/changelog_sheet.dart';
import 'package:japanana/features/settings/presentation/widgets/sheets/data_sheets.dart';
import 'package:japanana/features/settings/presentation/widgets/sheets/preference_sheets.dart';
import 'package:japanana/features/settings/presentation/widgets/sheets/store_sheets.dart';

/// Largest share of the screen height a settings sheet may cover.
const _kMaxSheetHeightFactor = 0.85;

class SettingsModal extends StatelessWidget {
  const SettingsModal({
    required this.settingType,
    super.key,
  });

  final SettingType settingType;

  static Future<void> show({
    required BuildContext context,
    required SettingType settingType,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsModal(settingType: settingType),
    );
  }

  Widget _content() => switch (settingType) {
        SettingType.language => const LanguageSheet(),
        SettingType.theme => const ThemeSheet(),
        SettingType.notifications => const NotificationsSheet(),
        SettingType.reminder => const ReminderSheet(),
        SettingType.resetProgress => const ResetProgressSheet(),
        SettingType.exportSyncData => const ExportSyncSheet(),
        SettingType.subscription => const SubscriptionSheet(),
        SettingType.donation => const DonationSheet(),
        SettingType.seeChangelog => const ChangelogSheet(),
        // External settings open a link instead of a sheet.
        _ => const SizedBox.shrink(),
      };

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * _kMaxSheetHeightFactor,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: context.neo.border,
                width: context.neo.borderWidth,
              ),
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.neo.radius * 2),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.neo.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Hero(
                            tag: settingType,
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: context.neo.decoration(
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                settingType.icon,
                                color: context.neo.onCard,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          settingType.label(context),
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _content(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
