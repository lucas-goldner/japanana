enum LectureType {
  writing,
  conversational,
}

class Lecture {
  Lecture({
    required this.title,
    required this.usages,
    required this.examples,
    required this.translations,
    this.extras,
    this.type,
  });

  final String title;
  final List<String> usages;
  final List<String> examples;
  final List<String> translations;
  final List<String>? extras;
  final LectureType? type;

  Lecture copyWith(
          {String? title,
          List<String>? usages,
          List<String>? examples,
          List<String>? translation,
          List<String>? extras,
          LectureType? type}) =>
      Lecture(
        title: title ?? this.title,
        usages: usages ?? this.usages,
        examples: examples ?? this.examples,
        translations: translation ?? this.translations,
        extras: extras ?? this.extras,
        type: type ?? this.type,
      );
}
