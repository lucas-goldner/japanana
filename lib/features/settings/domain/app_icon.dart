import 'package:flutter/widgets.dart';
import 'package:japanana/core/extensions.dart';

/// Home screen icons of the app. [iosName] is the alternate icon set in
/// `ios/Runner/Assets.xcassets`, null for the primary icon.
enum AppIcon {
  sparkle(null, 'sparkle'),
  focusLines('AppIcon-FocusLines', 'focus_lines'),
  don('AppIcon-Don', 'don'),
  talk('AppIcon-Talk', 'talk'),
  sticker('AppIcon-Sticker', 'sticker'),
  sensei('AppIcon-Sensei', 'sensei');

  const AppIcon(this.iosName, this._preview);

  final String? iosName;
  final String _preview;

  String get preview => 'assets/images/app_icons/$_preview.png';

  static AppIcon fromIosName(String? name) =>
      values.firstWhere((icon) => icon.iosName == name, orElse: () => sparkle);

  String label(BuildContext context) => switch (this) {
        AppIcon.sparkle => context.l10n.appIconSparkle,
        AppIcon.focusLines => context.l10n.appIconFocusLines,
        AppIcon.don => context.l10n.appIconDon,
        AppIcon.talk => context.l10n.appIconTalk,
        AppIcon.sticker => context.l10n.appIconSticker,
        AppIcon.sensei => context.l10n.appIconSensei,
      };
}
