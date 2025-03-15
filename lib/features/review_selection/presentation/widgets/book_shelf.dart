import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/router.dart';

part 'book.dart';

class BookShelf extends StatefulWidget {
  const BookShelf(
    this.lectureTypes, {
    required this.onBookSelect,
    super.key,
  });

  final List<LectureType> lectureTypes;
  final void Function(LectureType lecture) onBookSelect;

  @override
  State<BookShelf> createState() => _BookShelfState();
}

class _BookShelfState extends State<BookShelf> {
  static const double fixedHeight = 200;
  static const double verticalPadding = 24;
  static const double spineWidth = fixedHeight * 0.09;
  static const double coverWidth = fixedHeight * 0.7;

  @override
  Widget build(BuildContext context) => _BookCollection(
        books: List.generate(
          widget.lectureTypes.length,
          (index) {
            final type = widget.lectureTypes[index];
            final colors = context.booksTheme.lectureTypeColors[type];
            return BookData(
              lectureType: type,
              primaryColor: colors?.primary ?? Colors.black,
              secondaryColor: colors?.secondary ?? Colors.black,
            );
          },
        ),
        onBookSelect: widget.onBookSelect,
      );
}

class _BookCollection extends HookWidget {
  const _BookCollection({
    required this.books,
    required this.onBookSelect,
  });
  final List<BookData> books;
  final void Function(LectureType lecture) onBookSelect;

  @override
  Widget build(BuildContext context) {
    final booksState = useState<List<BookData>>(books);
    final lastOpenedIndex = useState<int>(-1);

    void toggleBook(int index) {
      if (index == lastOpenedIndex.value) {
        print('Opening book');
        return;
      }

      lastOpenedIndex.value = index;
      for (var i = 0; i < booksState.value.length; i++) {
        booksState.value[i].isOpen =
            (i == index) && !booksState.value[i].isOpen;
      }
    }

    return Transform.scale(
      scale: 1.2,
      child: Transform.rotate(
        angle: -0.2,
        child: Stack(
          children: [
            const _BookShelfBackground(),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: _BookShelfState.verticalPadding,
                horizontal: 32,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20),
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: books.length,
                itemBuilder: (context, index) => _AnimatedBook(
                  delay: Duration(milliseconds: index * 300),
                  duration: const Duration(milliseconds: 500),
                  isOpen: booksState.value[index].isOpen,
                  onTap: () => toggleBook(index),
                  onBookSelect: () =>
                      onBookSelect(booksState.value[index].lectureType),
                  child: Book(
                    book: booksState.value[index],
                    isOpen: booksState.value[index].isOpen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookShelfBackground extends StatelessWidget {
  const _BookShelfBackground();

  @override
  Widget build(BuildContext context) => SizedBox(
        height:
            _BookShelfState.fixedHeight + _BookShelfState.verticalPadding * 2,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              colorFilter: ColorFilter.mode(
                context.theme.brightness == Brightness.light
                    ? const Color(0xFFD05557)
                    : const Color(0xFF592049),
                BlendMode.modulate,
              ),
              image: const AssetImage('assets/images/noisy.webp'),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
      );
}

class _AnimatedBook extends HookWidget {
  const _AnimatedBook({
    required this.child,
    required this.isOpen,
    required this.duration,
    required this.onTap,
    required this.onBookSelect,
    this.delay = Duration.zero,
  });
  final Widget child;
  final bool isOpen;
  final Duration duration;
  final Duration delay;
  final VoidCallback onTap;
  final VoidCallback onBookSelect;

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: duration,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, -0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    final zoomController = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );
    final zoomAnimation = Tween<double>(
      begin: 1,
      end: 3,
    ).animate(
      CurvedAnimation(
        parent: zoomController,
        curve: Curves.easeInOut,
      ),
    );

    useEffect(
      () {
        Future.delayed(delay, animationController.forward);
        return null;
      },
      [delay],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isOpen) {
          zoomController.forward().then((_) {
            onBookSelect();
            zoomController.reverse();
          });
        } else {
          onTap();
        }
      },
      child: ScaleTransition(
        scale: zoomAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: AnimatedContainer(
              duration: duration,
              width: isOpen ? 180 : _BookShelfState.spineWidth + 10,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
