import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appIconServiceProvider =
    Provider<AppIconService>((ref) => PlatformAppIconService());

/// Switches the home screen icon. Only iOS supports alternate icons.
abstract interface class AppIconService {
  Future<bool> isSupported();

  /// Name of the alternate icon in use, or null for the primary icon.
  Future<String?> current();

  /// Switches to the alternate icon [name], or back to the primary with null.
  Future<void> set(String? name);
}

class PlatformAppIconService implements AppIconService {
  static const _channel = MethodChannel('japanana/app_icon');

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<bool> isSupported() async =>
      _isIOS && (await _channel.invokeMethod<bool>('isSupported') ?? false);

  @override
  Future<String?> current() => _channel.invokeMethod<String>('current');

  @override
  Future<void> set(String? name) => _channel.invokeMethod('set', name);
}
