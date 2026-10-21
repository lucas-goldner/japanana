import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Share of pixels a golden may differ by on macOS. The goldens are rendered
/// on Linux, and macOS anti-aliases text slightly differently (about 1-2%).
const _kMacOSGoldenTolerance = 0.03;

/// Runs before every test file in this folder.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final comparator = goldenFileComparator;
  if (Platform.isMacOS && comparator is LocalFileComparator) {
    goldenFileComparator = TolerantGoldenFileComparator(
      // LocalFileComparator only keeps the folder of the test file.
      comparator.basedir.resolve('golden_test.dart'),
      tolerance: _kMacOSGoldenTolerance,
    );
  }
  await testMain();
}

/// [LocalFileComparator] that passes when at most [tolerance] of the pixels
/// differ.
class TolerantGoldenFileComparator extends LocalFileComparator {
  TolerantGoldenFileComparator(super.testFile, {required this.tolerance});

  /// Allowed share of differing pixels, from 0 to 1.
  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    try {
      if (result.passed || result.diffPercent <= tolerance) {
        return true;
      }
      throw FlutterError(await generateFailureOutput(result, golden, basedir));
    } finally {
      result.dispose();
    }
  }
}
