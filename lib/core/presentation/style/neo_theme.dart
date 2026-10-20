import 'package:flutter/material.dart';

/// Tokens for the neubrutalism style: thick outlines, flat fills and hard
/// offset shadows without blur.
@immutable
class NeoTheme extends ThemeExtension<NeoTheme> {
  const NeoTheme({
    required this.border,
    required this.shadow,
    required this.accentShadow,
    required this.card,
    required this.onCard,
    required this.accent,
    required this.onAccent,
    required this.correctFill,
    required this.wrongFill,
    required this.onFeedback,
    required this.grid,
    required this.bookshelf,
    this.borderWidth = 3,
    this.shadowOffset = const Offset(5, 5),
    this.radius = 14,
  });

  static const light = NeoTheme(
    border: Color(0xff000000),
    shadow: Color(0xff000000),
    accentShadow: Color(0xff000000),
    card: Color(0xffFFFFFF),
    onCard: Color(0xff000000),
    accent: Color(0xffF8D318),
    onAccent: Color(0xff000000),
    correctFill: Color(0xff7BD88F),
    wrongFill: Color(0xffFF8A8A),
    onFeedback: Color(0xff000000),
    grid: Color(0x1A000000),
    bookshelf: Color(0xffD05557),
  );

  static const dark = NeoTheme(
    border: Color(0xffECE9F7),
    shadow: Color(0xffF8D318),
    accentShadow: Color(0xffECE9F7),
    card: Color(0xff2D3446),
    onCard: Color(0xffECE9F7),
    accent: Color(0xffF8D318),
    onAccent: Color(0xff171002),
    correctFill: Color(0xff7BD88F),
    wrongFill: Color(0xffFF8A8A),
    onFeedback: Color(0xff171002),
    grid: Color(0x1AECE9F7),
    bookshelf: Color(0xffC0585B),
  );

  /// Outline of every neubrutalist element.
  final Color border;

  /// Hard offset shadow behind cards and buttons.
  final Color shadow;

  /// Shadow behind elements filled with [accent], where [shadow] would
  /// blend into the fill.
  final Color accentShadow;

  /// Default fill of cards, bubbles and buttons.
  final Color card;
  final Color onCard;

  /// Loud fill for the user's own messages and highlights.
  final Color accent;
  final Color onAccent;

  /// Fill of a correctly answered option.
  final Color correctFill;

  /// Fill of a wrongly answered option.
  final Color wrongFill;

  /// Text on [correctFill] and [wrongFill].
  final Color onFeedback;

  /// Lines of the graph paper background.
  final Color grid;

  /// Fill of the bookshelf on the home screen.
  final Color bookshelf;

  final double borderWidth;
  final Offset shadowOffset;
  final double radius;

  /// Decoration with outline and hard shadow. Pass [pressed] to drop the
  /// shadow while a button is held down.
  BoxDecoration decoration({
    Color? color,
    Color? shadowColor,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    bool pressed = false,
  }) =>
      BoxDecoration(
        color: color ?? card,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : borderRadius ?? BorderRadius.circular(radius),
        border: Border.all(color: border, width: borderWidth),
        boxShadow: [
          if (!pressed)
            BoxShadow(
              color: shadowColor ?? shadow,
              offset: shadowOffset,
            ),
        ],
      );

  @override
  NeoTheme copyWith({
    Color? border,
    Color? shadow,
    Color? accentShadow,
    Color? card,
    Color? onCard,
    Color? accent,
    Color? onAccent,
    Color? correctFill,
    Color? wrongFill,
    Color? onFeedback,
    Color? grid,
    Color? bookshelf,
    double? borderWidth,
    Offset? shadowOffset,
    double? radius,
  }) =>
      NeoTheme(
        border: border ?? this.border,
        shadow: shadow ?? this.shadow,
        accentShadow: accentShadow ?? this.accentShadow,
        card: card ?? this.card,
        onCard: onCard ?? this.onCard,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        correctFill: correctFill ?? this.correctFill,
        wrongFill: wrongFill ?? this.wrongFill,
        onFeedback: onFeedback ?? this.onFeedback,
        grid: grid ?? this.grid,
        bookshelf: bookshelf ?? this.bookshelf,
        borderWidth: borderWidth ?? this.borderWidth,
        shadowOffset: shadowOffset ?? this.shadowOffset,
        radius: radius ?? this.radius,
      );

  @override
  NeoTheme lerp(NeoTheme? other, double t) {
    if (other is! NeoTheme) {
      return this;
    }
    return NeoTheme(
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      accentShadow: Color.lerp(accentShadow, other.accentShadow, t)!,
      card: Color.lerp(card, other.card, t)!,
      onCard: Color.lerp(onCard, other.onCard, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      correctFill: Color.lerp(correctFill, other.correctFill, t)!,
      wrongFill: Color.lerp(wrongFill, other.wrongFill, t)!,
      onFeedback: Color.lerp(onFeedback, other.onFeedback, t)!,
      grid: Color.lerp(grid, other.grid, t)!,
      bookshelf: Color.lerp(bookshelf, other.bookshelf, t)!,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
      shadowOffset: Offset.lerp(shadowOffset, other.shadowOffset, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}
