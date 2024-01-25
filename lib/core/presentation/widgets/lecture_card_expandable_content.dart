import 'package:flutter/material.dart';
import 'package:hikou/core/extensions.dart';

class LectureCardExpandableContent extends StatelessWidget {
  const LectureCardExpandableContent({
    required this.itemsToDisplay,
    required this.label,
    bool? upperPadding,
    super.key,
  }) : _upperPadding = upperPadding ?? true;

  final List<String> itemsToDisplay;
  final String label;
  final bool _upperPadding;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_upperPadding) SizedBox(height: 20),
          if (itemsToDisplay.length != 0)
            Text(
              "- ${label}:",
              style: context.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 4),
          ...itemsToDisplay
              .map(
                (example) => Text(
                  example,
                  style: context.textTheme.bodyLarge,
                ),
              )
              .toList(),
        ],
      );
}
