import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current time. Overridden in tests so time based screens render the same
/// on every run.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
