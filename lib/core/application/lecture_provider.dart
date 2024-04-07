import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/data/lecture_repository_impl.dart';
import 'package:japanana/core/data/lecture_repository.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/review_selection/domain/review_sections.dart';

class LectureNotifier extends Notifier<List<Lecture>> {
  LectureNotifier(this._repository);
  final LectureRepository _repository;

  @override
  List<Lecture> build() => [];

  void fetchLectures() async => state = await _repository.fetchLectures();

  List<Lecture> getLecturesForReviewOption(
    ReviewSections option,
  ) =>
      state.where((lecture) => lecture.types.contains(option)).toList();
}

final lectureProvider = NotifierProvider<LectureNotifier, List<Lecture>>(
  () => LectureNotifier(LectureRepositoryImpl()),
);
