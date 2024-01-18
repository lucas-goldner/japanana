import 'package:flutter_test/flutter_test.dart';
import 'package:hikou/core/data/lecture_import_service.dart';
import 'package:hikou/core/data/lecture_repository.dart';
import 'package:hikou/core/domain/lecture.dart';

class MockLectureImportService extends LectureRepository {
  @override
  Future<List<Lecture>> fetchLectures({
    String? assetsPath,
  }) async =>
      LectureImportService().fetchLectures(
        assetsPath: 'test/assets/data/Japanese Grammar Examples TestData.md',
      );
}
