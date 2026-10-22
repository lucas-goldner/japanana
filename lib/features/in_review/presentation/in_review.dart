import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/random_provider.dart';
import 'package:japanana/core/application/statistics_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/in_review/domain/question_builder.dart';
import 'package:japanana/features/in_review/domain/review_question.dart';
import 'package:japanana/features/in_review/domain/session_recap.dart';
import 'package:japanana/features/in_review/presentation/recap/recap_share_screen.dart';
import 'package:japanana/features/in_review/presentation/widgets/breaks/breaks.dart';
import 'package:japanana/features/in_review/presentation/widgets/lecture_section.dart';
import 'package:japanana/features/in_review/presentation/widgets/review_widgets.dart';
import 'package:japanana/features/in_review/presentation/widgets/session_summary.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/session/application/session_provider.dart';
import 'package:japanana/features/statistics/application/study_log_provider.dart';

/// Lectures between two breaks.
const kBreakEvery = 10;
const _kScrollDuration = Duration(milliseconds: 380);
const _kSnapDuration = Duration(milliseconds: 260);

/// How close a section start has to be to the top for scrolling to snap.
const _kSnapReach = 0.25;
const _kTopicHold = Duration(milliseconds: 2400);
const _kTopicFadeIn = Duration(milliseconds: 200);
const _kTopicFadeOut = Duration(milliseconds: 700);
const _kEndMargin = 24.0;

sealed class _Section {
  _Section(this.id);
  final int id;
}

class _LectureEntry extends _Section {
  _LectureEntry(super.id, this.question);
  final LectureQuestion question;
}

class _BreakEntry extends _Section {
  _BreakEntry(super.id, this.kind, {this.cards, this.statements});
  final BreakKind kind;
  final List<MemoryCard>? cards;
  final List<LightningStatement>? statements;
}

class _SummaryEntry extends _Section {
  _SummaryEntry(super.id, this.recap);
  final SessionRecap recap;
}

/// The review: one scrolling conversation in which every lecture is asked a
/// different way, with games in between. Everything stays in the history so
/// mistakes can be looked at again at the end.
class InReview extends HookConsumerWidget {
  const InReview(
    this.reviewOption, {
    @visibleForTesting this.modeSequence,
    @visibleForTesting this.breakEvery = kBreakEvery,
    super.key,
  });

  final (LectureType?, ReviewSetupOptions?)? reviewOption;

  /// Modes used in turn instead of picking them, for tests.
  final List<QuestionMode>? modeSequence;
  final int breakEvery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final existingSession = ref.watch(
      sessionProvider(reviewOption?.$1 ?? LectureType.writing),
    );
    final lectureType =
        existingSession?.lectureType ?? reviewOption?.$1 ?? LectureType.writing;
    final options =
        existingSession?.options ??
        reviewOption?.$2 ??
        const ReviewSetupOptions(randomize: false, repeatOnFalseCard: false);
    final random = ref.read(randomProvider);

    final deck = useMemoized(() {
      final list = [
        ...ref
            .read(lectureProvider.notifier)
            .getLecturesForReviewOption(lectureType),
      ];
      final completed = existingSession?.completedLectureIds ?? const [];
      list.removeWhere((lecture) => completed.contains(lecture.id));
      if (options.randomize) list.shuffle(random);
      return list;
    });
    final builder = useMemoized(() {
      final answers = ref.read(studyLogProvider).answers;
      return QuestionBuilder(
        deck: deck,
        allLectures: ref.read(lectureProvider),
        random: random,
        seenLectureIds: {for (final answer in answers) answer.lectureId},
        partners: mixedUpPartners(answers),
      );
    });

    final sections = useState<List<_Section>>([]);
    final nextLecture = useRef(0);
    final nextId = useRef(0);
    final completed = useRef(0);
    final keys = useRef(<int, GlobalKey>{});
    final sectionOfLecture = useRef(<String, int>{});
    final solvedSections = useRef(<int>{});
    final endKey = useMemoized(GlobalKey.new);
    final scrollController = useScrollController();
    final scrollTarget = useRef<double?>(null);
    final userScrolling = useRef(false);

    final combo = useState(0);
    final bestCombo = useRef(0);
    final firstTryRight = useRef(0);
    final answered = useRef(0);
    final hadWrong = useRef(<String>{});
    final missed = useRef(<Lecture>[]);
    final learned = useRef(<Lecture>[]);

    final topic = useState<String?>(null);
    final topicVisible = useState(false);
    final topicTimer = useRef<Timer?>(null);

    final studyLog = ref.read(studyLogProvider.notifier);
    final cardsCompleted = useRef(0);
    final mounted = useRef(true);

    // Record the session when leaving the review screen.
    useEffect(() {
      final start = ref.read(clockProvider)();
      return () {
        mounted.value = false;
        topicTimer.value?.cancel();
        if (cardsCompleted.value > 0) {
          studyLog.recordSession(
            start: start,
            cardsCompleted: cardsCompleted.value,
          );
        }
      };
    }, []);

    final media = MediaQuery.of(context);
    final headerBottom = media.padding.top + kToolbarHeight;
    final viewportHeight = media.size.height;

    double? topOf(GlobalKey key) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) return null;
      return box.localToGlobal(Offset.zero).dy;
    }

    void animateTo(double offset, {Duration duration = _kScrollDuration}) {
      if (!scrollController.hasClients) return;
      final position = scrollController.position;
      final clamped = offset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      scrollTarget.value = clamped;
      scrollController.animateTo(
        clamped,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    }

    void showTopic(int sectionId) {
      final section = sections.value
          .where((s) => s.id == sectionId)
          .firstOrNull;
      final text = switch (section) {
        _LectureEntry(:final question) =>
          (question.mode == QuestionMode.gap ||
                      question.mode == QuestionMode.pairs) &&
                  !solvedSections.value.contains(sectionId)
              ? question.mode.label(context)
              : '${question.lecture.title} · ${question.mode.label(context)}',
        _BreakEntry(:final kind) => kind.label(context),
        _ => null,
      };
      if (text == null) return;
      topicTimer.value?.cancel();
      topic.value = text;
      topicVisible.value = true;
      topicTimer.value = Timer(_kTopicHold, () {
        if (mounted.value) topicVisible.value = false;
      });
    }

    /// Scrolls so the section starts right below the app bar.
    void scrollToSection(int id, {bool announce = false, int retries = 3}) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted.value || !scrollController.hasClients) return;
        final key = keys.value[id];
        final top = key == null ? null : topOf(key);
        if (top == null) {
          if (retries > 0) {
            scrollToSection(id, announce: announce, retries: retries - 1);
          }
          return;
        }
        animateTo(scrollController.offset + top - headerBottom);
        if (announce) showTopic(id);
      });
    }

    /// Scrolls down just enough for the newest content to show.
    void revealEnd() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted.value || !scrollController.hasClients) return;
        final bottom = topOf(endKey);
        if (bottom == null) return;
        final offset = scrollController.offset;
        final base = scrollTarget.value ?? offset;
        final bottomAtTarget = bottom - (base - offset);
        final limit = viewportHeight - _kEndMargin;
        if (bottomAtTarget > limit) animateTo(base + bottomAtTarget - limit);
      });
    }

    void addSection(_Section Function(int id) create) {
      final id = nextId.value++;
      keys.value[id] = GlobalKey();
      sections.value = [...sections.value, create(id)];
      scrollToSection(id);
    }

    void appendLecture() {
      final lecture = deck[nextLecture.value];
      final previous = sections.value
          .whereType<_LectureEntry>()
          .lastOrNull
          ?.question
          .mode;
      final forced = modeSequence == null
          ? null
          : modeSequence![nextLecture.value % modeSequence!.length];
      nextLecture.value++;
      final question = builder.build(
        lecture,
        previous: previous,
        forced: forced,
      );
      addSection((id) {
        sectionOfLecture.value[lecture.id] = id;
        return _LectureEntry(id, question);
      });
    }

    void finishSession() {
      ref.read(sessionProvider(lectureType).notifier).clearSession();
      final recap = SessionRecap(
        book: lectureType,
        date: ref.read(clockProvider)(),
        cards: answered.value,
        firstTryRight: firstTryRight.value,
        bestCombo: bestCombo.value,
        learned: learned.value,
        missed: missed.value,
      );
      addSection((id) => _SummaryEntry(id, recap));
    }

    void appendBreak() {
      final round = completed.value ~/ breakEvery;
      final kind = round.isOdd ? BreakKind.memory : BreakKind.lightning;
      final studied = deck.sublist(0, nextLecture.value);
      final recent = studied.sublist(max(0, studied.length - breakEvery));
      final cards = kind == BreakKind.memory
          ? builder.memoryCards(recent)
          : null;
      final statements = kind == BreakKind.lightning
          ? builder.lightningStatements(studied)
          : null;
      if ((cards == null || cards.isEmpty) &&
          (statements == null || statements.isEmpty)) {
        appendLecture();
        return;
      }
      addSection(
        (id) => _BreakEntry(id, kind, cards: cards, statements: statements),
      );
    }

    void continueSession() {
      if (nextLecture.value >= deck.length) {
        finishSession();
      } else if (completed.value % breakEvery == 0) {
        appendBreak();
      } else {
        appendLecture();
      }
    }

    void handleAttempt(
      int sectionId,
      Lecture lecture, {
      required bool correct,
      String? pickedLectureId,
    }) {
      final firstAttempt = !hadWrong.value.contains(lecture.id);
      studyLog.recordAnswer(
        lectureId: lecture.id,
        correct: correct,
        firstAttempt: firstAttempt,
        pickedLectureId: correct ? null : pickedLectureId,
      );
      if (!correct) {
        hadWrong.value.add(lecture.id);
        if (!missed.value.contains(lecture)) missed.value.add(lecture);
        ref.read(mistakenLecturesProvider.notifier).addMistake(lecture.id);
        combo.value = 0;
      }
      // A section is answered with its first right pick, or with a wrong
      // pick when there is only one try.
      final question = sections.value
          .whereType<_LectureEntry>()
          .firstWhere((s) => s.id == sectionId)
          .question;
      final singleTry =
          question.mode == QuestionMode.swipe ||
          question.mode == QuestionMode.pairs;
      if (correct || singleTry) {
        solvedSections.value.add(sectionId);
        answered.value++;
        learned.value.add(lecture);
        if (correct && firstAttempt) {
          firstTryRight.value++;
          combo.value++;
          bestCombo.value = max(bestCombo.value, combo.value);
        }
      }
    }

    void handleLectureFinished(Lecture lecture) {
      ref
          .read(sessionProvider(lectureType).notifier)
          .markLectureCompleted(lecture.id);
      cardsCompleted.value++;
      completed.value++;
      continueSession();
    }

    void snap() {
      if (!scrollController.hasClients) return;
      final target = headerBottom;
      int? bestId;
      double? bestDistance;
      for (final MapEntry(key: id, value: key) in keys.value.entries) {
        final top = topOf(key);
        if (top == null) continue;
        final distance = top - target;
        if (bestDistance == null || distance.abs() < bestDistance.abs()) {
          bestId = id;
          bestDistance = distance;
        }
      }
      if (bestId == null || bestDistance == null) return;
      if (bestDistance.abs() <= viewportHeight * _kSnapReach) {
        if (bestDistance.abs() > 1) {
          animateTo(
            scrollController.offset + bestDistance,
            duration: _kSnapDuration,
          );
        }
        showTopic(bestId);
        return;
      }
      // Too far from a start to snap: name the section under the app bar.
      final covering = keys.value.entries
          .where((entry) => (topOf(entry.value) ?? double.infinity) <= target)
          .map((entry) => entry.key)
          .fold<int?>(
            null,
            (last, id) => last == null || id > last ? id : last,
          );
      if (covering != null) showTopic(covering);
    }

    useEffect(() {
      if (deck.isNotEmpty) appendLecture();
      return null;
    }, const []);

    final finished = sections.value.lastOrNull is _SummaryEntry;

    Widget buildSection(_Section section) => switch (section) {
      _LectureEntry(:final id, :final question) => LectureSectionView(
        question: question,
        onAttempt: ({required correct, pickedLectureId}) => handleAttempt(
          id,
          question.lecture,
          correct: correct,
          pickedLectureId: pickedLectureId,
        ),
        onFinished: () => handleLectureFinished(question.lecture),
        onGrow: revealEnd,
      ),
      _BreakEntry(kind: BreakKind.memory, :final cards) => MemoryBreakView(
        cards: cards!,
        onFinished: continueSession,
        onGrow: revealEnd,
      ),
      _BreakEntry(:final statements) => LightningRoundView(
        statements: statements!,
        onFinished: continueSession,
        onGrow: revealEnd,
      ),
      _SummaryEntry(:final recap) => SessionSummaryView(
        recap: recap,
        onJump: (lectureId) {
          final id = sectionOfLecture.value[lectureId];
          if (id != null) scrollToSection(id, announce: true);
        },
        onShare: () => RecapShareScreen.show(context, recap),
        onDone: () => context.popUntilPath(AppRoutes.reviewSelection.path),
      ),
    };

    return Stack(
      children: [
        const NoteBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                userScrolling.value = true;
                scrollTarget.value = null;
              } else if (notification is ScrollEndNotification &&
                  userScrolling.value) {
                userScrolling.value = false;
                WidgetsBinding.instance.addPostFrameCallback((_) => snap());
              }
              return false;
            },
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  title: Text(
                    lectureType.getLocalizedTitle(context),
                    style: context.textTheme.headlineSmall,
                  ),
                  pinned: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(child: ComboMeter(combo: combo.value)),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final section in sections.value)
                        KeyedSubtree(
                          key: keys.value[section.id],
                          child: buildSection(section),
                        ),
                      SizedBox(key: endKey, height: 1),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: finished ? 24 : viewportHeight * 0.55,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: headerBottom + 6,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: AnimatedOpacity(
                opacity: topicVisible.value ? 1 : 0,
                duration: topicVisible.value ? _kTopicFadeIn : _kTopicFadeOut,
                child: _TopicLabel(text: topic.value ?? ''),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small note of what the section at the top is about.
class _TopicLabel extends StatelessWidget {
  const _TopicLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: neo.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: neo.border, width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: kReviewFont,
          fontSize: 12,
          color: neo.onCard.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
