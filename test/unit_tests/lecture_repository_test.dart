import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikou/core/data/lecture_repository.dart';
import 'package:hikou/core/domain/lecture.dart';

import '../mocks/mock_lecture_import_service_mock.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group("Test get lectures from repository", () {
    Future<LectureRepository> setupMockLectureImportService() async {
      final mockLectureImportService = MockLectureImportService();
      return LectureRepository(lectureProvider: mockLectureImportService);
    }

    (Lecture firstLecture, Lecture secondLecture, Lecture thirdLecture)
        getFirstThreeLectures(List<Lecture> lectures) {
      final firstLecture = lectures.first;
      final secondLecture = lectures[1];
      final thirdLecture = lectures[2];
      return (firstLecture, secondLecture, thirdLecture);
    }

    test('Test ensure all lectures loads correctly', () async {
      final lectureRepository = await setupMockLectureImportService();
      final lectures = await lectureRepository.fetchLectures();
      expect(lectures.length, 24);
    });

    test('Test lectures titles', () async {
      final lectureRepository = await setupMockLectureImportService();
      final lectures = await lectureRepository.fetchLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      expect(firstLecture.title, 'んです');
      expect(secondLecture.title, 'いただきます, くださいます, やります');
      expect(thirdLecture.title, '-ていただけませんか');
    });

    test('Test lectures usages', () async {
      final lectureRepository = await setupMockLectureImportService();
      final lectures = await lectureRepository.fetchLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      expect(firstLecture.usages, [
        "Asking listener to confirm + When giving a reason or expiation In reply to a sentence with んです.",
      ]);
      expect(secondLecture.usages, [
        'When the speaker receives something from someone of higher status -> いただきます',
        'When someone of higher status gives the speaker something -> くださいます',
        'When the recipient is someone of lower status, an animal or a plant -> やります but nowadays あげます is more used'
      ]);
      expect(
          thirdLecture.usages, ['More polite than てください to ask for something']);
    });
  });
}
