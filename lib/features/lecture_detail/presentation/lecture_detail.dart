import 'package:flutter/material.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/features/in_review/presentation/widgets/lecture_card_expandable_content.dart';

class LectureDetail extends StatelessWidget {
  const LectureDetail(this.lecture, {super.key});
  final Lecture lecture;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            lecture.title,
            style: context.textTheme.headlineLarge,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
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
                Column(
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
                    Column(
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
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
