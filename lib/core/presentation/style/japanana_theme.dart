import 'package:flutter/material.dart';
import 'package:japanana/features/review_selection/presentation/style/books_theme.dart';

final ThemeData lightTheme = buildJapananaTheme(
  colorScheme: colorSchemeLight,
  appColors: AppColors.light,
  booksTheme: BooksTheme(),
);

final ThemeData darkTheme = buildJapananaTheme(
  colorScheme: colorSchemeDark,
  appColors: AppColors.dark,
  booksTheme: BooksTheme.dark(),
);

ThemeData buildJapananaTheme({
  required ColorScheme colorScheme,
  required AppColors appColors,
  required BooksTheme booksTheme,
}) {
  final textTheme = buildTextTheme(colorScheme.brightness);
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
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
      iconTheme: IconThemeData(
        color: colorScheme.onSecondary,
      ),
      titleTextStyle: textTheme.headlineLarge?.copyWith(
        color: colorScheme.onSecondary,
      ),
    ),
    extensions: [
      booksTheme,
      appColors,
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

ColorScheme colorSchemeDark = ColorScheme.dark(
  primary: const Color(0xffF8D318),
  onPrimary: _defaultColorScheme.onPrimary,
  secondary: const Color(0xff171002),
  onSecondary: const Color(0xffF7F5FF),
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

/// App specific colors that aren't covered by the [ColorScheme].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.scribbleBorder,
    required this.scribbleShadow,
    required this.correct,
    required this.wrong,
    required this.bookshelfTint,
  });

  static const light = AppColors(
    scribbleBorder: Colors.black,
    scribbleShadow: Colors.black26,
    correct: Colors.green,
    wrong: Colors.red,
    bookshelfTint: Color(0xFFD05557),
  );

  static const dark = AppColors(
    scribbleBorder: Colors.white,
    scribbleShadow: Colors.white24,
    correct: Colors.greenAccent,
    wrong: Colors.redAccent,
    bookshelfTint: Color(0xFF592049),
  );

  /// Border of hand drawn buttons and the default answer options.
  final Color scribbleBorder;

  /// Offset "shadow" stroke drawn below hand drawn buttons.
  final Color scribbleShadow;

  /// Highlights a correct answer or a session that can be continued.
  final Color correct;

  /// Highlights a wrong answer.
  final Color wrong;

  /// Tint multiplied onto the noisy bookshelf texture.
  final Color bookshelfTint;

  @override
  AppColors copyWith({
    Color? scribbleBorder,
    Color? scribbleShadow,
    Color? correct,
    Color? wrong,
    Color? bookshelfTint,
  }) =>
      AppColors(
        scribbleBorder: scribbleBorder ?? this.scribbleBorder,
        scribbleShadow: scribbleShadow ?? this.scribbleShadow,
        correct: correct ?? this.correct,
        wrong: wrong ?? this.wrong,
        bookshelfTint: bookshelfTint ?? this.bookshelfTint,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      scribbleBorder: Color.lerp(scribbleBorder, other.scribbleBorder, t)!,
      scribbleShadow: Color.lerp(scribbleShadow, other.scribbleShadow, t)!,
      correct: Color.lerp(correct, other.correct, t)!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      bookshelfTint: Color.lerp(bookshelfTint, other.bookshelfTint, t)!,
    );
  }
}
