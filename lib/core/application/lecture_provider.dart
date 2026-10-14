import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/shared_preferences_provider.dart';
import 'package:japanana/core/application/statistics_provider.dart';
import 'package:japanana/core/data/lecture_repository.dart';
import 'package:japanana/core/data/lecture_repository_impl.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/domain/shared_preferences_key.dart';

class LectureNotifier extends Notifier<List<Lecture>> {
  LectureNotifier(this._repository);
  final LectureRepository _repository;

  @override
  List<Lecture> build() => [];

  Future<void> fetchLectures() async {
    final lecturesToRememberIds =
        ref.read(sharedPreferencesProvider).getListStringOfSharedPreferences(
              SharedPreferencesKey.needToRememberLectures,
            );
    state = await _repository.fetchLectures(
      lecturesToRememberIds: lecturesToRememberIds,
    );
  }

  List<Lecture> getLecturesForReviewOption(
    LectureType option,
  ) {
    if (option == LectureType.recentMistakes) {
      // Get recent mistakes from statistics provider
      final mistakes = ref.read(mistakenLecturesProvider);

      // Get lectures that match the mistake IDs
      final mistakeLectureIds = mistakes.map((m) => m.lectureId).toSet();
      final mistakeLectures = state
          .where((lecture) => mistakeLectureIds.contains(lecture.id))
          .toList()

        // Sort by most recent mistake date
        ..sort((a, b) {
          final aMistake = mistakes.firstWhere((m) => m.lectureId == a.id);
          final bMistake = mistakes.firstWhere((m) => m.lectureId == b.id);
          return bMistake.lastMistakeDate.compareTo(aMistake.lastMistakeDate);
        });

      return mistakeLectures;
    }

    return state.where((lecture) => lecture.types.contains(option)).toList();
  }

  bool get hasLecturesInRememberChamper =>
      getLecturesForReviewOption(LectureType.remember).isNotEmpty;

  bool get hasRecentMistakes =>
      getLecturesForReviewOption(LectureType.recentMistakes).isNotEmpty;

  List<Lecture> getLecturesOfRememberChamber() {
    final rememberedLectureIds =
        ref.watch(sharedPreferencesProvider).getListStringOfSharedPreferences(
              SharedPreferencesKey.needToRememberLectures,
            );
    return state
        .where((lecture) => rememberedLectureIds.contains(lecture.id))
        .toList();
  }

  void putLectureInRememberChamber(String id) {
    final savedIds =
        getLecturesOfRememberChamber().map((lecture) => lecture.id).toList();
    final lectureToRememberIds = [...savedIds, id];
    ref.watch(sharedPreferencesProvider).writeListOfStringToSharedPreferences(
          SharedPreferencesKey.needToRememberLectures,
          lectureToRememberIds,
        );

    state = state
        .map(
          (lecture) => lectureToRememberIds.contains(lecture.id)
              ? lecture
                  .copyWith(types: [...lecture.types, LectureType.remember])
              : lecture,
        )
        .toList();
  }

  void banishLectureFromRememberChamber(String id) {
    final savedIds = getLecturesOfRememberChamber()
        .map((lecture) => lecture.id)
        .toList()
      ..removeWhere((element) => element == id);
    ref.watch(sharedPreferencesProvider).writeListOfStringToSharedPreferences(
          SharedPreferencesKey.needToRememberLectures,
          savedIds,
        );
    state = state
        .map(
          (lecture) => savedIds.contains(lecture.id)
              ? lecture
              : lecture.copyWith(
                  types: lecture.types..remove(LectureType.remember),
                ),
        )
        .toList();
  }
}

final lectureProvider = NotifierProvider<LectureNotifier, List<Lecture>>(
  () => LectureNotifier(LectureRepositoryImpl()),
  dependencies: [sharedPreferencesProvider, mistakenLecturesProvider],
);
