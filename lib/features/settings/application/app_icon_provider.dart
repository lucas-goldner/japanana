import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/features/settings/application/store_provider.dart';
import 'package:japanana/features/settings/data/app_icon_service.dart';
import 'package:japanana/features/settings/domain/app_icon.dart';

/// The home screen icon in use, or null where icons can't be switched.
final appIconProvider = AsyncNotifierProvider<AppIconNotifier, AppIcon?>(
  AppIconNotifier.new,
  retry: (_, _) => null,
);

class AppIconNotifier extends AsyncNotifier<AppIcon?> {
  @override
  Future<AppIcon?> build() async {
    // A lapsed supporter goes back to the free icon.
    ref.listen(storeProvider, (_, next) {
      final catalog = next.value;
      if (catalog != null &&
          !catalog.isSupporter &&
          (state.value?.isPerk ?? false)) {
        select(AppIcon.sparkle);
      }
    });
    final service = ref.watch(appIconServiceProvider);
    if (!await service.isSupported()) return null;
    final icon = AppIcon.fromIosName(await service.current());
    final catalog = ref.read(storeProvider).value;
    if (catalog != null && !catalog.isSupporter && icon.isPerk) {
      await service.set(null);
      return AppIcon.sparkle;
    }
    return icon;
  }

  /// Switches to [icon]. Throws when the system refused.
  Future<void> select(AppIcon icon) async {
    await ref.read(appIconServiceProvider).set(icon.iosName);
    state = AsyncData(icon);
  }
}
