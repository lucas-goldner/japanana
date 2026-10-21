import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/features/onboarding/presentation/widgets/motion.dart';

const _kSubtitleDelay = Duration(milliseconds: 450);

/// Space above every step for the progress bar and back button.
const kOnboardingChromeHeight = 64.0;

/// Background tint of an onboarding step.
enum StepTint {
  paper,
  banana,
  blush,
  cream,
  mint;

  Color resolve(BuildContext context) {
    final dark = context.theme.brightness == Brightness.dark;
    return switch (this) {
      StepTint.paper => context.colorScheme.secondary,
      StepTint.banana =>
        dark ? context.colorScheme.surface : const Color(0xffF8D318),
      StepTint.blush =>
        dark ? const Color(0xff2A2232) : const Color(0xffFFE9E4),
      StepTint.cream =>
        dark ? const Color(0xff27261F) : const Color(0xffFFF3D6),
      StepTint.mint => dark ? const Color(0xff1B2A28) : const Color(0xffEAF7EE),
    };
  }
}

/// Text styles of the onboarding.
extension OnboardingText on BuildContext {
  TextStyle get onbTitle => TextStyle(
    fontFamily: 'Exlibris',
    fontFamilyFallback: const ['NotoSansJP'],
    fontWeight: FontWeight.bold,
    fontSize: 33,
    height: 1.15,
    color: neo.onCard,
  );

  TextStyle get onbBody => TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.bold,
    color: neo.onCard,
  );

  TextStyle get onbSubtitle => TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 15,
    height: 1.45,
    color: neo.onCard.withValues(alpha: 0.75),
  );

  /// Ink fill: black in light mode, banana in dark mode.
  Color get onbInk =>
      theme.brightness == Brightness.dark ? neo.accent : neo.border;
  Color get onbOnInk =>
      theme.brightness == Brightness.dark ? neo.onAccent : neo.accent;
}

/// Graph paper in the tint of a step.
class StepBackdrop extends StatelessWidget {
  const StepBackdrop({required this.tint, required this.child, super.key});

  final StepTint tint;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: GridPaperPainter(
      backgroundColor: tint.resolve(context),
      lineColor: context.neo.grid,
    ),
    child: child,
  );
}

/// Title, subtitle, content and call to action of a step.
class StepLayout extends StatelessWidget {
  const StepLayout({
    required this.body,
    this.title,
    this.subtitle,
    this.cta,
    this.secondary,
    this.titleAlign = TextAlign.start,
    this.topPadding = kOnboardingChromeHeight,
    super.key,
  });

  final String? title;
  final String? subtitle;
  final Widget body;
  final Widget? cta;
  final Widget? secondary;
  final TextAlign titleAlign;
  final double topPadding;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            BlurWords(
              title!,
              style: context.onbTitle,
              delay: const Duration(milliseconds: 200),
              textAlign: titleAlign,
            ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Reveal(
                delay: _kSubtitleDelay,
                child: Text(
                  subtitle!,
                  style: context.onbSubtitle,
                  textAlign: titleAlign,
                ),
              ),
            ),
          Expanded(child: body),
          if (cta != null) cta!,
          if (secondary != null)
            Padding(padding: const EdgeInsets.only(top: 6), child: secondary),
        ],
      ),
    ),
  );
}

enum CtaStyle { ink, banana, card }

/// Big call to action at the bottom of a step.
class OnboardingCta extends StatelessWidget {
  const OnboardingCta({
    required this.label,
    required this.onPressed,
    this.style = CtaStyle.banana,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final CtaStyle style;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final (color, foreground, shadow) = switch (style) {
      CtaStyle.ink => (
        context.onbInk,
        context.onbOnInk,
        context.theme.brightness == Brightness.dark
            ? neo.accentShadow
            : neo.accent,
      ),
      CtaStyle.banana => (neo.accent, neo.onAccent, neo.accentShadow),
      CtaStyle.card => (neo.card, neo.onCard, neo.shadow),
    };
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: enabled ? 1 : 0.35,
      child: Padding(
        // Keeps the hard shadow inside the layout.
        padding: EdgeInsets.only(right: neo.shadowOffset.dx),
        child: NeoButton(
          onPressed: enabled ? onPressed : () {},
          color: color,
          foregroundColor: foreground,
          shadowColor: shadow,
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: 17,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Text button below the call to action.
class OnboardingTextButton extends StatelessWidget {
  const OnboardingTextButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: context.neo.onCard.withValues(alpha: 0.7),
      splashFactory: NoSplash.splashFactory,
    ),
    child: Text(
      label,
      style: const TextStyle(fontFamily: 'NotoSansJP', fontSize: 14),
    ),
  );
}

/// Answer tile that turns to ink once it's picked.
class OnboardingOption extends StatelessWidget {
  const OnboardingOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
    super.key,
  });

  final String label;
  final String? emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final foreground = selected ? context.onbOnInk : neo.onCard;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(right: neo.shadowOffset.dx),
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: neo.decoration(
          color: selected ? context.onbInk : neo.card,
          shadowColor: selected ? neo.accentShadow : neo.shadow,
        ),
        child: Row(
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: context.onbBody.copyWith(color: foreground),
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              scale: selected ? 1 : 0,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: context.onbOnInk,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 16, color: context.onbInk),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small outlined label.
class NeoPill extends StatelessWidget {
  const NeoPill({
    required this.label,
    this.color,
    this.foregroundColor,
    this.fontSize = 11,
    this.uppercase = true,
    super.key,
  });

  final String label;
  final Color? color;
  final Color? foregroundColor;
  final double fontSize;
  final bool uppercase;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: fontSize * 0.9,
      vertical: fontSize * 0.3,
    ),
    decoration: BoxDecoration(
      color: color ?? context.neo.card,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: context.neo.border, width: 2),
    ),
    child: Text(
      uppercase ? label.toUpperCase() : label,
      style: TextStyle(
        fontFamily: 'NotoSansJP',
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        letterSpacing: 0.6,
        color: foregroundColor ?? context.neo.onCard,
      ),
    ),
  );
}
