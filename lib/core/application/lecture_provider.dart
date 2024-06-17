import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/data/lecture_repository_impl.dart';
import 'package:japanana/core/data/lecture_repository.dart';
import 'package:japanana/core/domain/lecture.dart';

class LectureNotifier extends Notifier<List<Lecture>> {
  LectureNotifier(this._repository);
  final LectureRepository _repository;

  @override
  List<Lecture> build() => [];

  Future<void> fetchLectures() async =>
      state = await _repository.fetchLectures();

  List<Lecture> getLecturesForReviewOption(
    LectureType option,
  ) =>
      state.where((lecture) => lecture.types.contains(option)).toList();
}

final lectureProvider = NotifierProvider<LectureNotifier, List<Lecture>>(
  () => LectureNotifier(LectureRepositoryImpl()),
);
