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
}
