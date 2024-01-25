import 'package:flutter/material.dart';
import 'package:hikou/core/extensions.dart';

class ReviewSetupOption extends StatelessWidget {
  const ReviewSetupOption({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });
  final String label;
  final bool value;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Flexible(
            flex: 8,
            fit: FlexFit.tight,
            child: Text(
              label,
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.start,
            ),
          ),
          Spacer(),
          Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            value: value,
            onChanged: onChanged,
          ),
        ],
      );
}
