import 'package:flutter/material.dart';
import 'package:japanana/core/domain/lecture.dart';

class BooksTheme extends ThemeExtension<BooksTheme> {
  BooksTheme() {
    const lectureTypes = LectureType.values;
    for (final type in lectureTypes) {
      switch (type) {
        case LectureType.writing:
          lectureTypeColors[type] = (
            primary: const Color(0xFF323232),
            secondary: const Color(0xFF1E1E1E)
          );
        case LectureType.conversational:
          lectureTypeColors[type] = (
            primary: const Color(0xFFF64A69),
            secondary: const Color(0xFFEF3349)
          );

        case LectureType.n2:
          lectureTypeColors[type] = (
            primary: const Color(0xFFFA9716),
            secondary: const Color(0xFFE88D14)
          );

        case LectureType.n3:
          lectureTypeColors[type] = (
            primary: const Color(0xFF87BF29),
            secondary: const Color(0xFF7FB226)
          );
        case LectureType.n4:
          lectureTypeColors[type] = (
            primary: const Color(0xFF45A099),
            secondary: const Color(0xFF40958D)
          );

        case LectureType.remember:
          lectureTypeColors[type] = (
            primary: const Color(0xFF8F50E9),
            secondary: const Color(0xFF645290)
          );
      }
    }
  }

  final Map<LectureType, ({Color primary, Color secondary})> lectureTypeColors =
      {};

  @override
  ThemeExtension<BooksTheme> copyWith() => this;

  @override
  ThemeExtension<BooksTheme> lerp(
    covariant ThemeExtension<BooksTheme>? other,
    double t,
  ) =>
      this;
}
