import 'package:flutter/material.dart';

import '../theme/fox_theme.dart';

enum FoxStatusTone { success, warning, danger, info, neutral }

/// State is carried by a label and an icon as well as colour, so it survives
/// colour-vision deficiency, glare and a cracked screen.
class FoxStatusChip extends StatelessWidget {
  const FoxStatusChip({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final FoxStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final (fg, bg) = switch (tone) {
      FoxStatusTone.success => (c.success, c.successTint),
      FoxStatusTone.warning => (c.warning, c.warningTint),
      FoxStatusTone.danger => (c.danger, c.dangerTint),
      FoxStatusTone.info => (c.info, c.infoTint),
      FoxStatusTone.neutral => (c.textTertiary, c.surfaceRaised),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.circle, size: icon == null ? 8 : 13, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.type.caption
                .copyWith(color: fg, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// A role is text in a neutral badge. Seven roles cannot each own a hue
/// without exhausting the palette and colliding with the semantic states.
class FoxRoleBadge extends StatelessWidget {
  const FoxRoleBadge({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.divider),
      ),
      child: Text(
        role,
        style: context.type.caption
            .copyWith(color: c.textSecondary, fontWeight: FontWeight.w500),
      ),
    );
  }
}
