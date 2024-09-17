import 'package:japanana/core/domain/lecture.dart';

// ignore: one_member_abstracts
abstract class LectureRepository {
  Future<List<Lecture>> fetchLectures({
    String? assetsPath,
  });
}
