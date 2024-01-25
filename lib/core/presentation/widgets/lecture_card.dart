import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/core/extensions.dart';
import 'package:hikou/core/keys.dart';
import 'package:hikou/core/presentation/widgets/lecture_card_expandable_content.dart';

class LectureCard extends HookWidget {
  const LectureCard(this.lecture, {super.key});
  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(0);

    return GestureDetector(
      onTapDown: (_) => expanded.value == 2 ? 2 : expanded.value++,
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
                    key: K.lectureCardExpandedContent,
                    visible: expanded.value >= 1,
                    maintainState: true,
                    maintainSize: true,
                    maintainAnimation: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(height: 12),
                        LectureCardExpandableContent(
                          itemsToDisplay: lecture.usages,
                          label: context.l10n.usages,
                          upperPadding: lecture.usages.length != 0,
                        ),
                        LectureCardExpandableContent(
                          itemsToDisplay: lecture.examples,
                          label: context.l10n.examples,
                          upperPadding: lecture.examples.length != 0,
                        ),
                        Visibility(
                          key: K.lectureCardExpandedContent,
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
                                upperPadding: lecture.translations.length != 0,
                              ),
                              LectureCardExpandableContent(
                                itemsToDisplay: lecture.extras ?? [],
                                label: context.l10n.extras,
                                upperPadding: lecture.extras != null ||
                                    lecture.extras?.length != 0,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
