import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

class ReviewSetupOption extends StatelessWidget {
  const ReviewSetupOption({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });
  final String label;
  final bool value;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 8),
          constraints: const BoxConstraints(minHeight: 72),
          decoration: context.neo.decoration(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.neo.onCard,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      );
}
