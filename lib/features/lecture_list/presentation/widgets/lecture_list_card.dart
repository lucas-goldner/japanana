import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/router.dart';

class LectureListCard extends StatelessWidget {
  const LectureListCard({
    required this.lecture,
    required this.lectureIndex,
    super.key,
  });

  final Lecture lecture;
  final int lectureIndex;

  void _navigateToLectureDetail(BuildContext context, Lecture lecture) =>
      context.push(AppRoutes.lectureDetail.path, extra: lecture);

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width;

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
                  "$lectureIndex. ${lecture.title}",
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
  }
}
