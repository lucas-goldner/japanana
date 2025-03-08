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
  static const double verticalPadding = 24;
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
  int lastOpenedIndex = -1;

  @override
  void initState() {
    super.initState();
    _books = widget.books;
  }

  void _toggleBook(int index) {
    print('Tapped');

    if (index == lastOpenedIndex) {
      print('Route');
      return;
    }

    setState(() {
      lastOpenedIndex = index;
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
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  lastOpenedIndex = -1;
                  for (var i = 0; i < _books.length; i++) {
                    _books[i].isOpen = false;
                  }
                }),
                child: const _BookShelfBackground(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _BookShelfState.verticalPadding,
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
            ],
          ),
        ),
      );
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
