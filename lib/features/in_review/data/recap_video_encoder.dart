import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recapVideoEncoderProvider = Provider<RecapVideoEncoder>(
  (ref) => PlatformRecapVideoEncoder(),
);

/// Encodes rendered frames into an H.264 MP4 file.
abstract interface class RecapVideoEncoder {
  /// Whether this platform can encode video. Elsewhere the recap is shared
  /// as an image.
  bool get isSupported;

  Future<void> start({
    required String path,
    required int width,
    required int height,
    required int fps,
  });

  /// Appends one frame of RGBA pixels, `width * height * 4` bytes.
  Future<void> addFrame(Uint8List rgba);

  /// Finishes the file and returns its path.
  Future<String> finish();
}

/// Encoder written in the iOS and macOS runners with AVFoundation.
class PlatformRecapVideoEncoder implements RecapVideoEncoder {
  static const _channel = MethodChannel('japanana/recap_video');

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  Future<void> start({
    required String path,
    required int width,
    required int height,
    required int fps,
  }) => _channel.invokeMethod('start', {
    'path': path,
    'width': width,
    'height': height,
    'fps': fps,
  });

  @override
  Future<void> addFrame(Uint8List rgba) =>
      _channel.invokeMethod('addFrame', {'rgba': rgba});

  @override
  Future<String> finish() async =>
      (await _channel.invokeMethod<String>('finish'))!;
}
