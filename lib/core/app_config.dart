// RevenueCat keys are read from --dart-define so they are never committed.
// ignore_for_file: do_not_use_environment

/// External links, store identifiers and keys used by the settings screen.
///
/// Values marked TODO are placeholders and must be replaced before release.
abstract final class AppConfig {
  // TODO(lucas-goldner): Replace the placeholder links before release.
  static const websiteUrl = 'https://example.com/japanana';
  static const xProfileUrl = 'https://x.com/TODO';
  static const privacyPolicyUrl = 'https://example.com/japanana/privacy';
  static const termsOfUseUrl = 'https://example.com/japanana/terms';
  static const otherAppsUrl = 'https://example.com/apps';
  static const supportEmail = 'support@example.com';

  /// Numeric App Store id, used when the native review prompt is unavailable.
  // TODO(lucas-goldner): Set the App Store id once the app is listed.
  static const appStoreId = '';

  /// iCloud container that stores backups. Must match the container enabled
  /// in the iOS and macOS "iCloud" capability.
  static const iCloudContainerId = 'iCloud.com.lucas-goldner.hikou5';

  /// RevenueCat public SDK keys, passed in at build time, e.g.
  /// `flutter run --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx`.
  static const revenueCatAppleApiKey =
      String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
  static const revenueCatGoogleApiKey =
      String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');

  /// RevenueCat entitlement granted by the supporter subscription.
  static const supporterEntitlement = 'supporter';

  /// RevenueCat offering with the monthly and yearly supporter packages.
  static const supporterOffering = 'supporter';

  /// RevenueCat offering with the one-time tip packages.
  static const tipsOffering = 'tips';
}
