import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

const _kToggleDuration = Duration(milliseconds: 160);
const _kTrackWidth = 58.0;
const _kTrackHeight = 34.0;
const _kThumbSize = 22.0;

/// Neubrutalist on/off switch: an outlined track with a hard shadow and an
/// outlined thumb that slides across.
class NeoSwitch extends StatelessWidget {
  const NeoSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final thumbInset = (_kTrackHeight - neo.borderWidth * 2 - _kThumbSize) / 2;

    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: _kToggleDuration,
          width: _kTrackWidth,
          height: _kTrackHeight,
          decoration: neo
              .decoration(
                color: value ? neo.accent : neo.card,
                shadowColor: value ? neo.accentShadow : neo.shadow,
                borderRadius: BorderRadius.circular(999),
              )
              .copyWith(
                boxShadow: [
                  BoxShadow(
                    color: value ? neo.accentShadow : neo.shadow,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
          child: AnimatedAlign(
            duration: _kToggleDuration,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(thumbInset),
              child: Container(
                width: _kThumbSize,
                height: _kThumbSize,
                decoration: BoxDecoration(
                  color: value ? neo.onAccent : neo.border,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
