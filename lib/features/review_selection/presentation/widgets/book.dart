part of 'book_shelf.dart';

class BookData {
  BookData({
    required this.lectureType,
    required this.primaryColor,
    required this.secondaryColor,
    this.isOpen = false,
  });
  final LectureType lectureType;
  final Color primaryColor;
  final Color secondaryColor;
  bool isOpen;

  BookData copyWithOpen({bool? isOpen}) => BookData(
        lectureType: lectureType,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        isOpen: isOpen ?? this.isOpen,
      );
}

class Book extends StatefulWidget {
  const Book({
    required this.book,
    required this.isOpen,
    super.key,
  });
  final BookData book;
  final bool isOpen;

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -math.pi / 2, end: 0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
    _updateAnimationState();
  }

  @override
  void didUpdateWidget(Book oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationState();
  }

  void _updateAnimationState() {
    if (widget.isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: const Offset(_BookShelfState.spineWidth, 0),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) => Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(_animation.value)
              ..translate(0.0),
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                _BookCover(widget.book),
                Transform(
                  transform: Matrix4.identity()
                    ..rotateY(math.pi / 2)
                    ..translate(-_BookShelfState.spineWidth),
                  alignment: Alignment.centerLeft,
                  child: _BookSpine(widget.book),
                ),
              ],
            ),
          ),
        ),
      );
}

class _BookCover extends HookWidget {
  const _BookCover(this.book);

  final BookData book;

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    final animation = Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(animationController);

    useEffect(
      () {
        if (book.isOpen) {
          animationController
            ..duration = const Duration(seconds: 1)
            ..forward();
        } else {
          animationController
            ..duration = const Duration(milliseconds: 125)
            ..reverse();
        }
        return null;
      },
      [book.isOpen],
    );

    return Stack(
      children: [
        SizedBox(
          width: _BookShelfState.coverWidth,
          height: _BookShelfState.fixedHeight,
          child: ColoredBox(color: book.primaryColor),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SizedBox(
            width: 20,
            height: _BookShelfState.fixedHeight,
            child: ColoredBox(color: book.secondaryColor),
          ),
        ),
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) => Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 32),
              child: SizedBox(
                height: _BookShelfState.fixedHeight,
                width: _BookShelfState.coverWidth * 0.75,
                child: FittedBox(
                  child: Text(
                    book.lectureType
                        .getLocalizedTitle(context)
                        .characters
                        .map((e) => e == ' ' ? '\n' : e)
                        .join(),
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: Colors.white
                          .withAlpha((animation.value * 255).toInt()),
                      fontFamily: context.textTheme.notoSansJPFont,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookSpine extends StatelessWidget {
  const _BookSpine(this.book);

  final BookData book;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          SizedBox(
            width: _BookShelfState.spineWidth,
            height: _BookShelfState.fixedHeight,
            child: ColoredBox(color: book.secondaryColor),
          ),
          SizedBox(
            height: _BookShelfState.fixedHeight,
            width: _BookShelfState.spineWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: book.primaryColor,
                  width: 2,
                ),
              ),
              child: FittedBox(
                child: Text(
                  textAlign: TextAlign.center,
                  book.lectureType
                      .getLocalizedTitle(context)
                      .characters
                      .map((e) => '$e\n')
                      .join(),
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontFamily: context.textTheme.notoSansJPFont,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
