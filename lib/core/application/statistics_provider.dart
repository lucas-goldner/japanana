import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/domain/mistake.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _mistakesKey = 'mistakes';

final mistakenLecturesProvider =
    NotifierProvider<MistakenLecturesNotifier, List<Mistake>>(
  MistakenLecturesNotifier.new,
);

final statisticsProvider =
    Provider<List<Mistake>>((ref) => ref.watch(mistakenLecturesProvider));

class MistakenLecturesNotifier extends Notifier<List<Mistake>> {
  late SharedPreferences _prefs;

  @override
  List<Mistake> build() {
    _loadMistakes();
    return [];
  }

  Future<void> _loadMistakes() async {
    _prefs = await SharedPreferences.getInstance();
    final mistakesJson = _prefs.getStringList(_mistakesKey) ?? [];

    final mistakes = mistakesJson.map(Mistake.fromJson).toList()
      ..sort((a, b) => b.lastMistakeDate.compareTo(a.lastMistakeDate));

    state = mistakes;
  }

  Future<void> addMistake(String lectureId) async {
    final existingIndex = state.indexWhere((m) => m.lectureId == lectureId);

    if (existingIndex != -1) {
      // Update existing mistake
      final updated = state[existingIndex].copyWith(
        mistakeCount: state[existingIndex].mistakeCount + 1,
        lastMistakeDate: DateTime.now(),
      );

      state = [
        ...state.sublist(0, existingIndex),
        updated,
        ...state.sublist(existingIndex + 1),
      ]..sort((a, b) => b.lastMistakeDate.compareTo(a.lastMistakeDate));
    } else {
      // Add new mistake
      final newMistake = Mistake(
        lectureId: lectureId,
        mistakeCount: 1,
        lastMistakeDate: DateTime.now(),
      );

      state = [newMistake, ...state];
    }

    // Save to SharedPreferences
    await _saveMistakes();
  }

  Future<void> _saveMistakes() async {
    final mistakesJson = state.map((m) => m.toJson()).toList();
    await _prefs.setStringList(_mistakesKey, mistakesJson);
  }

  Future<void> clearMistakes() async {
    state = [];
    await _prefs.remove(_mistakesKey);
  }
}
