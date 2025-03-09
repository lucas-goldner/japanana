import 'package:flutter/material.dart';
import 'package:japanana/features/review_selection/presentation/style/books_theme.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: colorSchemeLight,
  textTheme: textTheme,
  scaffoldBackgroundColor: colorSchemeLight.surface,
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      splashFactory: NoSplash.splashFactory,
      side: WidgetStateProperty.all(
        BorderSide.none,
      ),
    ),
  ),
  extensions: [
    BooksTheme(),
    LinearPercentIndicatorColors(
      backgroundColor: colorSchemeLight.onSurface,
      progressLabelTextColor: colorSchemeLight.onPrimary,
      progressColor: colorSchemeLight.inversePrimary,
    ),
  ],
);

final ThemeData darkTheme = ThemeData(
  colorScheme: colorSchemeDark,
  textTheme: textTheme,
  scaffoldBackgroundColor: colorSchemeDark.surface,
  extensions: [
    BooksTheme.dark(),
    LinearPercentIndicatorColors(
      backgroundColor: colorSchemeLight.surface,
      progressLabelTextColor: colorSchemeLight.primary,
      progressColor: colorSchemeLight.inversePrimary,
    ),
  ],
);

TextTheme _defaultTextTheme = ThemeData().textTheme.apply(
  fontFamily: 'Exlibris',
  fontFamilyFallback: ['NotoSansJP'],
);

TextTheme textTheme = _defaultTextTheme.copyWith(
  bodyLarge: _defaultTextTheme.bodyLarge?.copyWith(
    fontFamily: _defaultTextTheme.notoSansJPFont,
  ),
);

ColorScheme get _defaultColorScheme => ThemeData().colorScheme;

ColorScheme colorSchemeLight = ColorScheme.light(
  primary: const Color(0xff202530),
  onPrimary: _defaultColorScheme.onPrimary,
  secondary: const Color(0xffF7F5FF),
  onSecondary: _defaultColorScheme.onSecondary,
  tertiary: const Color(0xffD05557),
  error: _defaultColorScheme.error,
  onError: _defaultColorScheme.onError,
  surface: const Color(0xffF8D318),
  onSurface: _defaultColorScheme.onSurface,
);

ColorScheme colorSchemeDark = ColorScheme.dark(
  primary: const Color(0xffF8D318),
  onPrimary: _defaultColorScheme.onPrimary,
  secondary: const Color(0xff171002),
  onSecondary: _defaultColorScheme.onSecondary,
  tertiary: const Color(0xff592049),
  error: _defaultColorScheme.error,
  onError: _defaultColorScheme.onError,
  surface: const Color(0xff171002),
  onSurface: _defaultColorScheme.onSurface,
);

extension TextThemeEX on TextTheme {
  String get exlibrisFont => 'Exlibris';
  String get notoSansJPFont => 'NotoSansJP';
}

@immutable
class LinearPercentIndicatorColors
    extends ThemeExtension<LinearPercentIndicatorColors> {
  const LinearPercentIndicatorColors({
    required this.progressLabelTextColor,
    required this.progressColor,
    required this.backgroundColor,
  });

  final Color? progressLabelTextColor;
  final Color? progressColor;
  final Color? backgroundColor;

  @override
  LinearPercentIndicatorColors copyWith({
    Color? progressLabelTextColor,
    Color? progressColor,
    Color? backgroundColor,
  }) =>
      LinearPercentIndicatorColors(
        progressLabelTextColor:
            progressLabelTextColor ?? this.progressLabelTextColor,
        progressColor: progressColor ?? this.progressColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
      );

  @override
  LinearPercentIndicatorColors lerp(
    LinearPercentIndicatorColors? other,
    double t,
  ) {
    if (other is! LinearPercentIndicatorColors) {
      return this;
    }
    return LinearPercentIndicatorColors(
      progressLabelTextColor:
          Color.lerp(progressLabelTextColor, other.progressLabelTextColor, t),
      progressColor: Color.lerp(progressColor, other.progressColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
    );
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'LinearPercentIndicatorColors(progressLabelTextColor: $progressLabelTextColor, progressColor: $progressColor, backgroundColor: $backgroundColor)';
}
