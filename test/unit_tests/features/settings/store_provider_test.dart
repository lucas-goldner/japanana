import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/features/settings/application/store_provider.dart';
import 'package:japanana/features/settings/data/purchases_service.dart';

import '../../../golden/golden_fakes.dart';

ProviderContainer _container(PurchasesService service) {
  final container = ProviderContainer(
    overrides: [purchasesServiceProvider.overrideWithValue(service)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('reports the store as unavailable without RevenueCat keys', () async {
    final container = _container(FakePurchasesService(isAvailable: false));

    await expectLater(
      container.read(storeProvider.future),
      throwsA(isA<StoreUnavailableException>()),
    );
  });

  test('buying the subscription makes the user a supporter', () async {
    final container = _container(FakePurchasesService());
    final catalog = await container.read(storeProvider.future);
    expect(catalog.isSupporter, isFalse);

    await container
        .read(storeProvider.notifier)
        .purchase(catalog.subscriptions.first);

    expect(container.read(storeProvider).value?.isSupporter, isTrue);
  });

  test('a tip does not make the user a supporter', () async {
    final service = FakePurchasesService();
    final container = _container(service);
    final catalog = await container.read(storeProvider.future);

    final purchased =
        await container.read(storeProvider.notifier).purchase(catalog.tips[1]);

    expect(purchased, isTrue);
    expect(service.purchased.single.id, 'tip_medium');
    expect(container.read(storeProvider).value?.isSupporter, isFalse);
  });
}
