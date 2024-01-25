class ReviewSetupOptions {
  const ReviewSetupOptions({
    required this.randomize,
    required this.repeatOnFalseCard,
  });

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
}
