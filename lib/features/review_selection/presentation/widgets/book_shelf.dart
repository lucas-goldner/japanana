import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/japanana_theme.dart';

part 'book.dart';

class BookShelf extends StatefulWidget {
  const BookShelf(this.lectureTypes, {super.key});

  final List<LectureType> lectureTypes;

  @override
  State<BookShelf> createState() => _BookShelfState();
}

class _BookShelfState extends State<BookShelf> {
  static const double fixedHeight = 200;
  static const double spineWidth = fixedHeight * 0.09;
  static const double coverWidth = fixedHeight * 0.7;

  @override
  Widget build(BuildContext context) {
    final booksTheme = context.booksTheme;
    return Flexible(
      flex: 4,
      child: _BookCollection(
        books: List.generate(
          widget.lectureTypes.length,
          (index) {
            final type = widget.lectureTypes[index];
            final colors = booksTheme.lectureTypeColors[type];
            return BookData(
              lectureType: type,
              primaryColor: colors?.primary ?? Colors.black,
              secondaryColor: colors?.secondary ?? Colors.black,
            );
          },
        ),
      ),
    );
  }
}

class _BookCollection extends StatefulWidget {
  const _BookCollection({required this.books});
  final List<BookData> books;

  @override
  _BookCollectionState createState() => _BookCollectionState();
}

class _BookCollectionState extends State<_BookCollection> {
  late List<BookData> _books;

  @override
  void initState() {
    super.initState();
    _books = widget.books;
  }

  void _toggleBook(int index) {
    print('on tap gesture');
    setState(() {
      for (var i = 0; i < _books.length; i++) {
        if (i == index) {
          _books[i].isOpen = !_books[i].isOpen;
        } else {
          _books[i].isOpen = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => Transform.scale(
        scale: 1.2,
        child: Transform.rotate(
          angle: -0.2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/noisy.webp'),
                repeat: ImageRepeat.repeat,
                colorFilter: ColorFilter.mode(
                  Colors.red.withValues(alpha: 0.7),
                  BlendMode.srcOver,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 32,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20),
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: widget.books.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _toggleBook(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBookWrapper(
                    isOpen: _books[index].isOpen,
                    child: Book(
                      book: _books[index],
                      isOpen: _books[index].isOpen,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class AnimatedBookWrapper extends StatelessWidget {
  const AnimatedBookWrapper({
    required this.child,
    required this.isOpen,
    super.key,
    this.duration = const Duration(milliseconds: 300),
  });
  final Widget child;
  final bool isOpen;
  final Duration duration;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: duration,
        width: isOpen ? 180 : _BookShelfState.spineWidth + 10,
        child: child,
      );
}
