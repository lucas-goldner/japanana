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

class _BookState extends State<Book> with TickerProviderStateMixin {
  // 1) Controller for the main cover rotation (closed -> open).
  late AnimationController _coverController;
  late Animation<double> _coverRotation;

  // 2) Controller for the second rotation (page reveal).
  //    Also used for scaling the entire book/page from 1..3.
  late AnimationController _pageController;
  late Animation<double> _pageRotation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // A) Main cover rotation: -π/2 (fully closed) -> 0 (flat open).
    _coverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _coverRotation = Tween<double>(begin: -math.pi / 2, end: 0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_coverController);

    // B) Page reveal rotation: 0..π/2 (cover rotates away from the page).
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pageRotation = Tween<double>(begin: 0, end: math.pi / 2)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pageController);

    // C) Scale everything from 1..3 during the second rotation.
    //    You can use the same _pageController. When it moves from 0..1,
    //    we’ll interpret that as 1..3 for the scale factor.
    _scaleAnimation = Tween<double>(begin: 1, end: 4)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pageController);

    _updateAnimationState();
  }

  @override
  void didUpdateWidget(covariant Book oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationState();
  }

  void _updateAnimationState() {
    if (widget.isOpen) {
      // Animate from closed (-π/2) to open (0).
      _coverController.forward();
    } else {
      // Animate from open (0) to closed (-π/2).
      _coverController.reverse();
      // Reset the second rotation & scale so page is hidden + scale = 1 next time.
      _pageController.reset();
    }
  }

  @override
  void dispose() {
    _coverController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Called when the user taps the book. If already open, do the second rotation & scale.
  Future<void> _handleTap() async {
    if (widget.isOpen) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        if (!context.mounted) {
          return;
        }

        await context.push(
          AppRoutes.reviewSetup.path,
          extra: widget.book.lectureType,
        );

        // Then on return, rotate cover back from π/2..0 and scale 3..1:
        _pageController.reverse();
      });
      // The book is already open: rotate cover from 0..π/2 AND scale 1..3.
      await _pageController.forward();
      // Once the animation completes, navigate or do whatever you want:
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _handleTap,
        child: Transform.translate(
          offset: const Offset(_BookShelfState.spineWidth, 0),
          child: AnimatedBuilder(
            animation: Listenable.merge([_coverController, _pageController]),
            builder: (context, child) {
              final coverVal = _coverRotation.value; // -π/2..0
              final pageVal = _pageRotation.value; // 0..π/2
              final scaleVal = _scaleAnimation.value; // 1..3

              // The final rotation is the sum of the “open book” rotation plus
              // any extra rotation that reveals the page.
              final totalRotation = coverVal + pageVal;

              return Transform.scale(
                scale: scaleVal,
                child: Stack(
                  children: [
                    // 1) The White Page behind the cover.
                    //    Visible once the second rotation begins (optional).
                    Visibility(
                      visible: pageVal > 0,
                      child: Positioned(
                        child: Container(
                          height: _BookShelfState.fixedHeight,
                          width: _BookShelfState.coverWidth,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 2) The rotating cover + spine. We apply the totalRotation here.
                    Transform(
                      alignment: Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY(totalRotation),
                      child: Stack(
                        children: [
                          _BookCover(widget.book),
                          // The Spine, rotated π/2 from the cover.
                          Visibility(
                            visible: pageVal == 0,
                            child: Transform(
                              transform: Matrix4.identity()
                                ..rotateY(math.pi / 2)
                                ..translate(-_BookShelfState.spineWidth),
                              alignment: Alignment.centerLeft,
                              child: _BookSpine(widget.book),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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
