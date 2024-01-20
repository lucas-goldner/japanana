enum LectureType {
  writing,
  conversational,
  n3,
  n4,
}

class Lecture {
  Lecture({
    required this.title,
    required this.usages,
    required this.examples,
    required this.translations,
    this.extras,
    required this.types,
  });

  final String title;
  final List<String> usages;
  final List<String> examples;
  final List<String> translations;
  final List<String>? extras;
  final List<LectureType> types;
}
