import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/features/in_review/presentation/widgets/lecture_card_expandable_content.dart';

class LectureDetail extends ConsumerWidget {
  const LectureDetail(this.lecture, {super.key});
  final Lecture lecture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rememberedLectures = ref.watch(lectureProvider);

    return Scaffold(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    key: K.lectureCardTitle,
                    lecture.title,
                    style: context.textTheme.headlineSmall,
                  ),
                  if (rememberedLectures
                      .where((element) => element.id == lecture.id)
                      .first
                      .types
                      .contains(LectureType.remember))
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(lectureProvider.notifier)
                            .banishLectureFromRememberChamber(
                              lecture.id,
                            );
                      },
                      label: Text(context.l10n.forget),
                      icon: const Icon(Icons.remove_circle),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(lectureProvider.notifier)
                            .putLectureInRememberChamber(
                              lecture.id,
                            );
                      },
                      label: Text(context.l10n.remember),
                      icon: const Icon(Icons.save),
                    ),
                ],
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
}
