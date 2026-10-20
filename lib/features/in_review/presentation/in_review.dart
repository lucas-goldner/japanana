import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/random_provider.dart';
import 'package:japanana/core/application/statistics_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/in_review/presentation/widgets/chat_message.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/session/application/session_provider.dart';
import 'package:japanana/features/statistics/application/study_log_provider.dart';

const _kButtonAnimationDuration = Duration(milliseconds: 900);
const _kButtonAnimationDelay = 0.2;
const _kButtonSlideDistance = 80.0;

enum _ReviewStage {
  intro,
  usage,
  examples,
  extras,
  finished,
}

class InReview extends HookConsumerWidget {
  const InReview(this.reviewOption, {super.key});
  final (LectureType?, ReviewSetupOptions?)? reviewOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final existingSession =
        ref.watch(sessionProvider(reviewOption?.$1 ?? LectureType.writing));
    final lectureType =
        existingSession?.lectureType ?? reviewOption?.$1 ?? LectureType.writing;
    final options = existingSession?.options ??
        reviewOption?.$2 ??
        const ReviewSetupOptions(
          randomize: false,
          repeatOnFalseCard: false,
        );

    final lectures = ref
        .read(lectureProvider.notifier)
        .getLecturesForReviewOption(lectureType);
    final random = ref.read(randomProvider);

    final shuffledLectures = useState<List<Lecture>>(() {
      final list = [...lectures];
      if (existingSession?.completedLectureIds.isNotEmpty ?? false) {
        list.removeWhere(
          (lecture) =>
              existingSession!.completedLectureIds.contains(lecture.id),
        );
      }
      if (options.randomize) list.shuffle(random);
      return list;
    }());

    final currentLectureIndex = useState(0);
    final currentStage = useState(_ReviewStage.intro);
    final selectedUsageIndex = useState<int?>(null);
    final wrongSelections = useState<Set<int>>({});
    final currentExampleIndex = useState(0);
    final showTranslation = useState(false);
    final messages = useState<List<ChatMessageData>>([]);
    final scrollController = useScrollController();
    final usageOptions = useState<List<String>>([]);
    final buttonAnimationController = useAnimationController(
      duration: _kButtonAnimationDuration,
    );
    final studyLog = ref.read(studyLogProvider.notifier);
    final cardsCompleted = useRef(0);

    // Record the session when leaving the review screen.
    useEffect(
      () {
        final start = ref.read(clockProvider)();
        return () {
          if (cardsCompleted.value > 0) {
            studyLog.recordSession(
              start: start,
              cardsCompleted: cardsCompleted.value,
            );
          }
        };
      },
      [],
    );

    useEffect(
      () {
        if (shuffledLectures.value.isNotEmpty) {
          messages.value = [
            ChatMessageData(
              text: l10n.letsTalkAbout(shuffledLectures.value[0].title),
              isUser: false,
            ),
          ];
        }
        return null;
      },
      [],
    );

    void addMessage(String text, {required bool isUser}) {
      messages.value = [
        ...messages.value,
        ChatMessageData(text: text, isUser: isUser),
      ];
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    void handleUsageSelection(int index, List<String> usageOptions) {
      // Picking an option that was already marked wrong changes nothing.
      if (selectedUsageIndex.value != null ||
          wrongSelections.value.contains(index)) {
        return;
      }

      final currentLecture = shuffledLectures.value[currentLectureIndex.value];
      final selectedUsage = usageOptions[index];
      final isCorrect = currentLecture.usages.contains(selectedUsage);

      studyLog.recordAnswer(
        lectureId: currentLecture.id,
        correct: isCorrect,
        firstAttempt: wrongSelections.value.isEmpty,
        pickedLectureId: isCorrect
            ? null
            : ref
                .read(lectureProvider)
                .where((lecture) => lecture.usages.contains(selectedUsage))
                .firstOrNull
                ?.id,
      );

      if (!isCorrect) {
        wrongSelections.value = {...wrongSelections.value, index};
        // Track the mistake
        ref
            .read(mistakenLecturesProvider.notifier)
            .addMistake(currentLecture.id);
      } else {
        selectedUsageIndex.value = index;
        addMessage(selectedUsage, isUser: true);

        Future.delayed(const Duration(milliseconds: 500), () {
          currentStage.value = _ReviewStage.examples;
          showTranslation.value = false;

          if (currentLecture.examples.isNotEmpty) {
            addMessage(currentLecture.examples[0], isUser: false);
          }
        });
      }
    }

    void handleGuessTranslation() {
      final currentLecture = shuffledLectures.value[currentLectureIndex.value];
      showTranslation.value = true;

      if (currentExampleIndex.value < currentLecture.translations.length) {
        addMessage(
          currentLecture.translations[currentExampleIndex.value],
          isUser: true,
        );
      }

      Future.delayed(const Duration(milliseconds: 250), () {
        if (currentExampleIndex.value < currentLecture.examples.length - 1) {
          currentExampleIndex.value++;
          showTranslation.value = false;
          addMessage(
            currentLecture.examples[currentExampleIndex.value],
            isUser: false,
          );
        } else {
          currentStage.value = _ReviewStage.extras;

          if (currentLecture.extras != null &&
              currentLecture.extras!.isNotEmpty) {
            final dontForgetMessage = l10n.dontForgetAboutTheseCases;
            addMessage(dontForgetMessage, isUser: false);
            for (final extra in currentLecture.extras!) {
              Future.delayed(const Duration(milliseconds: 100), () {
                addMessage(extra, isUser: false);
              });
            }
          }

          Future.delayed(const Duration(milliseconds: 500), () {
            if (currentLectureIndex.value < shuffledLectures.value.length - 1) {
              // Mark current lecture as completed
              final completedLecture =
                  shuffledLectures.value[currentLectureIndex.value];
              ref
                  .read(sessionProvider(lectureType).notifier)
                  .markLectureCompleted(completedLecture.id);
              cardsCompleted.value++;

              currentLectureIndex.value++;
              currentStage.value = _ReviewStage.intro;
              selectedUsageIndex.value = null;
              wrongSelections.value = {};
              currentExampleIndex.value = 0;
              showTranslation.value = false;

              final nextLecture =
                  shuffledLectures.value[currentLectureIndex.value];

              // Add separator before new lecture
              messages.value = [
                ...messages.value,
                ChatMessageData(
                  text: nextLecture.title,
                  isUser: false,
                  isSeparator: true,
                ),
              ];

              final letsTalkMessage = l10n.letsTalkAbout(nextLecture.title);
              addMessage(
                letsTalkMessage,
                isUser: false,
              );

              // Regenerate usage options for new lecture
              final newLecture =
                  shuffledLectures.value[currentLectureIndex.value];
              final options = <String>[];
              final usedUsages = <String>{};

              if (newLecture.usages.isNotEmpty) {
                final correctUsage = newLecture
                    .usages[random.nextInt(newLecture.usages.length)];
                options.add(correctUsage);
                usedUsages.add(correctUsage);
              }

              final otherLectures = shuffledLectures.value
                  .where((l) => l.id != newLecture.id)
                  .toList();

              // Collect all possible usages from other lectures
              final allOtherUsages = <String>[];
              for (final lecture in otherLectures) {
                allOtherUsages.addAll(lecture.usages);
              }

              // If not enough usages from other lectures, use current's
              if (allOtherUsages.isEmpty) {
                allOtherUsages.addAll(newLecture.usages);
              }

              // Shuffle and add unique usages
              allOtherUsages.shuffle(random);
              for (final usage in allOtherUsages) {
                if (options.length >= 4) break;
                if (!usedUsages.contains(usage)) {
                  options.add(usage);
                  usedUsages.add(usage);
                }
              }

              // If still not enough options, duplicate some
              while (options.length < 4 && options.isNotEmpty) {
                options.add(options[options.length % options.length]);
              }

              options.shuffle(random);
              usageOptions.value = options;
            } else {
              // Mark final lecture as completed
              final completedLecture =
                  shuffledLectures.value[currentLectureIndex.value];
              ref
                  .read(sessionProvider(lectureType).notifier)
                  .markLectureCompleted(completedLecture.id);
              cardsCompleted.value++;

              currentStage.value = _ReviewStage.finished;

              // Clear session when review is finished
              ref.read(sessionProvider(lectureType).notifier).clearSession();
            }
          });
        }
      });
    }

    void generateUsageOptions() {
      if (currentStage.value == _ReviewStage.intro) {
        currentStage.value = _ReviewStage.usage;
        addMessage(l10n.whichKindOfUsage, isUser: false);
      }
    }

    useEffect(
      () {
        if (currentStage.value == _ReviewStage.intro) {
          Future.delayed(const Duration(seconds: 1), generateUsageOptions);
        } else if (currentStage.value == _ReviewStage.usage) {
          buttonAnimationController.forward(from: 0);
        }
        return null;
      },
      [currentStage.value],
    );

    final currentLecture =
        currentLectureIndex.value < shuffledLectures.value.length
            ? shuffledLectures.value[currentLectureIndex.value]
            : null;

    // Initialize usage options when current lecture changes
    useEffect(
      () {
        if (currentLecture == null || shuffledLectures.value.isEmpty) {
          usageOptions.value = [];
          return null;
        }

        final options = <String>[];
        final usedUsages = <String>{};

        // Add one correct usage from current lecture
        if (currentLecture.usages.isNotEmpty) {
          final correctUsage = currentLecture
              .usages[random.nextInt(currentLecture.usages.length)];
          options.add(correctUsage);
          usedUsages.add(correctUsage);
        }

        // Add 3 random usages from other lectures
        final otherLectures = shuffledLectures.value
            .where((l) => l.id != currentLecture.id)
            .toList();

        // Collect all possible usages from other lectures
        final allOtherUsages = <String>[];
        for (final lecture in otherLectures) {
          allOtherUsages.addAll(lecture.usages);
        }

        // If not enough usages from other lectures, use current's
        if (allOtherUsages.isEmpty) {
          allOtherUsages.addAll(currentLecture.usages);
        }

        // Shuffle and add unique usages
        allOtherUsages.shuffle(random);
        for (final usage in allOtherUsages) {
          if (options.length >= 4) break;
          if (!usedUsages.contains(usage)) {
            options.add(usage);
            usedUsages.add(usage);
          }
        }

        // If still not enough options, duplicate some
        while (options.length < 4 && options.isNotEmpty) {
          options.add(options[options.length % options.length]);
        }

        // Shuffle the options
        options.shuffle(random);
        usageOptions.value = options;
        return null;
      },
      [currentLectureIndex.value],
    );

    return Stack(
      children: [
        const NoteBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                title: Text(
                  lectureType.getLocalizedTitle(context),
                  style: context.textTheme.headlineSmall,
                ),
                floating: true,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final message = messages.value[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ChatMessage(
                        text: message.text,
                        isUser: message.isUser,
                        index: index,
                        isSeparator: message.isSeparator,
                        fontFamily: context.textTheme.notoSansJPFont,
                      ),
                    );
                  },
                  childCount: messages.value.length,
                ),
              ),
              if (currentStage.value == _ReviewStage.usage &&
                  selectedUsageIndex.value == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(
                        usageOptions.value.length,
                        (index) {
                          final isWrong = wrongSelections.value.contains(index);
                          final isCorrect = selectedUsageIndex.value == index;

                          return AnimatedBuilder(
                            animation: buttonAnimationController,
                            builder: (context, child) {
                              final delay = index * _kButtonAnimationDelay;
                              final animationValue =
                                  ((buttonAnimationController.value - delay) /
                                          (1 - delay))
                                      .clamp(0.0, 1.0);
                              return Opacity(
                                opacity: animationValue,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    _kButtonSlideDistance *
                                        (1 - animationValue),
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  NeoButton(
                                    onPressed: () => handleUsageSelection(
                                      index,
                                      usageOptions.value,
                                    ),
                                    minHeight: 80,
                                    color: isWrong
                                        ? neo.wrongFill
                                        : isCorrect
                                            ? neo.correctFill
                                            : null,
                                    foregroundColor: isWrong || isCorrect
                                        ? neo.onFeedback
                                        : null,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        usageOptions.value[index],
                                        style: TextStyle(
                                          fontFamily:
                                              context.textTheme.notoSansJPFont,
                                          fontSize: 16,
                                          decoration: isWrong
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationThickness: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isWrong) const _MistakeMarker(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              if (currentStage.value == _ReviewStage.examples &&
                  !showTranslation.value)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: NeoButton(
                      onPressed: handleGuessTranslation,
                      minHeight: 80,
                      color: neo.accent,
                      foregroundColor: neo.onAccent,
                      shadowColor: neo.accentShadow,
                      child: Text(
                        l10n.tryToGuess.toUpperCase(),
                        style: TextStyle(
                          fontFamily: context.textTheme.notoSansJPFont,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              if (currentStage.value == _ReviewStage.finished)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.congratsOnFinising(
                              lectureType.getLocalizedTitle(context),
                            ),
                            textAlign: TextAlign.center,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 28),
                          NeoButton(
                            key: K.startNextReviewButton,
                            onPressed: () => context.popUntilPath(
                              AppRoutes.reviewSelection.path,
                            ),
                            minHeight: 72,
                            color: neo.accent,
                            foregroundColor: neo.onAccent,
                            shadowColor: neo.accentShadow,
                            child: Text(
                              l10n.startNextReview.toUpperCase(),
                              style: TextStyle(
                                fontFamily: context.textTheme.notoSansJPFont,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MistakeMarker extends StatelessWidget {
  const _MistakeMarker();

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Positioned(
      top: -12,
      right: -8,
      child: Transform.rotate(
        angle: 0.2,
        child: Container(
          width: 40,
          height: 40,
          decoration: neo.decoration(
            color: context.colorScheme.error,
            shape: BoxShape.circle,
          ).copyWith(
            boxShadow: [
              BoxShadow(color: neo.shadow, offset: const Offset(3, 3)),
            ],
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
