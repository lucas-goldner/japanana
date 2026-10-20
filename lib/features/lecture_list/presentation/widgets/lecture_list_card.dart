import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
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
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.fromLTRB(16, 8, 20, 16),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        decoration: context.neo.decoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$lectureIndex. ${lecture.title}',
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.neo.onCard,
                fontFamily: context.textTheme.notoSansJPFont,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Divider(color: context.neo.border, thickness: 2),
            Text(
              lecture.usages.join(', '),
              style: context.textTheme.titleMedium?.copyWith(
                color: context.neo.onCard,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
