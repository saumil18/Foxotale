import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/fox_theme.dart';
import 'fox_brand_text.dart';

/// The signed-in header: a deep brand gradient with a frosted panel, standing
/// in for a flat app bar.
///
/// Every colour on it comes from the header tokens, which were chosen so white
/// text clears 5.0:1 at both ends of the gradient and under the sheen. The two
/// overlays below are capped for that reason — raising either one, or pulling
/// the gradient towards Fox Flame, drops the text below AA.
class FoxHeader extends StatelessWidget implements PreferredSizeWidget {
  const FoxHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    this.trailing,
  });

  /// The large line — a greeting on the home tab, the section name elsewhere.
  final String title;

  /// The quiet line under it: which property, which role.
  final String subtitle;

  final List<Widget> actions;

  /// Sits on the right of the brand row, where the role badge or the property
  /// switcher goes.
  final Widget? trailing;

  static const _height = 152.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;
    final top = MediaQuery.of(context).padding.top;

    // One ink colour for everything on the gradient. Both ends are dark enough
    // that white holds at body size, so nothing here needs a per-element check.
    const ink = Color(0xFFFFFFFF);
    final inkQuiet = ink.withValues(alpha: 0.78);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Both gradients are dark, in either theme, so the clock and the
      // battery have to invert whichever theme is on.
      value: SystemUiOverlayStyle.light,
      child: Container(
      height: _height + top,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.headerTop, c.headerBottom],
        ),
      ),
      child: Stack(
        children: [
          // Warm glow, top right — the shine in the reference, in Fox Flame
          // rather than white so it reads as heat and costs less contrast.
          Positioned(
            top: -90,
            right: -70,
            child: _Glow(color: c.brandFlame.withValues(alpha: 0.22), size: 260),
          ),
          // Cool highlight along the top left edge, kept at 8% — at 18% the
          // white text over it measures 4.33:1 and fails.
          Positioned(
            top: -120,
            left: -80,
            child: _Glow(color: ink.withValues(alpha: 0.08), size: 240),
          ),
          Padding(
            padding: EdgeInsets.only(top: top + 10, left: 16, right: 8, bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _GlassTile(
                      fill: c.glassFill,
                      border: c.glassBorder,
                      child: Image.asset('assets/brand/fox_mark.png', package: 'foxotale_ui',
                          width: 30, height: 30, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    // The capital O keeps its brand colour everywhere else, but
                    // Fox Deep on this gradient is close to invisible, so the
                    // wordmark reads in one ink here.
                    FoxBrandText(
                      'FoxOtale',
                      style: t.h3.copyWith(
                          color: ink, letterSpacing: 0.4, fontWeight: FontWeight.w700),
                      accent: ink,
                    ),
                    const Spacer(),
                    ?trailing,
                    ...actions,
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    title,
                    style: t.display.copyWith(color: ink, height: 1.1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    subtitle,
                    style: t.bodySm.copyWith(color: inkQuiet),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// A soft radial wash. Used instead of a blur because a blur here would have to
/// sample the whole header every frame for an effect that never moves.
class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      );
}

/// The frosted square holding the fox mark.
class _GlassTile extends StatelessWidget {
  const _GlassTile({
    required this.fill,
    required this.border,
    required this.child,
  });

  final Color fill;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// An icon button sized and tinted for the gradient.
class FoxHeaderAction extends StatelessWidget {
  const FoxHeaderAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: 20,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(foregroundColor: Colors.white),
        icon: Icon(icon),
      );
}

/// The role, worn on the gradient. The surface badge is an opaque pill and
/// reads as a sticker up here, so this one is cut from the same glass as the
/// logo tile.
class FoxHeaderBadge extends StatelessWidget {
  const FoxHeaderBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.glassFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.glassBorder),
      ),
      child: Text(label,
          style: context.type.caption.copyWith(
              color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}
