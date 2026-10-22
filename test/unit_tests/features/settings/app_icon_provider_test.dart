import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/features/settings/application/app_icon_provider.dart';
import 'package:japanana/features/settings/application/store_provider.dart';
import 'package:japanana/features/settings/data/app_icon_service.dart';
import 'package:japanana/features/settings/data/purchases_service.dart';
import 'package:japanana/features/settings/domain/app_icon.dart';

import '../../../golden/golden_fakes.dart';

void main() {
  ProviderContainer container(
    FakeAppIconService service, {
    bool isSupporter = true,
  }) {
    final container = ProviderContainer(
      overrides: [
        appIconServiceProvider.overrideWithValue(service),
        purchasesServiceProvider.overrideWithValue(
          FakePurchasesService(isSupporter: isSupporter),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('is null where icons cannot be switched', () async {
    final icons = container(FakeAppIconService(supported: false));
    expect(await icons.read(appIconProvider.future), isNull);
  });

  test('reads the alternate icon in use', () async {
    final icons = container(FakeAppIconService(name: 'AppIcon-Don'));
    expect(await icons.read(appIconProvider.future), AppIcon.don);
  });

  test('selecting switches the system icon', () async {
    final service = FakeAppIconService();
    final icons = container(service);
    expect(await icons.read(appIconProvider.future), AppIcon.sparkle);

    await icons.read(appIconProvider.notifier).select(AppIcon.sensei);
    expect(service.name, 'AppIcon-Sensei');
    expect(icons.read(appIconProvider).value, AppIcon.sensei);

    await icons.read(appIconProvider.notifier).select(AppIcon.sparkle);
    expect(service.name, isNull);
  });

  test('a lapsed supporter goes back to the free icon', () async {
    final service = FakeAppIconService(name: 'AppIcon-Don');
    final icons = container(service, isSupporter: false);
    final subscription = icons.listen(appIconProvider, (_, _) {});
    addTearDown(subscription.close);
    await icons.read(appIconProvider.future);
    await icons.read(storeProvider.future);
    await Future<void>.delayed(Duration.zero);
    expect(service.name, isNull);
    expect(icons.read(appIconProvider).value, AppIcon.sparkle);
  });

  test('a lapsed supporter is reset when the store loads first', () async {
    final service = FakeAppIconService(name: 'AppIcon-Don');
    final icons = container(service, isSupporter: false);
    await icons.read(storeProvider.future);
    expect(await icons.read(appIconProvider.future), AppIcon.sparkle);
    expect(service.name, isNull);
  });

  test('every alternate icon has an icon set name', () {
    for (final icon in AppIcon.values.skip(1)) {
      expect(icon.iosName, startsWith('AppIcon-'));
    }
  });
}
