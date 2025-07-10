import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';

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
    final messages = useState<List<_ChatMessage>>([]);
    final scrollController = useScrollController();
    final usageOptions = useState<List<String>>([]);

    useEffect(
      () {
        if (shuffledLectures.value.isNotEmpty) {
          messages.value = [
            _ChatMessage(
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
        _ChatMessage(text: text, isUser: isUser),
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
              
              // If not enough usages from other lectures, use current lecture's usages
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
        
        // If not enough usages from other lectures, use current lecture's usages
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lectureType.getLocalizedTitle(context),
          style: context.textTheme.headlineSmall,
        ),
      ),
      body: Stack(
        children: [
          const NoteBackground(),
          if (currentStage.value == _ReviewStage.finished)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.congratsOnFinising(
                        lectureType.getLocalizedTitle(context),
                      ),
                      style: context.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      key: K.startNextReviewButton,
                      onPressed: () =>
                          context.popUntilPath(AppRoutes.reviewSelection.path),
                      child: Text(
                        context.l10n.startNextReview.toUpperCase(),
                        style: context.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.value.length,
                    itemBuilder: (context, index) {
                      final message = messages.value[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color:
                                  message.isUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (currentStage.value == _ReviewStage.usage &&
                    selectedUsageIndex.value == null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(
                        usageOptions.value.length,
                        (index) {
                          final isWrong = wrongSelections.value.contains(index);
                          final isCorrect = selectedUsageIndex.value == index;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => handleUsageSelection(
                                  index,
                                  usageOptions.value,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isWrong
                                      ? Colors.red
                                      : isCorrect
                                          ? Colors.green
                                          : null,
                                ),
                                child: Text(
                                  usageOptions.value[index],
                                  style: TextStyle(
                                    color: isWrong || isCorrect
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (currentStage.value == _ReviewStage.examples &&
                    !showTranslation.value)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: handleGuessTranslation,
                      child: const Text('Try to guess'),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

enum _ReviewStage {
  intro,
  usage,
  examples,
  extras,
  finished,
}

class _ChatMessage {
  _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}
