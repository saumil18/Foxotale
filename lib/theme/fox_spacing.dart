import 'package:flutter/material.dart';

/// Spacing, shape and elevation tokens. 4pt base.
@immutable
class FoxSpacing extends ThemeExtension<FoxSpacing> {
  const FoxSpacing();

  final double xs = 4;
  final double sm = 8;
  final double md = 12;
  final double lg = 16;
  final double xl = 24;
  final double xxl = 32;
  final double xxxl = 48;

  /// Set by housekeeping and front-desk use, not by the smallest control that fits.
  final double touchTarget = 48;
  final double rowHeight = 44;
  final double rowHeightCompact = 40;

  final double radiusSm = 6;
  final double radiusMd = 8;
  final double radiusLg = 10;
  final double radiusFull = 999;

  @override
  FoxSpacing copyWith() => const FoxSpacing();

  @override
  FoxSpacing lerp(ThemeExtension<FoxSpacing>? other, double t) => this;
}
