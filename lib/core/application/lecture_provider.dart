import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikou/core/data/lecture_import_service.dart';
import 'package:hikou/core/data/lecture_repository.dart';
import 'package:hikou/core/domain/lecture.dart';

class LectureNotifier extends Notifier<List<Lecture>> {
  LectureNotifier(this._repository);
  final LectureRepository _repository;

  @override
  List<Lecture> build() => [];

  void fetchLectures() async => state = await _repository.fetchLectures();
}

final lectureNotifierProvider =
    NotifierProvider<LectureNotifier, List<Lecture>>(
  () => LectureNotifier(LectureImportService()),
);
