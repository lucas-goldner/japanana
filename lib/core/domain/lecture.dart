class Lecture {
  Lecture({
    required this.title,
    required this.usages,
    required this.examples,
    required this.translation,
    this.extras,
  });

  final String title;
  final List<String> usages;
  final List<String> examples;
  final List<String> translation;
  final List<String>? extras;

  Lecture copyWith({
    String? title,
    List<String>? usages,
    List<String>? examples,
    List<String>? translation,
    List<String>? extras,
  }) =>
      Lecture(
        title: title ?? this.title,
        usages: usages ?? this.usages,
        examples: examples ?? this.examples,
        translation: translation ?? this.translation,
        extras: extras ?? this.extras,
      );
}
