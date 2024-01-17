import 'package:flutter/services.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/gen/assets.gen.dart';

enum ParagraphType {
  usage('- **Usage**:'),
  example('- **Examples**:'),
  translation("- **Translation**:"),
  extra("- **Extras**:");

  const ParagraphType(this.prefix);
  final String prefix;
}

class LectureImportService {
  List<String> splitBySections(String text) {
    RegExp exp = RegExp(r'###.*?(?=###|$)', dotAll: true);
    return exp.allMatches(text).map((m) => m.group(0)!.trim()).toList();
  }

  Future<List<Lecture>> importLectures({
    String? assetsPath,
  }) async {
    final markdownContent = await rootBundle
        .loadString(assetsPath ?? Assets.data.japaneseGrammarExamples);

    final lectures = <Lecture>[];
    List<String> sections = splitBySections(markdownContent);
    for (final section in sections) {
      lectures.add(transformLecture(section));
    }

    return lectures;
  }

  Lecture transformLecture(String section) {
    final lecture = Lecture(
        title: "", usages: [], examples: [], translation: [], extras: []);

    final lines = section.split("\n");
    final title = lines.first.replaceAll("###", "").trim();
    final (usages, examples, translations) = extractParagraphs(lines);

    return lecture.copyWith(
      title: title,
      usages: usages,
      examples: examples,
      translation: translations,
    );
  }

  (List<String> usages, List<String> examples, List<String> translations)
      extractParagraphs(List<String> lines) {
    List<String> usages = getLinesPerParagraph(
        lines, ParagraphType.usage.prefix, ParagraphType.example.prefix);
    List<String> examples = getLinesPerParagraph(
        lines, ParagraphType.example.prefix, ParagraphType.translation.prefix);
    List<String> translations = getLinesPerParagraph(
        lines, ParagraphType.translation.prefix, ParagraphType.extra.prefix);

    return (usages, examples, translations);
  }

  List<String> getLinesPerParagraph(
    List<String> lines,
    String currentParagraph,
    String nextParagraph,
  ) {
    final List<String> extractedLines = [];
    final currentParagraphIndex =
        lines.indexWhere((line) => line.trim().startsWith(currentParagraph));

    if (currentParagraphIndex != -1) {
      bool isNotMultiLine =
          lines[currentParagraphIndex + 1].startsWith(nextParagraph);

      if (isNotMultiLine) {
        final usage =
            lines[currentParagraphIndex].split(currentParagraph).last.trim();
        extractedLines.add(usage);
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
