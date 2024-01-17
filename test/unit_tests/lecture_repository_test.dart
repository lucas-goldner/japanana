import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikou/core/data/lecture_import_service.dart';
import 'package:hikou/core/data/lecture_repository.dart';
import 'package:hikou/core/domain/lecture.dart';

import '../mocks/mock_lecture_import_service_mock.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group("Test get lectures from repository", () {
    Future<LectureRepository> setupMockLectureImportService({
      String? assetsPath,
    }) async {
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

    test('Test ensure all lectures loads correctly from test data', () async {
      final lectureRepository = await setupMockLectureImportService();
      final lectures = await lectureRepository.fetchLectures();
      expect(lectures.length, 25);
    });

    test('Test ensure all lectures loads correctly all data', () async {
      final lectureImportService = LectureImportService();
      final lectureRepository =
          LectureRepository(lectureProvider: lectureImportService);
      final lectures = await lectureRepository.fetchLectures();
      expect(lectures.length, 331);
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

    test('Test lectures examples', () async {
      final lectureRepository = await setupMockLectureImportService();
      final lectures = await lectureRepository.fetchLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      expect(firstLecture.examples, ['雨が降っているんですか', 'バスが来なかったんです']);
      expect(secondLecture.examples, ['もう一度考えてみます']);
      expect(thirdLecture.examples, ['良い先生を紹介していただけませんか']);
    });

    test('Test lectures translations', () async {
      final lectureRepository = await setupMockLectureImportService();
      final lectures = await lectureRepository.fetchLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      expect(firstLecture.translation,
          ['Is it raining?', '...Because the bus didn\'t come']);
      expect(secondLecture.translation, ['I\'ll have another think about it']);
      expect(thirdLecture.translation,
          ['Would you be so kind as to introduce me to a good teacher?']);
    });

    test('Test lectures extras', () async {
      final lectureRepository = await setupMockLectureImportService();
      final lectures = await lectureRepository.fetchLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      final fifthLecture = lectures[4];
      final eighthLecture = lectures[7];
      final lastLecture = lectures[24];
      expect(firstLecture.extras, ['のです in writing.']);
      expect(secondLecture.extras, [
        '-てみたい can be used to express more reticently something one hopes for than when using -たい'
      ]);
      expect(thirdLecture.extras?.isEmpty, true);
      expect(fifthLecture.extras, ['Sentences need to use が']);
      expect(eighthLecture.extras, [
        'With ように the speaker is giving up in order to create a situation in which he or she will become able to have his or her own shop'
      ]);
      expect(lastLecture.extras, [
        '+ can also be in the form of とのことです ✍️',
        '+ ということですね can be used when repeating what someone just has said in order to confirm it: はい、分かりました。３０分ほど遅れるということですね。Yes, I understand. You\'ll be about thirty minutes late, right?'
      ]);
    });
  });
}
