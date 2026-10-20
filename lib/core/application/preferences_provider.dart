import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The loaded [SharedPreferences] instance, provided once the app started.
final preferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('preferencesProvider must be overridden');
});
