/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $TestGen {
  const $TestGen();

  $TestAssetsGen get assets => const $TestAssetsGen();
}

class $AssetsDataGen {
  const $AssetsDataGen();

  /// File path: assets/data/Japanese Grammar Examples.md
  String get japaneseGrammarExamples =>
      'assets/data/Japanese Grammar Examples.md';

  /// List of all assets
  List<String> get values => [japaneseGrammarExamples];
}

class $AssetsL10nGen {
  const $AssetsL10nGen();

  /// File path: assets/l10n/app_de.arb
  String get appDe => 'assets/l10n/app_de.arb';

  /// File path: assets/l10n/app_en.arb
  String get appEn => 'assets/l10n/app_en.arb';

  /// File path: assets/l10n/app_ja.arb
  String get appJa => 'assets/l10n/app_ja.arb';

  /// List of all assets
  List<String> get values => [appDe, appEn, appJa];
}

class $TestAssetsGen {
  const $TestAssetsGen();

  $TestAssetsDataGen get data => const $TestAssetsDataGen();
}

class $TestAssetsDataGen {
  const $TestAssetsDataGen();

  /// File path: test/assets/data/Japanese Grammar Examples TestData.md
  String get japaneseGrammarExamplesTestData =>
      'test/assets/data/Japanese Grammar Examples TestData.md';

  /// List of all assets
  List<String> get values => [japaneseGrammarExamplesTestData];
}

class Assets {
  Assets._();

  static const $AssetsDataGen data = $AssetsDataGen();
  static const $AssetsL10nGen l10n = $AssetsL10nGen();
  static const $TestGen test = $TestGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
