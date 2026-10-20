import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/features/settings/data/purchases_service.dart';
import 'package:japanana/features/settings/domain/store_catalog.dart';

/// Thrown when purchases aren't set up for this build or platform.
class StoreUnavailableException implements Exception {
  const StoreUnavailableException();
}

final storeProvider = AsyncNotifierProvider<StoreNotifier, StoreCatalog>(
  StoreNotifier.new,
  // An unconfigured or unreachable store is reported in the sheet instead of
  // being retried in the background.
  retry: (_, _) => null,
);

class StoreNotifier extends AsyncNotifier<StoreCatalog> {
  PurchasesService get _service => ref.read(purchasesServiceProvider);

  @override
  Future<StoreCatalog> build() async {
    final service = ref.watch(purchasesServiceProvider);
    if (!service.isAvailable) {
      throw const StoreUnavailableException();
    }
    return service.loadCatalog();
  }

  /// Buys [item]. Returns false when the purchase was cancelled.
  Future<bool> purchase(StoreItem item) async {
    final isSupporter = await _service.purchase(item);
    if (isSupporter == null) return false;
    _updateSupporter(isSupporter: isSupporter);
    return true;
  }

  Future<void> restore() async {
    _updateSupporter(isSupporter: await _service.restore());
  }

  void _updateSupporter({required bool isSupporter}) {
    if (state.value case final catalog?) {
      state = AsyncData(catalog.copyWith(isSupporter: isSupporter));
    }
  }
}
