import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikou/core/data/lecture_repository_impl.dart';
import 'package:hikou/core/data/lecture_repository.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/features/review_setup/domain/review_options.dart';

class LectureNotifier extends Notifier<List<Lecture>> {
  LectureNotifier(this._repository);
  final LectureRepository _repository;

  @override
  List<Lecture> build() => [];

  void fetchLectures() async => state = await _repository.fetchLectures();

  Future<List<Lecture>> getLecturesForReviewOption(
    ReviewOptions option,
  ) async =>
      state.where((lecture) => lecture.types.contains(option)).toList();
}

final lectureProvider = NotifierProvider<LectureNotifier, List<Lecture>>(
  () => LectureNotifier(LectureRepositoryImpl()),
);
