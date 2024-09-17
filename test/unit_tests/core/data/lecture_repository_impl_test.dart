// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/data/lecture_repository_impl.dart';
import 'package:japanana/core/domain/lecture.dart';

void main() {
  setUp(WidgetsFlutterBinding.ensureInitialized);

  group('Test get lectures from repository', () {
    final lectureImportService = LectureRepositoryImpl();

    Future<List<Lecture>> fetchMockedLectures() async =>
        lectureImportService.fetchLectures(
          assetsPath: 'test/assets/data/Japanese Grammar Examples TestData.md',
        );

    (Lecture firstLecture, Lecture secondLecture, Lecture thirdLecture)
        getFirstThreeLectures(List<Lecture> lectures) {
      final firstLecture = lectures.first;
      final secondLecture = lectures[1];
      final thirdLecture = lectures[2];
      return (firstLecture, secondLecture, thirdLecture);
    }

    test('Test ensure all lectures loads correctly from test data', () async {
      final lectures = await fetchMockedLectures();
      expect(lectures.length, 25);
    });

    test('Test ensure all lectures loads correctly all data', () async {
      final lectureImportService = LectureRepositoryImpl();
      final lectures = await lectureImportService.fetchLectures();
      expect(lectures.length, 397);
    });

    test('Test lectures titles', () async {
      final lectures = await fetchMockedLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      expect(firstLecture.title, 'んです');
      expect(secondLecture.title, 'いただきます, くださいます, やります');
      expect(thirdLecture.title, '-ていただけませんか');
    });

    test('Test lectures usages', () async {
      final lectures = await fetchMockedLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      expect(firstLecture.usages, [
        'Asking listener to confirm + When giving a reason or expiation In reply to a sentence with んです.',
      ]);
      expect(secondLecture.usages, [
        'When the speaker receives something from someone of higher status -> いただきます',
        'When someone of higher status gives the speaker something -> くださいます',
        'When the recipient is someone of lower status, an animal or a plant -> やります but nowadays あげます is more used',
      ]);
      expect(
        thirdLecture.usages,
        ['More polite than てください to ask for something'],
      );
    });

    test('Test lectures examples', () async {
      final lectures = await fetchMockedLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      expect(firstLecture.examples, ['雨が降っているんですか', 'バスが来なかったんです']);
      expect(secondLecture.examples, ['もう一度考えてみます']);
      expect(thirdLecture.examples, ['良い先生を紹介していただけませんか']);
    });

    test('Test lectures translations', () async {
      final lectures = await fetchMockedLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      expect(
        firstLecture.translations,
        ['Is it raining?', "...Because the bus didn't come"],
      );
      expect(secondLecture.translations, ["I'll have another think about it"]);
      expect(
        thirdLecture.translations,
        ['Would you be so kind as to introduce me to a good teacher?'],
      );
    });

    test('Test lectures extras', () async {
      final lectures = await fetchMockedLectures();
      final (firstLecture, secondLecture, thirdLecture) =
          getFirstThreeLectures(lectures);
      final fifthLecture = lectures[4];
      final eighthLecture = lectures[7];
      final lastLecture = lectures[24];
      expect(firstLecture.extras, ['のです in writing.']);
      expect(secondLecture.extras, [
        '-てみたい can be used to express more reticently something one hopes for than when using -たい',
      ]);
      expect(thirdLecture.extras?.isEmpty, true);
      expect(fifthLecture.extras, ['Sentences need to use が']);
      expect(eighthLecture.extras, [
        'With ように the speaker is giving up in order to create a situation in which he or she will become able to have his or her own shop',
      ]);
      expect(lastLecture.extras, [
        '+ can also be in the form of とのことです ✍️',
        "+ ということですね can be used when repeating what someone just has said in order to confirm it: はい、分かりました。３０分ほど遅れるということですね。Yes, I understand. You'll be about thirty minutes late, right?",
      ]);
    });

    test('Test lectures content based types', () async {
      final lectures = await fetchMockedLectures();
      final writingLectures = lectures
          .where((lecture) => lecture.types.contains(LectureType.writing))
          .toList();
      final conversationalLectures = lectures
          .where(
            (lecture) => lecture.types.contains(LectureType.conversational),
          )
          .toList();
      expect(writingLectures.length, 1);
      expect(conversationalLectures.length, 1);
    });

    test('Test lectures categorized based types', () async {
      final lectureImportService = LectureRepositoryImpl();
      final lectures = await lectureImportService.fetchLectures();
      final n4Lectures = lectures
          .where((lecture) => lecture.types.contains(LectureType.n4))
          .toList();
      final n3Lectures = lectures
          .where((lecture) => lecture.types.contains(LectureType.n3))
          .toList();
      expect(n3Lectures.length, 329);
      expect(n4Lectures.length, 68);
      expect(n4Lectures.last.title, '謙譲語');
      expect(
        n3Lectures.first.title,
        'Vてform + てもらえませんか/ていただけませんか/てもらえないでしょうか/ていただけないでしょうか',
      );
      expect(n3Lectures.last.title, '一方だ');
    });
  });

  group('Test confirm formating some lectures are correctly imported', () {
    Future<List<Lecture>> getLectures() async {
      final lectureImportService = LectureRepositoryImpl();
      return lectureImportService.fetchLectures();
    }

    test('Test なさそう lecture is correctly imported', () async {
      final lectures = await getLectures();
      final nasaSouLecture = lectures
          .where((lecture) => lecture.title.contains('なさそう negative'))
          .first;
      expect(nasaSouLecture.title, 'なさそう negative (looks like そうです)');
      expect(nasaSouLecture.usages, [
        'Indicates something does not appear to be A or is not thought to be A',
      ]);
      expect(
        nasaSouLecture.examples,
        ['+ あの映画はあまり面白くなさそうですね', '+ この機会はそんなに複雑じゃなさそうです'],
      );
      expect(nasaSouLecture.translations, [
        "+ That film doesn't look very interesting, does it?",
        '+ This machine does not look that complicated',
      ]);
      expect(nasaSouLecture.extras?.length, 0);
      expect(nasaSouLecture.types, [LectureType.n3]);
    });

    test('Test なさそう lecture is correctly imported', () async {
      final lectures = await getLectures();
      final nasaSouLecture = lectures
          .where((lecture) => lecture.title.contains('そうもない negative'))
          .first;
      expect(nasaSouLecture.title, 'そうもない negative (I heard そうです)');
      expect(
        nasaSouLecture.usages,
        ['Indicates the prediction that V will probably not occur'],
      );
      expect(
        nasaSouLecture.examples,
        ['+ 今日は仕事がたくさんあるので、５時に帰れそうもありません。', '+ この雨はまだやみそうもないですね。'],
      );
      expect(nasaSouLecture.translations, [
        "+ I have a lot of work to do today, so it doesn't look like I'll be able to leave at five.",
        "+ This rain doesn't look like it's stopping yet, does it?",
      ]);
      expect(nasaSouLecture.extras?.length, 0);
      expect(nasaSouLecture.types, [LectureType.n3]);
    });
  });
}
