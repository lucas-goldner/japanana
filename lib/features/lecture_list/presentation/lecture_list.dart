import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/router.dart';

class LectureList extends StatelessWidget {
  const LectureList(this.lectures, {super.key});
  final List<Lecture> lectures;

  void _navigateToLectureDetail(BuildContext context, Lecture lecture) =>
      context.push(AppRoutes.lectureDetail.path, extra: lecture);

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.lectureList,
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: ListWheelScrollView(
        itemExtent: 150,
        squeeze: 0.9,
        diameterRatio: 3,
        children: lectures.indexed.map(
          (lectureWithIndex) {
            final index = lectureWithIndex.$1;
            final lecture = lectureWithIndex.$2;

            return GestureDetector(
              onTap: () => _navigateToLectureDetail(context, lecture),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colorScheme.primaryContainer,
                    width: 2,
                  ),
                ),
                child: SizedBox(
                  height: 150,
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8, right: 12),
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
