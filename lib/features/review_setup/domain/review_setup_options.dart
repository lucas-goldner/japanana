import 'package:flutter/foundation.dart';

@immutable
class ReviewSetupOptions {
  const ReviewSetupOptions({
    required this.randomize,
    required this.repeatOnFalseCard,
  });

  factory ReviewSetupOptions.fromMap(Map<String, dynamic> map) =>
      ReviewSetupOptions(
        randomize: map['randomize'] as bool,
        repeatOnFalseCard: map['repeatOnFalseCard'] as bool,
      );

  final bool randomize;
  final bool repeatOnFalseCard;

  ReviewSetupOptions copyWith({
    bool? randomize,
    bool? repeatOnFalseCard,
  }) =>
      ReviewSetupOptions(
        randomize: randomize ?? this.randomize,
        repeatOnFalseCard: repeatOnFalseCard ?? this.repeatOnFalseCard,
      );

  Map<String, dynamic> toMap() => {
        'randomize': randomize,
        'repeatOnFalseCard': repeatOnFalseCard,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewSetupOptions &&
        other.randomize == randomize &&
        other.repeatOnFalseCard == repeatOnFalseCard;
  }

  @override
  int get hashCode => randomize.hashCode ^ repeatOnFalseCard.hashCode;
}
