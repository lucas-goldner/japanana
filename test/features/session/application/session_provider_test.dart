import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/domain/shared_preferences_key.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/session/application/session_provider.dart';
import 'package:japanana/features/session/domain/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SessionProvider', () {
    late ProviderContainer container;
    const testLectureType = LectureType.writing;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      expect(container.read(sessionProvider(testLectureType)), isNull);
    });

    test('startNewSession creates and saves session', () async {
      const options = ReviewSetupOptions(
        randomize: true,
        repeatOnFalseCard: false,
      );

      await container
          .read(sessionProvider(testLectureType).notifier)
          .startNewSession(options);

      final session = container.read(sessionProvider(testLectureType));
      expect(session, isNotNull);
      expect(session!.lectureType, testLectureType);
      expect(session.options, options);
      expect(session.completedLectureIds, isEmpty);
      expect(session.lastUpdated, isA<DateTime>());
    });

    test('markLectureCompleted adds lecture to completed list', () async {
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      final notifier =
          container.read(sessionProvider(testLectureType).notifier);
      await notifier.startNewSession(options);
      await notifier.markLectureCompleted('lecture-1');

      final session = container.read(sessionProvider(testLectureType));
      expect(session!.completedLectureIds, contains('lecture-1'));
    });

    test('markLectureCompleted updates lastUpdated', () async {
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      final notifier =
          container.read(sessionProvider(testLectureType).notifier);
      await notifier.startNewSession(options);
      final initialTime =
          container.read(sessionProvider(testLectureType))!.lastUpdated;

      // Wait a bit to ensure time difference
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await notifier.markLectureCompleted('lecture-1');

      final updatedTime =
          container.read(sessionProvider(testLectureType))!.lastUpdated;
      expect(updatedTime.isAfter(initialTime), isTrue);
    });

    test('clearSession removes session from state and storage', () async {
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      final notifier =
          container.read(sessionProvider(testLectureType).notifier);
      await notifier.startNewSession(options);
      expect(container.read(sessionProvider(testLectureType)), isNotNull);

      await notifier.clearSession();
      expect(container.read(sessionProvider(testLectureType)), isNull);
    });

    test('getSessionForType returns session for matching type', () async {
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      final notifier =
          container.read(sessionProvider(testLectureType).notifier);
      await notifier.startNewSession(options);

      final session = notifier.getSessionForType(LectureType.writing);
      expect(session, isNotNull);
      expect(session!.lectureType, LectureType.writing);
    });

    test('getSessionForType returns null for non-matching type', () async {
      const options = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: false,
      );

      final notifier =
          container.read(sessionProvider(testLectureType).notifier);
      await notifier.startNewSession(options);

      final session = notifier.getSessionForType(LectureType.conversational);
      expect(session, isNull);
    });

    test('session persists across provider recreations', () async {
      const options = ReviewSetupOptions(
        randomize: true,
        repeatOnFalseCard: true,
      );

      final notifier =
          container.read(sessionProvider(testLectureType).notifier);
      await notifier.startNewSession(options);
      await notifier.markLectureCompleted('lecture-1');

      // Dispose and recreate container to simulate app restart
      container.dispose();
      container = ProviderContainer();

      // Wait for session to load
      await container
          .read(sessionProvider(testLectureType).notifier)
          .waitForLoad();

      final session = container.read(sessionProvider(testLectureType));
      expect(session, isNotNull);
      expect(session!.lectureType, testLectureType);
      expect(session.options.randomize, true);
      expect(session.options.repeatOnFalseCard, true);
      expect(session.completedLectureIds, contains('lecture-1'));
    });

    test('corrupted session data is cleared on load', () async {
      // Set corrupted data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = SharedPreferencesKey.sessionKey(testLectureType);
      await prefs.setString(sessionKey.value, 'invalid-json');

      container.dispose();
      container = ProviderContainer();

      // Wait for session to load
      await container
          .read(sessionProvider(testLectureType).notifier)
          .waitForLoad();

      final session = container.read(sessionProvider(testLectureType));
      expect(session, isNull);
    });
  });

  group('Multiple Sessions', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('can handle multiple sessions for different lecture types', () async {
      const writingOptions = ReviewSetupOptions(
        randomize: true,
        repeatOnFalseCard: false,
      );
      const conversationalOptions = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: true,
      );

      // Start sessions for different lecture types
      await container
          .read(sessionProvider(LectureType.writing).notifier)
          .startNewSession(writingOptions);
      await container
          .read(sessionProvider(LectureType.conversational).notifier)
          .startNewSession(conversationalOptions);

      // Verify both sessions exist independently
      final writingSession =
          container.read(sessionProvider(LectureType.writing));
      final conversationalSession =
          container.read(sessionProvider(LectureType.conversational));

      expect(writingSession, isNotNull);
      expect(conversationalSession, isNotNull);
      expect(writingSession!.lectureType, LectureType.writing);
      expect(conversationalSession!.lectureType, LectureType.conversational);
      expect(writingSession.options.randomize, true);
      expect(conversationalSession.options.randomize, false);
    });

    test('sessions are isolated and do not affect each other', () async {
      const options = ReviewSetupOptions(
        randomize: true,
        repeatOnFalseCard: false,
      );

      // Start sessions for different lecture types
      await container
          .read(sessionProvider(LectureType.writing).notifier)
          .startNewSession(options);
      await container
          .read(sessionProvider(LectureType.conversational).notifier)
          .startNewSession(options);

      // Complete a lecture in one session
      await container
          .read(sessionProvider(LectureType.writing).notifier)
          .markLectureCompleted('lecture-1');

      // Verify only the writing session has the completed lecture
      final writingSession =
          container.read(sessionProvider(LectureType.writing));
      final conversationalSession =
          container.read(sessionProvider(LectureType.conversational));

      expect(writingSession!.completedLectureIds, contains('lecture-1'));
      expect(conversationalSession!.completedLectureIds, isEmpty);
    });

    test('clearing one session does not affect other sessions', () async {
      const options = ReviewSetupOptions(
        randomize: true,
        repeatOnFalseCard: false,
      );

      // Start sessions for different lecture types
      await container
          .read(sessionProvider(LectureType.writing).notifier)
          .startNewSession(options);
      await container
          .read(sessionProvider(LectureType.conversational).notifier)
          .startNewSession(options);

      // Clear one session
      await container
          .read(sessionProvider(LectureType.writing).notifier)
          .clearSession();

      // Verify only the writing session is cleared
      final writingSession =
          container.read(sessionProvider(LectureType.writing));
      final conversationalSession =
          container.read(sessionProvider(LectureType.conversational));

      expect(writingSession, isNull);
      expect(conversationalSession, isNotNull);
    });

    test('multiple sessions persist across provider recreations', () async {
      const writingOptions = ReviewSetupOptions(
        randomize: true,
        repeatOnFalseCard: false,
      );
      const conversationalOptions = ReviewSetupOptions(
        randomize: false,
        repeatOnFalseCard: true,
      );

      // Start sessions for different lecture types
      await container
          .read(sessionProvider(LectureType.writing).notifier)
          .startNewSession(writingOptions);
      await container
          .read(sessionProvider(LectureType.conversational).notifier)
          .startNewSession(conversationalOptions);

      // Mark lectures as completed in both sessions
      await container
          .read(sessionProvider(LectureType.writing).notifier)
          .markLectureCompleted('writing-1');
      await container
          .read(sessionProvider(LectureType.conversational).notifier)
          .markLectureCompleted('conversational-1');

      // Dispose and recreate container to simulate app restart
      container.dispose();
      container = ProviderContainer();

      // Wait for sessions to load
      await container
          .read(sessionProvider(LectureType.writing).notifier)
          .waitForLoad();
      await container
          .read(sessionProvider(LectureType.conversational).notifier)
          .waitForLoad();

      // Verify both sessions are restored correctly
      final writingSession =
          container.read(sessionProvider(LectureType.writing));
      final conversationalSession =
          container.read(sessionProvider(LectureType.conversational));

      expect(writingSession, isNotNull);
      expect(conversationalSession, isNotNull);
      expect(writingSession!.lectureType, LectureType.writing);
      expect(conversationalSession!.lectureType, LectureType.conversational);
      expect(writingSession.options.randomize, true);
      expect(conversationalSession.options.randomize, false);
      expect(writingSession.completedLectureIds, contains('writing-1'));
      expect(
        conversationalSession.completedLectureIds,
        contains('conversational-1'),
      );
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
