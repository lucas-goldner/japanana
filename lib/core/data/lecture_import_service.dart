import 'package:flutter/services.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/core/domain/lecture_type.dart';
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

class LectureImportService {
  Future<List<Lecture>> importLectures({
    String? assetsPath,
  }) async {
    final markdownContent = await rootBundle
        .loadString(assetsPath ?? Assets.data.japaneseGrammarExamples);

    final lectures = <Lecture>[];
    List<String> sections = _splitBySections(_removeHeaders(markdownContent));
    for (final section in sections) {
      lectures.add(_transformLecture(section));
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

  Lecture _transformLecture(String section) {
    final lines = section.split("\n");
    final title = lines.first.replaceAll("###", "").trim();
    final lectureType = _getLectureType(title);
    final (usages, examples, translations, extras) = _extractParagraphs(lines);

    return Lecture(
      title: title,
      usages: usages,
      examples: examples,
      translations: translations,
      extras: extras,
      type: lectureType,
    );
  }

  // Legend: ✍️ Writing specific, 🗣️ Talk specific
  LectureType? _getLectureType(String title) => switch (title) {
        String s when s.contains("✍️") => LectureType.writing,
        String s when s.contains("🗣️") => LectureType.conversational,
        _ => null
      };

  Paragraphs _extractParagraphs(List<String> lines) {
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
    lines.add(ParagraphType.end.prefix);
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

    return extractedLines;
  }
}
