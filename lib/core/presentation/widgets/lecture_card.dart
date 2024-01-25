import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/core/extensions.dart';
import 'package:hikou/core/keys.dart';

class LectureCard extends HookWidget {
  const LectureCard(this.lecture, {super.key});
  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

    return GestureDetector(
      onTapDown: (_) => expanded.value = true,
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
                    visible: expanded.value,
                    maintainState: true,
                    maintainSize: true,
                    maintainAnimation: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(height: 12),
                        ...lecture.usages
                            .map(
                              (example) => Text(
                                example,
                                style: context.textTheme.bodyLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            )
                            .toList(),
                        SizedBox(height: 20),
                        ...lecture.examples
                            .map(
                              (example) => Text(
                                example,
                                style: context.textTheme.bodyLarge,
                              ),
                            )
                            .toList(),
                        SizedBox(height: 20),
                        ...lecture.translations
                            .map(
                              (example) => Text(
                                example,
                                style: context.textTheme.bodyLarge,
                              ),
                            )
                            .toList(),
                        SizedBox(height: 20),
                        ...(lecture.extras ?? [])
                            .map(
                              (example) => Text(
                                example,
                                style: context.textTheme.bodyLarge,
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
