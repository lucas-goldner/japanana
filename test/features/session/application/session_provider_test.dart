import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/session/application/session_provider.dart';
import 'package:japanana/features/session/domain/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SessionProvider', () {
    late ProviderContainer container;
    late SessionNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      notifier = container.read(sessionProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      expect(container.read(sessionProvider), isNull);
    });

    test('startNewSession creates and saves session', () async {
      const lectureType = LectureType.writing;
      const options = ReviewSetupOptions(
        randomize: true,
        repeatOnFalseCard: false,
      );

      await notifier.startNewSession(lectureType, options);

      final session = container.read(sessionProvider);
      expect(session, isNotNull);
      expect(session!.lectureType, lectureType);
      expect(session.options, options);
      expect(session.completedLectureIds, isEmpty);
      expect(session.lastUpdated, isA<DateTime>());
    });

    test('markLectureCompleted adds lecture to completed list', () async {
      const lectureType = LectureType.writing;
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      await notifier.startNewSession(lectureType, options);
      await notifier.markLectureCompleted('lecture-1');

      final session = container.read(sessionProvider);
      expect(session!.completedLectureIds, contains('lecture-1'));
    });

    test('markLectureCompleted updates lastUpdated', () async {
      const lectureType = LectureType.writing;
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      await notifier.startNewSession(lectureType, options);
      final initialTime = container.read(sessionProvider)!.lastUpdated;

      // Wait a bit to ensure time difference
      await Future.delayed(const Duration(milliseconds: 10));
      await notifier.markLectureCompleted('lecture-1');

      final updatedTime = container.read(sessionProvider)!.lastUpdated;
      expect(updatedTime.isAfter(initialTime), isTrue);
    });

    test('clearSession removes session from state and storage', () async {
      const lectureType = LectureType.writing;
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      await notifier.startNewSession(lectureType, options);
      expect(container.read(sessionProvider), isNotNull);

      await notifier.clearSession();
      expect(container.read(sessionProvider), isNull);
    });

    test('getSessionForType returns session for matching type', () async {
      const lectureType = LectureType.writing;
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      await notifier.startNewSession(lectureType, options);

      final session = notifier.getSessionForType(LectureType.writing);
      expect(session, isNotNull);
      expect(session!.lectureType, LectureType.writing);
    });

    test('getSessionForType returns null for non-matching type', () async {
      const lectureType = LectureType.writing;
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      await notifier.startNewSession(lectureType, options);

      final session = notifier.getSessionForType(LectureType.conversational);
      expect(session, isNull);
    });

    test('session persists across provider recreations', () async {
      const lectureType = LectureType.writing;
      const options = ReviewSetupOptions(
        randomize: true,
        repeatOnFalseCard: true,
      );

      await notifier.startNewSession(lectureType, options);
      await notifier.markLectureCompleted('lecture-1');

      // Dispose and recreate container to simulate app restart
      container.dispose();
      container = ProviderContainer();

      // Wait for session to load
      await container.read(sessionProvider.notifier).waitForLoad();

      final session = container.read(sessionProvider);
      expect(session, isNotNull);
      expect(session!.lectureType, lectureType);
      expect(session.options.randomize, true);
      expect(session.options.repeatOnFalseCard, true);
      expect(session.completedLectureIds, contains('lecture-1'));
    });

    test('corrupted session data is cleared on load', () async {
      // Set corrupted data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_session', 'invalid-json');

      container.dispose();
      container = ProviderContainer();

      // Wait for session to load
      await container.read(sessionProvider.notifier).waitForLoad();

      final session = container.read(sessionProvider);
      expect(session, isNull);
    });
  });

  group('Session', () {
    test('toJson and fromJson work correctly', () {
      final originalSession = Session(
        lectureType: LectureType.writing,
        options: const ReviewSetupOptions(
          randomize: true,
          repeatOnFalseCard: false,
        ),
        completedLectureIds: ['lecture-1', 'lecture-2'],
        lastUpdated: DateTime(2023),
      );

      final json = originalSession.toJson();
      final restoredSession = Session.fromJson(json);

      expect(restoredSession.lectureType, originalSession.lectureType);
      expect(
        restoredSession.options.randomize,
        originalSession.options.randomize,
      );
      expect(
        restoredSession.options.repeatOnFalseCard,
        originalSession.options.repeatOnFalseCard,
      );
      expect(
        restoredSession.completedLectureIds,
        originalSession.completedLectureIds,
      );
      expect(restoredSession.lastUpdated, originalSession.lastUpdated);
    });

    test('copyWith creates new instance with updated values', () {
      final originalSession = Session(
        lectureType: LectureType.writing,
        options: const ReviewSetupOptions(
          randomize: false,
          repeatOnFalseCard: false,
        ),
        completedLectureIds: ['lecture-1'],
        lastUpdated: DateTime(2023),
      );

      final updatedSession = originalSession.copyWith(
        completedLectureIds: ['lecture-1', 'lecture-2'],
        lastUpdated: DateTime(2023, 1, 2),
      );

      expect(updatedSession.lectureType, originalSession.lectureType);
      expect(updatedSession.options, originalSession.options);
      expect(updatedSession.completedLectureIds, ['lecture-1', 'lecture-2']);
      expect(updatedSession.lastUpdated, DateTime(2023, 1, 2));
    });
  });
}
