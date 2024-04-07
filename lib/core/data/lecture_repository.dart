import 'package:japanana/core/domain/lecture.dart';

abstract class LectureRepository {
  Future<List<Lecture>> fetchLectures({
    String? assetsPath,
  });
}
