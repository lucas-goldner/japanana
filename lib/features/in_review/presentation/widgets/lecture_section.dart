import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/features/in_review/domain/review_question.dart';
import 'package:japanana/features/in_review/presentation/widgets/chat_message.dart';
import 'package:japanana/features/in_review/presentation/widgets/questions/questions.dart';
import 'package:japanana/features/in_review/presentation/widgets/review_widgets.dart';

const _kPromptDelay = Duration(milliseconds: 700);
const _kQuestionDelay = Duration(milliseconds: 1100);
const _kExamplesDelay = Duration(milliseconds: 600);
const _kNextExampleDelay = Duration(milliseconds: 250);
const _kFinishDelay = Duration(milliseconds: 500);

/// True once [delay] passed since the first build.
bool useDelayedFlag(Duration delay) {
  final passed = useState(delay == Duration.zero);
  useEffect(() {
    if (passed.value) return null;
    final timer = Timer(delay, () => passed.value = true);
    return timer.cancel;
  }, const []);
  return passed.value;
}

/// Calls [action] after [delay] unless the widget was disposed.
typedef Later = void Function(Duration delay, VoidCallback action);

Later useLater() {
  final timers = useRef(<Timer>[]);
  useEffect(
    () => () {
      for (final timer in timers.value) {
        timer.cancel();
      }
    },
    const [],
  );
  return (delay, action) => timers.value.add(Timer(delay, action));
}

/// One lecture: its question, then its examples to translate and extras.
/// Everything stays on screen afterwards, mistakes included.
class LectureSectionView extends HookWidget {
  const LectureSectionView({
    required this.question,
    required this.onAttempt,
    required this.onFinished,
    required this.onGrow,
    super.key,
  });

  final LectureQuestion question;
  final AttemptCallback onAttempt;
  final VoidCallback onFinished;

  /// Called after content was added at the bottom.
  final VoidCallback onGrow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final lecture = question.lecture;
    final showPrompt = useDelayedFlag(_kPromptDelay);
    final showQuestion = useDelayedFlag(_kQuestionDelay);
    final solved = useState(false);
    final messages = useState<List<ChatMessageData>>([]);
    final awaitingGuess = useState(false);
    final cursor = useRef(0);
    final later = useLater();
    final examples = useMemoized(
      () => [
        for (var i = 0; i < lecture.examples.length; i++)
          if (i != question.usedExample) i,
      ],
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => onGrow());
      return null;
    }, [showPrompt, showQuestion]);

    void add(String text, {required bool isUser}) {
      messages.value = [
        ...messages.value,
        ChatMessageData(text: text, isUser: isUser),
      ];
      WidgetsBinding.instance.addPostFrameCallback((_) => onGrow());
    }

    void finishWithExtras() {
      final extras = lecture.extras;
      if (extras != null && extras.isNotEmpty) {
        add(l10n.dontForgetAboutTheseCases, isUser: false);
        for (final extra in extras) {
          add(extra, isUser: false);
        }
      }
      later(_kFinishDelay, onFinished);
    }

    void showExample() {
      add(lecture.examples[examples[cursor.value]], isUser: false);
      awaitingGuess.value = true;
    }

    void handleSolved() {
      solved.value = true;
      later(_kExamplesDelay, () {
        if (examples.isEmpty) {
          finishWithExtras();
        } else {
          showExample();
        }
      });
    }

    void guess() {
      final index = examples[cursor.value];
      awaitingGuess.value = false;
      if (index < lecture.translations.length) {
        add(lecture.translations[index], isUser: true);
      }
      later(_kNextExampleDelay, () {
        cursor.value++;
        if (cursor.value < examples.length) {
          showExample();
        } else {
          finishWithExtras();
        }
      });
    }

    // Gap and pairs questions would give the answer away with the title.
    final hidesTitle =
        question.mode == QuestionMode.gap ||
        question.mode == QuestionMode.pairs;
    final prompt = switch (question.mode) {
      QuestionMode.choose => l10n.whichKindOfUsage,
      QuestionMode.swipe => l10n.reviewSwipePrompt(lecture.title),
      QuestionMode.gap => l10n.reviewGapPrompt,
      QuestionMode.meaning => l10n.reviewMeaningPrompt,
      QuestionMode.pairs => l10n.reviewPairsPrompt,
    };
    final questionView = switch (question.mode) {
      QuestionMode.choose => ChooseQuestionView(
        question: question,
        onAttempt: onAttempt,
        onSolved: handleSolved,
      ),
      QuestionMode.swipe => SwipeQuestionView(
        question: question,
        onAttempt: onAttempt,
        onSolved: handleSolved,
      ),
      QuestionMode.gap => GapQuestionView(
        question: question,
        onAttempt: onAttempt,
        onSolved: handleSolved,
      ),
      QuestionMode.meaning => MeaningQuestionView(
        question: question,
        onAttempt: onAttempt,
        onSolved: handleSolved,
      ),
      QuestionMode.pairs => PairsQuestionView(
        question: question,
        onAttempt: onAttempt,
        onSolved: handleSolved,
      ),
    };

    Widget bubble(String text, {bool isUser = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ChatMessage(
        text: text,
        isUser: isUser,
        index: 0,
        fontFamily: kReviewFont,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: hidesTitle && !solved.value ? '？' : lecture.title,
          label: question.mode.label(context),
        ),
        if (!hidesTitle) bubble(l10n.letsTalkAbout(lecture.title)),
        if (showPrompt) bubble(prompt),
        if (showQuestion)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: questionView,
          ),
        for (final message in messages.value)
          bubble(message.text, isUser: message.isUser),
        if (awaitingGuess.value)
          Padding(
            padding: const EdgeInsets.all(16),
            child: NeoButton(
              onPressed: guess,
              minHeight: 72,
              color: neo.accent,
              foregroundColor: neo.onAccent,
              shadowColor: neo.accentShadow,
              child: Text(
                l10n.tryToGuess.toUpperCase(),
                style: const TextStyle(
                  fontFamily: kReviewFont,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
