import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/features/in_review/presentation/widgets/lecture_card_expandable_content.dart';

class LectureCard extends HookWidget {
  const LectureCard(this.lecture, {super.key});
  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(0);
    final focus = useFocusNode();

    return SelectionArea(
      focusNode: focus,
      child: GestureDetector(
        onTapDown: (_) => {
          if (expanded.value == 2) 2 else expanded.value++,
          focus.unfocus(),
        },
        child: Card(
          key: K.lectureCard,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key: K.lectureCardTitle,
                      lecture.title,
                      style: context.textTheme.headlineSmall,
                    ),
                    Visibility(
                      key: K.getReviewLectureCardExpandedContent(1),
                      visible: expanded.value >= 1,
                      maintainState: true,
                      maintainSize: true,
                      maintainAnimation: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 12),
                          LectureCardExpandableContent(
                            itemsToDisplay: lecture.usages,
                            label: context.l10n.usages,
                            upperPadding: lecture.usages.isNotEmpty,
                          ),
                          LectureCardExpandableContent(
                            itemsToDisplay: lecture.examples,
                            label: context.l10n.examples,
                            upperPadding: lecture.examples.isNotEmpty,
                          ),
                          Visibility(
                            key: K.getReviewLectureCardExpandedContent(2),
                            visible: expanded.value >= 2,
                            maintainState: true,
                            maintainSize: true,
                            maintainAnimation: true,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LectureCardExpandableContent(
                                  itemsToDisplay: lecture.translations,
                                  label: context.l10n.translations,
                                  upperPadding: lecture.translations.isNotEmpty,
                                ),
                                LectureCardExpandableContent(
                                  itemsToDisplay: lecture.extras ?? [],
                                  label: context.l10n.extras,
                                  upperPadding: lecture.extras != null ||
                                      (lecture.extras?.isNotEmpty ?? false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
