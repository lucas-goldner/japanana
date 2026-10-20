import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of randomness for shuffling review content.
///
/// Overridden with a seeded [Random] in tests so screens render
/// deterministically.
final randomProvider = Provider<Random>((ref) => Random());
