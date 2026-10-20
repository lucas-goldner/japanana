import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/app_config.dart';
import 'package:japanana/features/settings/domain/store_catalog.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final purchasesServiceProvider =
    Provider<PurchasesService>((ref) => RevenueCatPurchasesService());

/// Supporter subscription and tip jar purchases.
abstract interface class PurchasesService {
  /// Whether purchases can be offered at all on this build and platform.
  bool get isAvailable;

  Future<StoreCatalog> loadCatalog();

  /// Buys [item]. Returns whether the user is a supporter afterwards, or null
  /// when the purchase was cancelled.
  Future<bool?> purchase(StoreItem item);

  /// Returns whether the user is a supporter after restoring.
  Future<bool> restore();
}

class RevenueCatPurchasesService implements PurchasesService {
  Future<void>? _configuration;

  String get _apiKey => switch (defaultTargetPlatform) {
        TargetPlatform.iOS ||
        TargetPlatform.macOS =>
          AppConfig.revenueCatAppleApiKey,
        TargetPlatform.android => AppConfig.revenueCatGoogleApiKey,
        _ => '',
      };

  @override
  bool get isAvailable => !kIsWeb && _apiKey.isNotEmpty;

  Future<void> _ensureConfigured() =>
      _configuration ??= Purchases.configure(PurchasesConfiguration(_apiKey));

  bool _isSupporter(CustomerInfo info) =>
      info.entitlements.active.containsKey(AppConfig.supporterEntitlement);

  StoreItem _item(Package package, StoreItemKind kind) => StoreItem(
        id: package.identifier,
        kind: kind,
        title: package.storeProduct.title,
        price: package.storeProduct.priceString,
        handle: package,
      );

  @override
  Future<StoreCatalog> loadCatalog() async {
    await _ensureConfigured();
    final offerings = await Purchases.getOfferings();
    final supporter = offerings.getOffering(AppConfig.supporterOffering);
    final tips = [
      ...?offerings.getOffering(AppConfig.tipsOffering)?.availablePackages,
    ]..sort((a, b) => a.storeProduct.price.compareTo(b.storeProduct.price));

    return StoreCatalog(
      subscriptions: [
        if (supporter?.monthly case final monthly?)
          _item(monthly, StoreItemKind.monthly),
        if (supporter?.annual case final annual?)
          _item(annual, StoreItemKind.yearly),
      ],
      tips: [for (final tip in tips) _item(tip, StoreItemKind.tip)],
      isSupporter: _isSupporter(await Purchases.getCustomerInfo()),
    );
  }

  @override
  Future<bool?> purchase(StoreItem item) async {
    await _ensureConfigured();
    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(item.handle! as Package),
      );
      return _isSupporter(result.customerInfo);
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<bool> restore() async {
    await _ensureConfigured();
    return _isSupporter(await Purchases.restorePurchases());
  }
}
