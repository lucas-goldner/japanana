import 'package:flutter/services.dart';
import 'package:japanana/core/data/lecture_repository.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/gen/assets.gen.dart';

enum ParagraphType {
  usage('- **Usage**:'),
  example('- **Examples**:'),
  translation('- **Translation**:'),
  extra('- **Extras**:'),
  end('_PARAGRAPH_END_');

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
    List<String>? lecturesToRememberIds,
  }) async {
    final markdownContent = await rootBundle
        .loadString(assetsPath ?? Assets.data.japaneseGrammarExamples);

    final lectures = <Lecture>[];
    final sections = _splitBySections(_removeHeaders(markdownContent));
    for (final (index, section) in sections.indexed) {
      lectures.add(
        _transformLecture(
          section: section,
          currentLectureIndex: index,
          lecturesToRememberIds: lecturesToRememberIds,
        ),
      );
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
    final exp = RegExp(r'###.*?(?=###|$)', dotAll: true);
    return exp.allMatches(text).map((m) => m.group(0)!.trim()).toList();
  }

  Lecture _transformLecture({
    required String section,
    required int currentLectureIndex,
    List<String>? lecturesToRememberIds,
  }) {
    final lines = section.split('\n');
    final title = lines.first.replaceAll('###', '').trim();
    final lectureTypes = <LectureType>[];
    final contentLectureType = _getContentBasedLectureType(title);
    if (contentLectureType != null) lectureTypes.add(contentLectureType);
    final categorizedLectureType =
        _getCategorizedLectureType(currentLectureIndex);
    if (categorizedLectureType != null) {
      lectureTypes.add(categorizedLectureType);
    }
    final (usages, examples, translations, extras) = _extractParagraphs(lines);
    final id = _createId(
      title: title,
      currentLectureIndex: currentLectureIndex,
      lectureTypes: lectureTypes,
    );

    return Lecture(
      id: id,
      title: title,
      usages: usages,
      examples: examples,
      translations: translations,
      extras: extras,
      types: [
        ...lectureTypes,
        if (lecturesToRememberIds != null && lecturesToRememberIds.contains(id))
          LectureType.remember,
      ],
    );
  }

  String _createId({
    required String title,
    required int currentLectureIndex,
    required List<LectureType> lectureTypes,
  }) {
    final sourceId =
        lectureTypes.join(',') + title + currentLectureIndex.toString();

    final shiftedId = String.fromCharCodes(
      sourceId.codeUnits.map((char) => char + 10).toList(),
    );

    return shiftedId;
  }

  // Legend: ✍️ Writing specific, 🗣️ Talk specific
  LectureType? _getContentBasedLectureType(String title) => switch (title) {
        final String s when s.contains('✍️') => LectureType.writing,
        final String s when s.contains('🗣️') => LectureType.conversational,
        _ => null
      };

  LectureType? _getCategorizedLectureType(int indexOfLecture) =>
      switch (indexOfLecture) {
        final int i when i > 67 => LectureType.n3,
        final int i when i <= 67 => LectureType.n4,
        _ => null
      };

  Paragraphs _extractParagraphs(List<String> lines) {
    lines.add(ParagraphType.end.prefix);
    final usages = _getLinesPerParagraph(
      lines,
      ParagraphType.usage.prefix,
      ParagraphType.example.prefix,
    );
    final examples = _getLinesPerParagraph(
      lines,
      ParagraphType.example.prefix,
      ParagraphType.translation.prefix,
    );
    final translations = _getLinesPerParagraph(
      lines,
      ParagraphType.translation.prefix,
      ParagraphType.extra.prefix,
    );
    final extras = _getLinesPerParagraph(
      lines,
      ParagraphType.extra.prefix,
      ParagraphType.end.prefix,
    );

    return (usages, examples, translations, extras);
  }

  List<String> _getLinesPerParagraph(
    List<String> lines,
    String currentParagraph,
    String nextParagraph,
  ) {
    final extractedLines = <String>[];
    final currentParagraphIndex =
        lines.indexWhere((line) => line.trim().startsWith(currentParagraph));

    if (currentParagraphIndex != -1) {
      final isEndOfList = (currentParagraphIndex + 1) == lines.length;
      final isNotMultiLine =
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
        final linesInBetween = lines.sublist(
          currentParagraphIndex + 1,
          reachesEndOfLines ? lines.length : nextParagraphIndex,
        );
        for (final element in linesInBetween) {
          extractedLines.add(element.replaceAll('- ', '').trim());
        }
      }
    }

    extractedLines
        .removeWhere((element) => element == ParagraphType.end.prefix);
    return extractedLines;
  }
}
