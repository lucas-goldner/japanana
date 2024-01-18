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
}
