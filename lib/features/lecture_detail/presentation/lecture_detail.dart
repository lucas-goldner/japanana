import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 20, 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: context.neo.decoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      key: K.lectureCardTitle,
                      lecture.title,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontFamily: context.textTheme.notoSansJPFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (rememberedLectures
                      .where((element) => element.id == lecture.id)
                      .first
                      .types
                      .contains(LectureType.remember))
                    NeoButton(
                      onPressed: () {
                        ref
                            .read(lectureProvider.notifier)
                            .banishLectureFromRememberChamber(
                              lecture.id,
                            );
                      },
                      minHeight: 44,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      color: context.neo.wrongFill,
                      foregroundColor: context.neo.onFeedback,
                      shadowColor: context.neo.accentShadow,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark_remove,
                            size: 20,
                            color: context.neo.onFeedback,
                          ),
                          const SizedBox(width: 6),
                          Text(context.l10n.forget),
                        ],
                      ),
                    )
                  else
                    NeoButton(
                      onPressed: () {
                        ref
                            .read(lectureProvider.notifier)
                            .putLectureInRememberChamber(
                              lecture.id,
                            );
                      },
                      minHeight: 44,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      color: context.neo.accent,
                      foregroundColor: context.neo.onAccent,
                      shadowColor: context.neo.accentShadow,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark_add,
                            size: 20,
                            color: context.neo.onAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(context.l10n.remember),
                        ],
                      ),
                    ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 24,
                    thickness: 2,
                    color: context.neo.border,
                  ),
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
