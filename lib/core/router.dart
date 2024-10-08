import 'package:go_router/go_router.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/in_review/presentation/in_review.dart';
import 'package:japanana/features/lecture_detail/presentation/lecture_detail.dart';
import 'package:japanana/features/lecture_list/presentation/lecture_list.dart';
import 'package:japanana/features/review_selection/presentation/review_selection.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/review_setup/presentation/review_setup.dart';

enum AppRoutes {
  reviewSelection('/reviewSelection'),
  reviewSetup('/reviewSetup'),
  inReview('/inReview'),
  lectureList('/lectureList'),
  lectureDetail('/lectureDetail');

  const AppRoutes(this.path);
  final String path;
}

final router = GoRouter(
  restorationScopeId: 'router',
  initialLocation: AppRoutes.reviewSelection.path,
  routes: [
    GoRoute(
      path: AppRoutes.reviewSelection.path,
      builder: (context, state) => const ReviewSelection(),
    ),
    GoRoute(
      path: AppRoutes.reviewSetup.path,
      builder: (context, state) => ReviewSetup(state.extra as LectureType?),
    ),
    GoRoute(
      path: AppRoutes.inReview.path,
      builder: (context, state) =>
          InReview(state.extra as (LectureType?, ReviewSetupOptions?)?),
    ),
    GoRoute(
      path: AppRoutes.lectureList.path,
      builder: (context, state) => const LectureList(),
    ),
    GoRoute(
      path: AppRoutes.lectureDetail.path,
      builder: (context, state) => LectureDetail(state.extra! as Lecture),
    ),
  ],
);
