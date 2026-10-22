import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:japanana/core/app_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final externalActionsProvider =
    Provider<ExternalActions>((ref) => DeviceExternalActions());

/// Settings actions that leave the app: links, email and store reviews.
abstract interface class ExternalActions {
  /// Opens [url]. Legal pages open in an in-app browser view.
  /// Returns false when nothing could open it.
  Future<bool> openUrl(String url, {bool inApp = false});

  /// Opens an email draft to the support address.
  Future<bool> sendFeedback({required String subject, required String body});

  /// Shows the native rating prompt, or the store listing as a fallback.
  Future<void> rateApp();

  /// Asks the system to show its rating prompt. The system decides whether
  /// it actually appears, so nothing opens when it doesn't.
  Future<void> requestReview();

  /// Opens the share sheet with [text].
  Future<void> shareText(String text, {Rect? shareOrigin});

  /// Opens the share sheet with the file at [path].
  Future<void> shareFile(
    String path, {
    required String mimeType,
    String? text,
    Rect? shareOrigin,
  });
}

class DeviceExternalActions implements ExternalActions {
  @override
  Future<bool> openUrl(String url, {bool inApp = false}) => launchUrl(
        Uri.parse(url),
        mode: inApp
            ? LaunchMode.inAppBrowserView
            : LaunchMode.externalApplication,
      );

  @override
  Future<bool> sendFeedback({
    required String subject,
    required String body,
  }) async {
    final info = await PackageInfo.fromPlatform();
    final details = 'Japanana ${info.version} (${info.buildNumber}), '
        '${defaultTargetPlatform.name}';
    return launchUrl(
      Uri(
        scheme: 'mailto',
        path: AppConfig.supportEmail,
        // Uri encodes spaces in queryParameters as "+", which mail apps show
        // literally, so build the query by hand.
        query: 'subject=${Uri.encodeComponent(subject)}'
            '&body=${Uri.encodeComponent('$body\n\n\n---\n$details')}',
      ),
    );
  }

  @override
  Future<void> rateApp() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    } else {
      await review.openStoreListing(appStoreId: AppConfig.appStoreId);
    }
  }

  @override
  Future<void> requestReview() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    }
  }

  @override
  Future<void> shareText(String text, {Rect? shareOrigin}) =>
      SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: shareOrigin),
      );

  @override
  Future<void> shareFile(
    String path, {
    required String mimeType,
    String? text,
    Rect? shareOrigin,
  }) =>
      SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: mimeType)],
          text: text,
          sharePositionOrigin: shareOrigin,
        ),
      );
}
