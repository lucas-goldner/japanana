import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final service = ref.watch(appIconServiceProvider);
    if (!await service.isSupported()) return null;
    return AppIcon.fromIosName(await service.current());
  }

  /// Switches to [icon]. Throws when the system refused.
  Future<void> select(AppIcon icon) async {
    await ref.read(appIconServiceProvider).set(icon.iosName);
    state = AsyncData(icon);
  }
}
