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

  Future<void> _fetchLectures(WidgetRef ref) async =>
      ref.read(lectureProvider.notifier).fetchLectures();

  void _navigateToLectureList({
    required BuildContext context,
  }) =>
      context.push(
        AppRoutes.lectureList.path,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
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
                onPressed: () => _navigateToLectureList(
                  context: context,
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder<void>(
          future: _fetchLectures(ref),
          builder: (context, snapshot) {
            final hasLecturesToRemember = ref
                .watch(lectureProvider.notifier)
                .hasLecturesInRememberChamper;
            final lectureTypes = hasLecturesToRemember
                ? LectureType.values.toList()
                : (LectureType.values.toList()..remove(LectureType.remember));

            return switch (snapshot.connectionState) {
              ConnectionState.done => ListView.separated(
                  itemCount: lectureTypes.length,
                  itemBuilder: (context, index) => ReviewSelectionItem(
                    lectureTypes[index],
                  ),
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ConnectionState.none ||
              ConnectionState.active ||
              ConnectionState.waiting =>
                const Center(child: CircularProgressIndicator())
            };
          },
        ),
      );
}
