import 'package:flutter/services.dart';
import 'package:hikou/core/data/lecture_repository.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/gen/assets.gen.dart';

enum ParagraphType {
  usage('- **Usage**:'),
  example('- **Examples**:'),
  translation("- **Translation**:"),
  extra("- **Extras**:"),
  end("_PARAGRAPH_END_");

  const ParagraphType(this.prefix);
  final String prefix;
}

typedef Paragraphs = (
  List<String> usages,
  List<String> examples,
  List<String> translations,
  List<String> extras
);

class LectureRepositoryImpl implements LectureRepository {
  @override
  Future<List<Lecture>> fetchLectures({
    String? assetsPath,
  }) async {
    final markdownContent = await rootBundle
        .loadString(assetsPath ?? Assets.data.japaneseGrammarExamples);

    final lectures = <Lecture>[];
    List<String> sections = _splitBySections(_removeHeaders(markdownContent));
    for (final (index, section) in sections.indexed) {
      lectures.add(_transformLecture(section, index));
    }

    return lectures;
  }

  String _removeHeaders(String inputText) {
    final lines = inputText.split('\n');
    final filteredLines = lines
        .where((line) => !(line.startsWith('##') && !line.startsWith('###')))
        .toList();
    return filteredLines.join('\n');
  }

  List<String> _splitBySections(String text) {
    RegExp exp = RegExp(r'###.*?(?=###|$)', dotAll: true);
    return exp.allMatches(text).map((m) => m.group(0)!.trim()).toList();
  }

  Lecture _transformLecture(String section, int currentLectureIndex) {
    final lines = section.split("\n");
    final title = lines.first.replaceAll("###", "").trim();
    final List<LectureType> lectureTypes = [];
    final contentLectureType = _getContentBasedLectureType(title);
    if (contentLectureType != null) lectureTypes.add(contentLectureType);
    final categorizedLectureType =
        _getCategorizedLectureType(currentLectureIndex);
    if (categorizedLectureType != null)
      lectureTypes.add(categorizedLectureType);
    final (usages, examples, translations, extras) = _extractParagraphs(lines);

    return Lecture(
      title: title,
      usages: usages,
      examples: examples,
      translations: translations,
      extras: extras,
      types: lectureTypes,
    );
  }

  // Legend: ✍️ Writing specific, 🗣️ Talk specific
  LectureType? _getContentBasedLectureType(String title) => switch (title) {
        String s when s.contains("✍️") => LectureType.writing,
        String s when s.contains("🗣️") => LectureType.conversational,
        _ => null
      };

  LectureType? _getCategorizedLectureType(int indexOfLecture) =>
      switch (indexOfLecture) {
        int i when i > 67 => LectureType.n3,
        int i when i <= 67 => LectureType.n4,
        _ => null
      };

  Paragraphs _extractParagraphs(List<String> lines) {
    lines.add(ParagraphType.end.prefix);
    List<String> usages = _getLinesPerParagraph(
        lines, ParagraphType.usage.prefix, ParagraphType.example.prefix);
    List<String> examples = _getLinesPerParagraph(
        lines, ParagraphType.example.prefix, ParagraphType.translation.prefix);
    List<String> translations = _getLinesPerParagraph(
        lines, ParagraphType.translation.prefix, ParagraphType.extra.prefix);
    List<String> extras = _getLinesPerParagraph(
        lines, ParagraphType.extra.prefix, ParagraphType.end.prefix);

    return (usages, examples, translations, extras);
  }

  List<String> _getLinesPerParagraph(
    List<String> lines,
    String currentParagraph,
    String nextParagraph,
  ) {
    final List<String> extractedLines = [];
    final currentParagraphIndex =
        lines.indexWhere((line) => line.trim().startsWith(currentParagraph));

    if (currentParagraphIndex != -1) {
      bool isEndOfList = (currentParagraphIndex + 1) == lines.length;
      bool isNotMultiLine =
          lines[isEndOfList ? lines.length - 1 : currentParagraphIndex + 1]
              .startsWith(nextParagraph);

      if (isNotMultiLine) {
        final line =
            lines[currentParagraphIndex].split(currentParagraph).last.trim();
        extractedLines.add(line);
      } else {
        final nextParagraphIndex =
            lines.indexWhere((line) => line.trim().startsWith(nextParagraph));
        final reachesEndOfLines = nextParagraphIndex == -1;
        final linesInBetween = lines.sublist(currentParagraphIndex + 1,
            reachesEndOfLines ? lines.length : nextParagraphIndex);
        linesInBetween.forEach((element) =>
            extractedLines.add(element.replaceAll("- ", "").trim()));
      }
    }

    extractedLines
        .removeWhere((element) => element == ParagraphType.end.prefix);
    return extractedLines;
  }
}
