import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/fade_in_from_bottom.dart';
import 'package:japanana/features/review_selection/presentation/widgets/app_name_banner.dart';
import 'package:japanana/features/review_selection/presentation/widgets/book_shelf.dart';
import 'package:japanana/features/review_selection/presentation/widgets/open_settings_button.dart';
import 'package:japanana/features/review_selection/presentation/widgets/open_statistics_button.dart';
import 'package:japanana/core/router.dart';
import 'package:go_router/go_router.dart';

class ReviewSelection extends HookConsumerWidget {
  const ReviewSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appNameBannerAnimationCompleted = useState(false);

    void selectLecture(LectureType lecture) => print(lecture);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _AnimatedAppNameBanner(
              onAnimationCompleted: () => {
                appNameBannerAnimationCompleted.value = true,
              },
            ),
            const SizedBox(height: 80),
            Visibility(
              visible: appNameBannerAnimationCompleted.value,
              child: const _AnimatedReviewSelectionTitle(),
            ),
            const SizedBox(height: 32),
            Visibility(
              visible: appNameBannerAnimationCompleted.value,
              child: _AnimatedBookShelf(
                onBookSelect: selectLecture,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 32,
            right: 32,
            bottom: 20,
          ),
          child: Visibility(
            visible: appNameBannerAnimationCompleted.value,
            child: const OptionsRow(),
          ),
        ),
      ),
    );
  }
}

class _AnimatedAppNameBanner extends HookConsumerWidget {
  const _AnimatedAppNameBanner({
    required this.onAnimationCompleted,
  });

  final void Function() onAnimationCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fadeController = useAnimationController(
      duration: const Duration(seconds: 1),
    );
    final translateController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    final screenSize = MediaQuery.of(context).size;

    final moveAnimation = Tween<Offset>(
      begin: Offset(
        -screenSize.width * 0.35,
        screenSize.height * 0.5,
      ),
      end: Offset(0, screenSize.height * 0.05),
    ).animate(
      CurvedAnimation(parent: translateController, curve: Curves.easeInOut),
    );

    final scaleAnimation = Tween<double>(
      begin: 4,
      end: 1,
    ).animate(
      CurvedAnimation(parent: translateController, curve: Curves.easeInOut),
    );

    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: fadeController, curve: Curves.easeInOut));

    useEffect(
      () {
        fadeController.forward().then(
              (_) => translateController.forward().then(
                    (_) => onAnimationCompleted(),
                  ),
            );
        return null;
      },
      [],
    );

    return AnimatedBuilder(
      animation: translateController,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          moveAnimation.value.dx,
          moveAnimation.value.dy,
        ),
        child: Transform.scale(
          scale: scaleAnimation.value,
          child: AnimatedBuilder(
            animation: fadeController,
            builder: (context, child) => Opacity(
              opacity: fadeAnimation.value,
              child: const AppNameBanner(),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedReviewSelectionTitle extends StatelessWidget {
  const _AnimatedReviewSelectionTitle();

  @override
  Widget build(BuildContext context) => FadeInFromBottom(
        duration: const Duration(seconds: 1),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Select your Lecture',
            style: context.textTheme.displayLarge?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}

class _AnimatedBookShelf extends ConsumerStatefulWidget {
  const _AnimatedBookShelf({
    required this.onBookSelect,
  });

  final void Function(LectureType lecture) onBookSelect;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __AnimatedBookShelfState();
}

class __AnimatedBookShelfState extends ConsumerState<_AnimatedBookShelf> {
  late final Future<void> lecturesFuture;

  Future<void> _fetchLectures(WidgetRef ref) async =>
      ref.read(lectureProvider.notifier).fetchLectures();

  @override
  void initState() {
    lecturesFuture = _fetchLectures(ref);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: lecturesFuture,
        builder: (context, snapshot) {
          final hasLecturesToRemember =
              ref.watch(lectureProvider.notifier).hasLecturesInRememberChamper;
          final lectureTypes = hasLecturesToRemember
              ? LectureType.values.toList()
              : (LectureType.values.toList()..remove(LectureType.remember));

          return switch (snapshot.connectionState) {
            ConnectionState.done => Flexible(
                child: FadeInFromBottom(
                  duration: const Duration(seconds: 1),
                  delay: const Duration(milliseconds: 250),
                  child: BookShelf(
                    lectureTypes,
                    onBookSelect: widget.onBookSelect,
                  ),
                ),
              ),
            ConnectionState.none ||
            ConnectionState.active ||
            ConnectionState.waiting =>
              const SizedBox()
          };
        },
      );
}

class OptionsRow extends StatelessWidget {
  const OptionsRow({super.key});

  @override
  Widget build(BuildContext context) => FadeInFromBottom(
        duration: const Duration(seconds: 1),
        delay: const Duration(milliseconds: 500),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: OpenSettingsButton(),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.statistics.path),
                child: const OpenStatisticsButton(),
              ),
            ),
          ],
        ),
      );
}
