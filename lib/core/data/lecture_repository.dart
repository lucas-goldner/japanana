import 'package:hikou/core/domain/lecture.dart';

abstract class LectureRepository {
  Future<List<Lecture>> fetchLectures({
    String? assetsPath,
  });
}
