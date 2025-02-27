part of 'book_shelf.dart';

class BookData {
  BookData({
    required this.coverAsset,
    required this.spineAsset,
    this.isOpen = false,
  });
  final String coverAsset;
  final String spineAsset;
  bool isOpen;
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
          builder: (context, child) => Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(_animation.value)
              ..translate(0.0),
            alignment: Alignment.centerLeft,
            child: _buildBookContent(),
          ),
        ),
      );

  Widget _buildBookContent() => Stack(
        children: [
          // Cover image
          SizedBox(
            width: _BookShelfState.coverWidth,
            height: _BookShelfState.fixedHeight,
            child: Image.asset(
              widget.book.coverAsset,
              fit: BoxFit.fill,
            ),
          ),
          // Spine image
          Transform(
            transform: Matrix4.identity()
              ..rotateY(math.pi / 2)
              ..translate(-_BookShelfState.spineWidth),
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: _BookShelfState.spineWidth,
              height: _BookShelfState.fixedHeight,
              child: Image.asset(
                widget.book.spineAsset,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      );
}
