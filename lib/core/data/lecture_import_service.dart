import 'package:flutter/services.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/gen/assets.gen.dart';

class LectureImportService {
  Future<List<Lecture>> importLectures({
    String? assetsPath,
  }) async {
    final markdownContent = await rootBundle
        .loadString(assetsPath ?? Assets.data.japaneseGrammarExamples);

    final lectures = <Lecture>[];
    markdownContent.split('\n').forEach((line) {
      Lecture? lecture;
      if (line.startsWith('###')) {
        lecture = Lecture(
          title: line,
          usages: [],
          examples: [],
          translation: [],
        );
      }

      if (line.startsWith('- **Usage**:')) {
        for (var i = markdownContent.indexOf(line);
            i < markdownContent.length;
            i++) {
          final nextLine = markdownContent[i];
          if (nextLine.startsWith('- **Examples**:')) {
            break;
          }
          lecture = lecture!.copyWith(usages: [...lecture.usages, nextLine]);
        }
        final nextLine = markdownContent[markdownContent.indexOf(line)];

        if (nextLine.startsWith('- **Examples**:')) {}

        lecture = Lecture(
          title: line,
          usages: [],
          examples: [],
          translation: [],
        );
      }
    });

    return lectures;
  }
}
