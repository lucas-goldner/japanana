import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikou/core/data/lecture_repository.dart';

import '../mocks/mock_lecture_import_service_mock.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  test('Test get lectures from repository', () async {
    final mockLectureImportService = MockLectureImportService();
    final lectureRepository =
        LectureRepository(lectureProvider: mockLectureImportService);
    final lectures = await lectureRepository.fetchLectures();
    expect(lectures.length, 24);
    final firstLecture = lectures.first;
    final secondLecture = lectures[1];
    final thirdLecture = lectures[2];
    expect(firstLecture.title, 'んです');
    expect(secondLecture.title, '-ていただけませんか');
    expect(thirdLecture.title, '-たら良いですか');
    // expect(firstLecture.usages, [
    //   'Asking listener to confirm + When giving a reason or expiation In reply to a sentence with んです.',
    // ]);
    // expect(firstLecture.examples, ['雨が降っているんですか', 'バスが来なかったんです']);
    // expect(
    //   firstLecture.translation,
    //   ['Is it raining?', "...Because the bus didn't come"],
    // );
    // expect(firstLecture.extras, ['のです in writing.']);
  });
}
