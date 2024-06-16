import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/review_selection/presentation/widgets/review_selection_item.dart';

class ReviewSelection extends ConsumerWidget {
  const ReviewSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Builder(builder: (context) {
        final lectures = ref.watch(lectureProvider);
        return _ReviewSelection(lectures);
      });
}

class _ReviewSelection extends StatefulWidget {
  const _ReviewSelection(this.lectures);
  final List<Lecture> lectures;

  @override
  State<_ReviewSelection> createState() => _ReviewSelectionState();
}

class _ReviewSelectionState extends State<_ReviewSelection> {
  void _navigateToLectureList(BuildContext context) => context.push(
        AppRoutes.lectureList.path,
        extra: widget.lectures,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            key: K.reviewSelectionAppTitle,
            context.l10n.appTitle,
            style: context.textTheme.headlineLarge,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: IconButton(
                icon: Icon(
                  Icons.list_alt_outlined,
                  color: context.colorScheme.secondaryContainer,
                ),
                onPressed: () => _navigateToLectureList(context),
              ),
            ),
          ],
        ),
        body: ListView.separated(
          itemCount: LectureType.values.length,
          itemBuilder: (context, index) => ReviewSelectionItem(
            LectureType.values[index],
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      );
}
