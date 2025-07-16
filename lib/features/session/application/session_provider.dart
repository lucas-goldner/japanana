import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/session/domain/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sessionKey = 'current_session';

final sessionProvider =
    NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

class SessionNotifier extends Notifier<Session?> {
  SharedPreferences? _prefs;
  Future<void>? _loadingFuture;

  @override
  Session? build() {
    // Load session asynchronously but don't block build
    _loadingFuture = _loadSession();
    return null;
  }

  // For testing: wait for the initial load to complete
  Future<void> waitForLoad() async {
    await _loadingFuture;
  }

  Future<void> _loadSession() async {
    _prefs = await SharedPreferences.getInstance();
    final sessionJson = _prefs!.getString(_sessionKey);

    if (sessionJson != null) {
      try {
        final session = Session.fromJson(sessionJson);
        state = session;
      } catch (e) {
        // Clear corrupted session data
        await _prefs!.remove(_sessionKey);
      }
    }
  }

  Future<void> _ensurePrefsInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> startNewSession(
    LectureType lectureType,
    ReviewSetupOptions options,
  ) async {
    await _ensurePrefsInitialized();

    final session = Session(
      lectureType: lectureType,
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
    await _prefs!.remove(_sessionKey);
  }

  Future<void> _saveSession() async {
    final currentSession = state;
    if (currentSession != null && _prefs != null) {
      await _prefs!.setString(_sessionKey, currentSession.toJson());
    }
  }

  Session? getSessionForType(LectureType type) {
    final currentSession = state;
    if (currentSession?.lectureType == type) {
      return currentSession;
    }
    return null;
  }
}
