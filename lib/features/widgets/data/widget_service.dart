import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/features/widgets/domain/widget_snapshot.dart';

final widgetServiceProvider =
    Provider<WidgetService>((ref) => PlatformWidgetService());

/// Sends data to the home screen widgets. Only iOS has widgets.
abstract interface class WidgetService {
  bool get isSupported;

  Future<void> update(WidgetSnapshot snapshot);
}

class PlatformWidgetService implements WidgetService {
  static const _channel = MethodChannel('japanana/widgets');

  @override
  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<void> update(WidgetSnapshot snapshot) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('update', snapshot.toJson());
    } on PlatformException catch (error) {
      debugPrint('Widgets not updated: $error');
    }
  }
}
