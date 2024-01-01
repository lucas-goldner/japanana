import 'package:flutter_test/flutter_test.dart';
import 'package:hikou/core/data/lecture_import_service.dart';
import 'package:hikou/core/domain/lecture.dart';

class MockLectureImportService implements LectureImportService {
  @override
  Future<List<Lecture>> importLectures({
    String? assetsPath,
  }) async =>
      LectureImportService().importLectures(
        assetsPath: 'test/assets/data/Japanese Grammar Examples TestData.md',
      );
}
