import 'package:flutter/material.dart';

import '../theme/fox_theme.dart';

/// Label above, value below, optional qualifier beneath. The value is the
/// largest thing in the tile.
class FoxStatTile extends StatelessWidget {
  const FoxStatTile({
    super.key,
    required this.label,
    required this.value,
    this.qualifier,
    this.needsAttention = false,
  });

  final String label;
  final String value;
  final String? qualifier;

  /// Turns the figure orange. Reserved for what the user must act on —
  /// pending payment, rooms out of order, tasks overdue.
  final bool needsAttention;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceBase,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: context.type.overline.copyWith(color: c.textMin),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: context.type.figureLg.copyWith(
                color: needsAttention ? c.brandAction : c.textPrimary,
              ),
            ),
          ),
          if (qualifier != null) ...[
            const SizedBox(height: 4),
            Text(
              qualifier!,
              style: context.type.caption.copyWith(color: c.textMin),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
