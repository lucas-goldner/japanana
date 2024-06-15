import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  appBarTheme: AppBarTheme(
    backgroundColor: colorSchemeLight.inversePrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all(colorSchemeLight.primaryContainer),
    foregroundColor:
        WidgetStateProperty.all(colorSchemeLight.onPrimaryContainer),
  )),
  cardTheme: CardTheme(
    color: colorSchemeLight.surfaceContainerHighest,
  ),
  colorScheme: colorSchemeLight,
  useMaterial3: true,
  listTileTheme: ListTileThemeData(
    minVerticalPadding: 16,
  ),
  extensions: [
    LinearPercentIndicatorColors(
      backgroundColor: colorSchemeLight.onSurface,
      progressLabelTextColor: colorSchemeLight.onPrimary,
      progressColor: colorSchemeLight.inversePrimary,
    )
  ],
);

final ThemeData darkTheme = ThemeData(
  appBarTheme: AppBarTheme(
    backgroundColor: colorSchemeDark.inversePrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
  ),
  cardTheme: CardTheme(
    color: colorSchemeDark.onPrimaryContainer,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
    backgroundColor:
        WidgetStateProperty.all(colorSchemeDark.onPrimaryContainer),
    foregroundColor: WidgetStateProperty.all(colorSchemeDark.primary),
  )),
  colorScheme: colorSchemeDark,
  useMaterial3: true,
  listTileTheme: ListTileThemeData(
    minVerticalPadding: 16,
  ),
  extensions: [
    LinearPercentIndicatorColors(
      backgroundColor: colorSchemeLight.surface,
      progressLabelTextColor: colorSchemeLight.primary,
      progressColor: colorSchemeLight.inversePrimary,
    )
  ],
);

const ColorScheme colorSchemeLight = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xff171002),
  onPrimary: Color(0xffFFFCF0),
  primaryContainer: Color(0xffF8D318),
  onPrimaryContainer: Color(0xff171002),
  secondary: Color(0xffF9DA3E),
  onSecondary: Color(0xff171002),
  secondaryContainer: Color(0xffFAE36B),
  onSecondaryContainer: Color(0xff171002),
  tertiary: Color(0xffFAE36B),
  onTertiary: Color(0xff171002),
  tertiaryContainer: Color(0xffF8D318),
  onTertiaryContainer: Color(0xff171002),
  error: Color(0xffBA1A1A),
  onError: Color(0xffFFFFFF),
  errorContainer: Color(0xffFFDAD6),
  onErrorContainer: Color(0xff410002),
  surface: Color(0xffF9DA3E),
  onSurface: Color(0xff171002),
  surfaceContainerHighest: Color(0xffF8D318),
  onSurfaceVariant: Color(0xff171002),
  outline: Color(0xff171002),
  outlineVariant: Color(0xff171002),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xff171002),
  onInverseSurface: Color(0xffFFFCF0),
  inversePrimary: Color(0xffC6A300),
  surfaceTint: Color(0xff171002),
);

const ColorScheme colorSchemeDark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffFAE36B),
  onPrimary: Color(0xff171002),
  primaryContainer: Color(0xffF8D318),
  onPrimaryContainer: Color(0xff171002),
  secondary: Color(0xffF9DA3E),
  onSecondary: Color(0xff171002),
  secondaryContainer: Color(0xffFAE36B),
  onSecondaryContainer: Color(0xff171002),
  tertiary: Color(0xffFAE36B),
  onTertiary: Color(0xff171002),
  tertiaryContainer: Color(0xffF8D318),
  onTertiaryContainer: Color(0xff171002),
  error: Color(0xffFFB4AB),
  onError: Color(0xff690005),
  errorContainer: Color(0xff93000A),
  onErrorContainer: Color(0xffFFB4AB),
  surface: Color(0xff1A1A1A),
  onSurface: Color(0xffFAE36B),
  surfaceContainerHighest: Color(0xff2E2E2E),
  onSurfaceVariant: Color(0xffFAE36B),
  outline: Color(0xffFAE36B),
  outlineVariant: Color(0xffF8D318),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xffDCE2D8),
  onInverseSurface: Color(0xff2F312D),
  inversePrimary: Color(0xffDAA520),
  surfaceTint: Color(0xffFAE36B),
);

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
          backgroundColor: backgroundColor ?? this.backgroundColor);

  @override
  LinearPercentIndicatorColors lerp(
      LinearPercentIndicatorColors? other, double t) {
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
      'LinearPercentIndicatorColors(progressLabelTextColor: $progressLabelTextColor, progressColor: $progressColor, backgroundColor: $backgroundColor)';
}
