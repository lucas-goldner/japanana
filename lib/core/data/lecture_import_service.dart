import 'package:flutter/services.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/gen/assets.gen.dart';

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
    print(lines);
    final title = lines.first.replaceAll("###", "").trim();
    final usages = extractParagraphs(lines);
    final examples = extractParagraphs(lines);
    final ustranslationages = extractParagraphs(lines);
    final extras = extractParagraphs(lines);

    return lecture.copyWith(title: title, usages: usages);
  }

  List<String> extractParagraphs(List<String> lines) {
    List<String> usages = [];
    bool isDesiredSection = false;

    for (final line in lines) {
      if (line.trim().startsWith('- **Usage**:')) {
        final usage = line.split('- **Usage**:').last.trim();
        usages.add(usage);
        break;
      } else if (line.trim() == '- **Usage**:') {
        isDesiredSection = true;
        continue;
      }

      if (isDesiredSection) {
        if (line.trim().startsWith('- ')) {
          usages.add(line.trim().substring(2).trim());
        } else if (line.trim().isEmpty) {
          break;
        }
      }
    }

    return usages;
  }
}
