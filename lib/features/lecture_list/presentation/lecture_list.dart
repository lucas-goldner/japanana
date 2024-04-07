import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';

class LectureList extends HookWidget {
  const LectureList(this.lectures, {super.key});
  final List<Lecture> lectures;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width;
    final cardTextWidth = cardWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.lectureList,
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: ListWheelScrollView(
        itemExtent: 100,
        squeeze: 0.9,
        diameterRatio: 3,
        children: lectures.indexed.map(
          (lectureWithIndex) {
            final index = lectureWithIndex.$1;
            final lecture = lectureWithIndex.$2;

            return DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.inversePrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                height: 100,
                width: cardWidth,
                child: SizedBox(
                  width: cardTextWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$index. ${lecture.title}",
                          style: context.textTheme.headlineLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Divider(),
                        Text(
                          "${lecture.usages.join(", ")}",
                          style: context.textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
