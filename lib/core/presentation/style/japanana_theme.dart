import 'package:flutter/material.dart';
import 'package:japanana/core/presentation/style/neo_theme.dart';
import 'package:japanana/features/review_selection/presentation/style/books_theme.dart';

final ThemeData lightTheme = buildJapananaTheme(
  colorScheme: colorSchemeLight,
  neoTheme: NeoTheme.light,
  booksTheme: BooksTheme(),
);

final ThemeData darkTheme = buildJapananaTheme(
  colorScheme: colorSchemeDark,
  neoTheme: NeoTheme.dark,
  booksTheme: BooksTheme.dark(),
);

ThemeData buildJapananaTheme({
  required ColorScheme colorScheme,
  required NeoTheme neoTheme,
  required BooksTheme booksTheme,
}) {
  final textTheme = buildTextTheme(colorScheme.brightness);
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: neoTheme.border, width: neoTheme.borderWidth),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? neoTheme.accent
            : Colors.transparent,
      ),
      checkColor: WidgetStateProperty.all(neoTheme.onAccent),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        side: WidgetStateProperty.all(
          BorderSide.none,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.secondary,
      surfaceTintColor: colorScheme.secondary,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(
        bottom: BorderSide(
          color: neoTheme.border,
          width: neoTheme.borderWidth,
        ),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSecondary,
      ),
      titleTextStyle: textTheme.headlineLarge?.copyWith(
        color: colorScheme.onSecondary,
      ),
    ),
    extensions: [
      booksTheme,
      neoTheme,
      LinearPercentIndicatorColors(
        backgroundColor: colorScheme.onSurface,
        progressLabelTextColor: colorScheme.onPrimary,
        progressColor: colorScheme.inversePrimary,
      ),
    ],
  );
}

/// Exlibris text theme whose default colors match [brightness].
TextTheme buildTextTheme(Brightness brightness) {
  final defaultTextTheme = ThemeData(brightness: brightness).textTheme.apply(
    fontFamily: 'Exlibris',
    fontFamilyFallback: ['NotoSansJP'],
  );
  return defaultTextTheme.copyWith(
    bodyLarge: defaultTextTheme.bodyLarge?.copyWith(
      fontFamily: defaultTextTheme.notoSansJPFont,
    ),
  );
}

ColorScheme get _defaultColorScheme => ThemeData().colorScheme;

ColorScheme colorSchemeLight = ColorScheme.light(
  primary: const Color(0xff202530),
  onPrimary: _defaultColorScheme.onPrimary,
  secondary: const Color(0xffF7F5FF),
  onSecondary: const Color(0xff171002),
  tertiary: const Color(0xffD05557),
  error: _defaultColorScheme.error,
  onError: _defaultColorScheme.onError,
  surface: const Color(0xffF8D318),
  onSurface: _defaultColorScheme.onSurface,
);

// "Midnight notebook": navy paper with banana yellow accents.
ColorScheme colorSchemeDark = const ColorScheme.dark(
  primary: Color(0xffF8D318),
  onPrimary: Color(0xff171002),
  primaryContainer: Color(0xffF8D318),
  secondary: Color(0xff1A1E29),
  onSecondary: Color(0xffECE9F7),
  secondaryContainer: Color(0xffF8D318),
  tertiary: Color(0xffD05557),
  surface: Color(0xff232937),
  onSurface: Color(0xffECE9F7),
  surfaceContainerLow: Color(0xff2D3446),
  surfaceContainerHigh: Color(0xff2D3446),
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
