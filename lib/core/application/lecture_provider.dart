import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/shared_preferences_provider.dart';
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
  ) =>
      state.where((lecture) => lecture.types.contains(option)).toList();

  bool get hasLecturesInRememberChamper =>
      getLecturesForReviewOption(LectureType.remember).isNotEmpty;

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
  dependencies: [sharedPreferencesProvider],
);
