import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

/// Small pill shown to users with an active supporter subscription.
class SupporterBadge extends StatelessWidget {
  const SupporterBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: neo
          .decoration(
            color: context.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(999),
          )
          .copyWith(
            border: Border.all(color: neo.border, width: 2),
            boxShadow: [
              BoxShadow(color: neo.accentShadow, offset: const Offset(2, 2)),
            ],
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            context.l10n.supporterBadge,
            style: context.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
