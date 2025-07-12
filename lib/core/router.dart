import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/in_review/presentation/in_review.dart';
import 'package:japanana/features/lecture_detail/presentation/lecture_detail.dart';
import 'package:japanana/features/lecture_list/presentation/lecture_list.dart';
import 'package:japanana/features/review_selection/presentation/review_selection.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/review_setup/presentation/review_setup.dart';
import 'package:japanana/features/statistics/presentation/statistics.dart';

enum AppRoutes {
  reviewSelection('/reviewSelection'),
  reviewSetup('/reviewSetup'),
  inReview('/inReview'),
  lectureList('/lectureList'),
  lectureDetail('/lectureDetail'),
  statistics('/statistics');

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
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: ReviewSetup(state.extra as LectureType?),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.inReview.path,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: InReview(state.extra as (LectureType?, ReviewSetupOptions?)?),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurveTween(curve: Curves.easeInCubic).animate(animation),
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.lectureList.path,
      builder: (context, state) => const LectureList(),
    ),
    GoRoute(
      path: AppRoutes.lectureDetail.path,
      builder: (context, state) => LectureDetail(state.extra! as Lecture),
    ),
    GoRoute(
      path: AppRoutes.statistics.path,
      builder: (context, state) => const Statistics(),
    ),
  ],
);
