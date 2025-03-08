import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/review_selection/presentation/widgets/app_name_banner.dart';
import 'package:japanana/features/review_selection/presentation/widgets/book_shelf.dart';
import 'package:japanana/features/review_selection/presentation/widgets/open_settings_button.dart';
import 'package:japanana/features/review_selection/presentation/widgets/open_statistics_button.dart';

class ReviewSelection extends ConsumerWidget {
  const ReviewSelection({super.key});

  Future<void> _fetchLectures(WidgetRef ref) async =>
      ref.read(lectureProvider.notifier).fetchLectures();

  // void _navigateToLectureList({
  //   required BuildContext context,
  // }) =>
  //     context.push(
  //       AppRoutes.lectureList.path,
  //     );

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const AppNameBanner(),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Select your Lecture',
                  style: context.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FutureBuilder<void>(
                future: _fetchLectures(ref),
                builder: (context, snapshot) {
                  final hasLecturesToRemember = ref
                      .watch(lectureProvider.notifier)
                      .hasLecturesInRememberChamper;
                  final lectureTypes = hasLecturesToRemember
                      ? LectureType.values.toList()
                      : (LectureType.values.toList()
                        ..remove(LectureType.remember));

                  return switch (snapshot.connectionState) {
                    ConnectionState.done => BookShelf(lectureTypes),
                    ConnectionState.none ||
                    ConnectionState.active ||
                    ConnectionState.waiting =>
                      const Center(child: CircularProgressIndicator())
                  };
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: const SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 32,
              right: 32,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: OpenSettingsButton(),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: OpenStatisticsButton(),
                ),
              ],
            ),
          ),
        ),
      );
}


// Content:
// FutureBuilder<void>(
//           future: _fetchLectures(ref),
//           builder: (context, snapshot) {
//             final hasLecturesToRemember = ref
//                 .watch(lectureProvider.notifier)
//                 .hasLecturesInRememberChamper;
//             final lectureTypes = hasLecturesToRemember
//                 ? LectureType.values.toList()
//                 : (LectureType.values.toList()..remove(LectureType.remember));

//             return switch (snapshot.connectionState) {
//               ConnectionState.done => ListView.separated(
//                   itemCount: lectureTypes.length,
//                   itemBuilder: (context, index) => ReviewSelectionItem(
//                     lectureTypes[index],
//                   ),
//                   separatorBuilder: (context, index) => const Divider(),
//                 ),
//               ConnectionState.none ||
//               ConnectionState.active ||
//               ConnectionState.waiting =>
//                 const Center(child: CircularProgressIndicator())
//             };
//           },
//         ),