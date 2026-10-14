import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/domain/shared_preferences_key.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/session/domain/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sessionProvider =
    NotifierProvider.family<SessionNotifier, Session?, LectureType>(
  SessionNotifier.new,
);

class SessionNotifier extends FamilyNotifier<Session?, LectureType> {
  SharedPreferences? _prefs;
  Future<void>? _loadingFuture;

  @override
  Session? build(LectureType lectureType) {
    // Load session asynchronously but don't block build
    _loadingFuture = _loadSession(lectureType);
    return null;
  }

  // For testing: wait for the initial load to complete
  Future<void> waitForLoad() async {
    await _loadingFuture;
  }

  Future<void> _loadSession(LectureType lectureType) async {
    _prefs = await SharedPreferences.getInstance();
    final sessionKey = SharedPreferencesKey.sessionKey(lectureType);
    final sessionJson = _prefs!.getString(sessionKey.value);

    if (sessionJson != null) {
      try {
        final session = Session.fromJson(sessionJson);
        state = session;
      } catch (e) {
        // Clear corrupted session data
        await _prefs!.remove(sessionKey.value);
      }
    }
  }

  Future<void> _ensurePrefsInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> startNewSession(
    ReviewSetupOptions options,
  ) async {
    await _ensurePrefsInitialized();

    final session = Session(
      lectureType: arg,
      options: options,
      completedLectureIds: [],
      lastUpdated: DateTime.now(),
    );

    state = session;
    await _saveSession();
  }

  Future<void> markLectureCompleted(String lectureId) async {
    final currentSession = state;
    if (currentSession == null) return;

    await _ensurePrefsInitialized();

    final updatedSession = currentSession.copyWith(
      completedLectureIds: [...currentSession.completedLectureIds, lectureId],
      lastUpdated: DateTime.now(),
    );

    state = updatedSession;
    await _saveSession();
  }

  Future<void> clearSession() async {
    await _ensurePrefsInitialized();
    state = null;
    final sessionKey = SharedPreferencesKey.sessionKey(arg);
    await _prefs!.remove(sessionKey.value);
  }

  Future<void> _saveSession() async {
    final currentSession = state;
    if (currentSession != null && _prefs != null) {
      final sessionKey = SharedPreferencesKey.sessionKey(arg);
      await _prefs!.setString(sessionKey.value, currentSession.toJson());
    }
  }

  Session? getSessionForType(LectureType type) {
    final currentSession = state;
    if (currentSession != null && currentSession.lectureType == type) {
      return currentSession;
    }
    return null;
  }
}
