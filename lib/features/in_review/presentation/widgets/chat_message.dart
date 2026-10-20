import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

class ChatMessageData {
  ChatMessageData({
    required this.text,
    required this.isUser,
    this.isSeparator = false,
  });

  final String text;
  final bool isUser;
  final bool isSeparator;
}

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.index,
    this.isSeparator = false,
    this.fontFamily,
    this.fontWeight = FontWeight.bold,
    super.key,
  });

  final String text;
  final bool isUser;
  final int index;
  final bool isSeparator;
  final String? fontFamily;
  final FontWeight fontWeight;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _popController;
  late AnimationController _textController;
  late Animation<double> _popAnimation;
  late Animation<double> _textAnimation;
  bool _hasAnimated = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Bubble pop in animation
    _popController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    // Text fade-in animation (0.3 seconds, starts after the pop in)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _popAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _popController,
        curve: Curves.easeOutBack,
      ),
    );

    _textAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Only animate once
    if (!_hasAnimated) {
      _hasAnimated = true;
      // Start pop in animation immediately
      _popController
        ..forward()
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _textController.forward();
          }
        });
    } else {
      // If already animated, jump to end state
      _popController.value = 1.0;
      _textController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final colorScheme = context.colorScheme;
    final neo = context.neo;

    if (widget.isSeparator) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _SeparatorLine(color: neo.border)),
            Flexible(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: neo.decoration(
                  color: colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(999),
                  shadowColor: neo.accentShadow,
                ),
                child: Text(
                  widget.text,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: widget.fontWeight,
                    color: Colors.white,
                    fontFamily: widget.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(child: _SeparatorLine(color: neo.border)),
          ],
        ),
      );
    }

    final radius = Radius.circular(neo.radius);
    // The corner next to the speaker stays sharp, like a speech bubble tail.
    final borderRadius = widget.isUser
        ? BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
          )
        : BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomRight: radius,
          );

    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: EdgeInsets.only(
          left: widget.isUser ? 40 : 0,
          right: widget.isUser ? 0 : 40,
        ),
        child: AnimatedBuilder(
          animation: _popAnimation,
          builder: (context, child) => Opacity(
            opacity: _popAnimation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.85 + 0.15 * _popAnimation.value,
              alignment: widget.isUser
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: child,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: neo.decoration(
              color: widget.isUser ? neo.accent : neo.card,
              shadowColor: widget.isUser ? neo.accentShadow : neo.shadow,
              borderRadius: borderRadius,
            ),
            child: AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) => Opacity(
                opacity: _textAnimation.value,
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.isUser ? neo.onAccent : neo.onCard,
                    fontSize: 16,
                    fontFamily: widget.fontFamily,
                    fontWeight: widget.fontWeight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeparatorLine extends StatelessWidget {
  const _SeparatorLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(height: 3, color: color);
}
