import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/shared_preferences_provider.dart';
import 'package:japanana/core/data/lecture_repository.dart';
import 'package:japanana/core/data/lecture_repository_impl.dart';
import 'package:japanana/core/data/shared_preferences_repository.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/domain/shared_preferences_key.dart';

class LectureNotifier extends Notifier<List<Lecture>> {
  LectureNotifier(this._repository);
  final LectureRepository _repository;

  @override
  List<Lecture> build() => [];

  Future<void> fetchLectures({
    required SharedPreferencesRepository sharedPreferencesRepository,
  }) async {
    final lecturesToRememberIds =
        sharedPreferencesRepository.getListStringOfSharedPreferences(
      SharedPreferencesKey.needToRememberLectures,
    );

    state = await _repository.fetchLectures(
      lecturesToRememberIds: lecturesToRememberIds,
    );
  }

  List<Lecture> getLecturesForReviewOption(
    LectureType option,
  ) =>
      state.where((lecture) => lecture.types.contains(option)).toList();

  void putLectureInRememberChamber() {
    ref.watch(sharedPreferencesProvider).writeListOfStringToSharedPreferences(
      SharedPreferencesKey.needToRememberLectures,
      [],
    );
  }
}

final lectureProvider = NotifierProvider<LectureNotifier, List<Lecture>>(
  () => LectureNotifier(LectureRepositoryImpl()),
);
