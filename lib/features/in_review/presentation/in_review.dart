import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/core/presentation/widgets/scribble_border_button.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/in_review/presentation/widgets/chat_message.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';

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
    final lectureType = reviewOption?.$1 ?? LectureType.writing;
    final options = reviewOption?.$2 ??
        const ReviewSetupOptions(
          randomize: false,
          repeatOnFalseCard: false,
        );

    final lectures = ref
        .read(lectureProvider.notifier)
        .getLecturesForReviewOption(lectureType);

    final shuffledLectures = useState<List<Lecture>>(() {
      final list = [...lectures];
      if (options.randomize) list.shuffle();
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

    useEffect(
      () {
        if (shuffledLectures.value.isNotEmpty) {
          messages.value = [
            ChatMessageData(
              text: "Let's talk about ${shuffledLectures.value[0].title}",
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
      if (selectedUsageIndex.value != null) return;

      final currentLecture = shuffledLectures.value[currentLectureIndex.value];
      final selectedUsage = usageOptions[index];
      final isCorrect = currentLecture.usages.contains(selectedUsage);

      if (!isCorrect) {
        wrongSelections.value = {...wrongSelections.value, index};
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

      Future.delayed(const Duration(milliseconds: 1000), () {
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
            addMessage("Don't forget about these cases:", isUser: false);
            for (final extra in currentLecture.extras!) {
              Future.delayed(const Duration(milliseconds: 100), () {
                addMessage(extra, isUser: false);
              });
            }
          }

          Future.delayed(const Duration(seconds: 2), () {
            if (currentLectureIndex.value < shuffledLectures.value.length - 1) {
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

              addMessage(
                "Let's talk about ${nextLecture.title}",
                isUser: false,
              );

              // Regenerate usage options for new lecture
              final newLecture =
                  shuffledLectures.value[currentLectureIndex.value];
              final options = <String>[];
              final usedUsages = <String>{};

              if (newLecture.usages.isNotEmpty) {
                final correctUsage = newLecture.usages[
                    DateTime.now().millisecondsSinceEpoch %
                        newLecture.usages.length];
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
              allOtherUsages.shuffle();
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

              options.shuffle();
              usageOptions.value = options;
            } else {
              currentStage.value = _ReviewStage.finished;
            }
          });
        }
      });
    }

    void generateUsageOptions() {
      if (currentStage.value == _ReviewStage.intro) {
        currentStage.value = _ReviewStage.usage;
        addMessage('Which kind of usage?', isUser: false);
      }
    }

    useEffect(
      () {
        if (currentStage.value == _ReviewStage.intro) {
          Future.delayed(const Duration(seconds: 1), generateUsageOptions);
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
          final correctUsage = currentLecture.usages[
              DateTime.now().millisecondsSinceEpoch %
                  currentLecture.usages.length];
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
        allOtherUsages.shuffle();
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
        options.shuffle();
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
                ),
                floating: true,
                scrolledUnderElevation: 4,
                elevation: 4,
                backgroundColor: context.colorScheme.secondary,
                surfaceTintColor: context.colorScheme.secondary,
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

                          return Stack(
                            children: [
                              ScribbleBorderButton(
                                onPressed: () => handleUsageSelection(
                                  index,
                                  usageOptions.value,
                                ),
                                minHeight: 100,
                                borderColor: isWrong
                                    ? Colors.red
                                    : isCorrect
                                        ? Colors.green
                                        : Colors.black,
                                fontFamily: context.textTheme.notoSansJPFont,
                                child: Container(
                                  color: isWrong
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : isCorrect
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    usageOptions.value[index],
                                    style: isWrong
                                        ? context.textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          )
                                        : isCorrect
                                            ? context.textTheme.bodyLarge
                                                ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              )
                                            : null, // Use default theme style
                                  ),
                                ),
                              ),
                              if (isWrong) const _MistakeMarker(),
                            ],
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
                    child: ScribbleBorderButton(
                      onPressed: handleGuessTranslation,
                      minHeight: 100,
                      fontFamily: context.textTheme.notoSansJPFont,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Try to guess',
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                            context.l10n.congratsOnFinising(
                              lectureType.getLocalizedTitle(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ScribbleBorderButton(
                            key: K.startNextReviewButton,
                            onPressed: () => context.popUntilPath(
                              AppRoutes.reviewSelection.path,
                            ),
                            minHeight: 80,
                            fontFamily: context.textTheme.notoSansJPFont,
                            child: Text(
                              context.l10n.startNextReview.toUpperCase(),
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
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
  Widget build(BuildContext context) => Positioned(
        top: 6,
        right: 6,
        child: Stack(
          children: [
            Icon(
              Icons.close,
              color: context.colorScheme.primary,
              size: 60,
            ),
            Positioned(
              top: 6,
              left: 6,
              child: Icon(
                Icons.close,
                color: context.colorScheme.error,
                size: 48,
              ),
            ),
          ],
        ),
      );
}
