import 'package:go_router/go_router.dart';
import 'package:hikou/features/in_review/presentation/in_review.dart';
import 'package:hikou/features/review_setup/presentation/review_setup.dart';

enum AppRoutes {
  reviewSetup("/reviewSetup"),
  inReview("/inReview");

  const AppRoutes(this.path);
  final String path;
}

final router = GoRouter(
  initialLocation: AppRoutes.reviewSetup.path,
  routes: [
    GoRoute(
      path: AppRoutes.reviewSetup.path,
      builder: (context, state) => ReviewSetup(),
    ),
    GoRoute(
      path: AppRoutes.inReview.path,
      builder: (context, state) => InReview(),
    ),
  ],
);
