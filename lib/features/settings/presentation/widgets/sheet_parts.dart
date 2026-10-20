import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/neo_switch.dart';

/// Short explanation at the top of a settings sheet.
class SheetDescription extends StatelessWidget {
  const SheetDescription(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface,
          fontFamily: context.textTheme.notoSansJPFont,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      );
}

/// Selectable option card; the selected one is filled with the ink color.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    // The sheet itself uses the accent color in light mode, so the selected
    // option is inked in instead.
    final foreground = selected ? neo.card : neo.onCard;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: neo.decoration(
          color: selected ? neo.border : neo.card,
          shadowColor: selected ? neo.accentShadow : neo.shadow,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              Icon(leading, color: foreground),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontFamily: context.textTheme.notoSansJPFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: foreground),
          ],
        ),
      ),
    );
  }
}

/// Outlined card with a label and a [NeoSwitch].
class SwitchTile extends StatelessWidget {
  const SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.only(left: 18, right: 14),
          decoration: context.neo.decoration(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.neo.onCard,
                    fontFamily: context.textTheme.notoSansJPFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              NeoSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      );
}

enum SheetMessageTone { success, error }

/// Result of an action, shown as a colored note below the buttons.
class SheetMessage extends StatelessWidget {
  const SheetMessage(this.text, {required this.tone, super.key});
  final String text;
  final SheetMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: neo.decoration(
        color: switch (tone) {
          SheetMessageTone.success => neo.correctFill,
          SheetMessageTone.error => neo.wrongFill,
        },
        shadowColor: neo.accentShadow,
      ),
      child: Row(
        children: [
          Icon(
            switch (tone) {
              SheetMessageTone.success => Icons.check_circle,
              SheetMessageTone.error => Icons.error,
            },
            color: neo.onFeedback,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: neo.onFeedback,
                fontFamily: context.textTheme.notoSansJPFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical stack of sheet sections with even spacing.
class SheetColumn extends StatelessWidget {
  const SheetColumn({required this.children, super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const SizedBox(height: 16),
            child,
          ],
        ],
      );
}
