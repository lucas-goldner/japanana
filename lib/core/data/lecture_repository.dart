import 'package:hikou/core/data/lecture_import_service.dart';
import 'package:hikou/core/domain/lecture.dart';

class LectureRepository {
  LectureRepository({LectureImportService? lectureProvider})
      : _lectureProvider = lectureProvider ?? LectureImportService();
  final LectureImportService _lectureProvider;

  Future<List<Lecture>> fetchLectures() => _lectureProvider.importLectures();
}
