import 'package:flutter/material.dart';

/// Colour tokens for the FoxOtale Staff App.
///
/// Values are fixed by Design System v1 and each carries a measured contrast
/// ratio. Never substitute a Material-generated tonal value for one of these:
/// the accessibility record in the design system assumes the exact hex ships.
@immutable
class FoxColors extends ThemeExtension<FoxColors> {
  const FoxColors({
    required this.brandFlame,
    required this.brandEmber,
    required this.brandAction,
    required this.brandTint,
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMin,
    required this.textDisabled,
    required this.border,
    required this.divider,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.successTint,
    required this.warningTint,
    required this.dangerTint,
    required this.infoTint,
    required this.onBrand,
    required this.headerTop,
    required this.headerBottom,
    required this.glassFill,
    required this.glassBorder,
  });

  final Color brandFlame;
  final Color brandEmber;

  /// The only orange permitted behind white text or used as text on a light
  /// surface. 5.05:1 against white; the brand oranges measure 3.48 and 3.42.
  final Color brandAction;
  final Color brandTint;

  final Color surfaceBase;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color surfaceSelected;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Lowest colour that still passes AA at body size. Nothing readable goes below it.
  final Color textMin;
  final Color textDisabled;

  final Color border;
  final Color divider;

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  final Color successTint;
  final Color warningTint;
  final Color dangerTint;
  final Color infoTint;

  final Color onBrand;

  /// The two ends of the signed-in header gradient. Both ends and every point
  /// between them clear 5.0:1 against white, so the header can carry body text
  /// anywhere on it — including under the sheen, which is capped for that
  /// reason. Do not lighten either end towards the brand oranges: Fox Flame
  /// measures 3.48:1 and would break the header's text.
  final Color headerTop;
  final Color headerBottom;

  /// The frosted panel on the header — fill and hairline. Alpha values, meant
  /// to sit on the gradient and nowhere else.
  final Color glassFill;
  final Color glassBorder;

  static const light = FoxColors(
    brandFlame: Color(0xFFFF4200),
    brandEmber: Color(0xFFEA5F04),
    brandAction: Color(0xFFC74000),
    brandTint: Color(0xFFFFF3ED),
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF4F1EE),
    surfaceSunken: Color(0xFFFEF9E6),
    surfaceSelected: Color(0xFFFFE0D1),
    textPrimary: Color(0xFF1A1613),
    textSecondary: Color(0xFF3D3733),
    textTertiary: Color(0xFF5C534D),
    textMin: Color(0xFF78706A),
    textDisabled: Color(0xFF9A928C),
    border: Color(0xFFC4BDB7),
    divider: Color(0xFFE3DEDA),
    success: Color(0xFF1B7A44),
    warning: Color(0xFF9A6200),
    danger: Color(0xFFC0271F),
    info: Color(0xFF1A5FA8),
    successTint: Color(0xFFE8F4ED),
    warningTint: Color(0xFFFBF1DE),
    dangerTint: Color(0xFFFAEAE9),
    infoTint: Color(0xFFE9F0F9),
    onBrand: Color(0xFFFFFFFF),
    headerTop: Color(0xFF8E2E00),
    headerBottom: Color(0xFF421200),
    glassFill: Color(0x26FFFFFF),
    glassBorder: Color(0x4DFFFFFF),
  );

  static const dark = FoxColors(
    brandFlame: Color(0xFFFF4200),
    brandEmber: Color(0xFFEA5F04),
    brandAction: Color(0xFFFF7A45),
    brandTint: Color(0xFF2A1710),
    surfaceBase: Color(0xFF14100D),
    surfaceRaised: Color(0xFF1F1A16),
    surfaceSunken: Color(0xFF0D0A08),
    surfaceSelected: Color(0xFF332016),
    textPrimary: Color(0xFFF5EFE9),
    textSecondary: Color(0xFFC6BDB5),
    textTertiary: Color(0xFFA79E96),
    textMin: Color(0xFFA79E96),
    textDisabled: Color(0xFF6E645C),
    border: Color(0xFF3A322C),
    divider: Color(0xFF2A231E),
    success: Color(0xFF5BC98B),
    warning: Color(0xFFE7A94A),
    danger: Color(0xFFF2837B),
    info: Color(0xFF7FB2F0),
    successTint: Color(0xFF173226),
    warningTint: Color(0xFF302411),
    dangerTint: Color(0xFF33191A),
    infoTint: Color(0xFF12243A),
    onBrand: Color(0xFF14100D),
    headerTop: Color(0xFF3A1A0E),
    headerBottom: Color(0xFF140D08),
    glassFill: Color(0x1FFFFFFF),
    glassBorder: Color(0x33FFFFFF),
  );

  @override
  FoxColors copyWith({
    Color? brandFlame,
    Color? brandEmber,
    Color? brandAction,
    Color? brandTint,
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? surfaceSelected,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textMin,
    Color? textDisabled,
    Color? border,
    Color? divider,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? successTint,
    Color? warningTint,
    Color? dangerTint,
    Color? infoTint,
    Color? onBrand,
    Color? headerTop,
    Color? headerBottom,
    Color? glassFill,
    Color? glassBorder,
  }) {
    return FoxColors(
      brandFlame: brandFlame ?? this.brandFlame,
      brandEmber: brandEmber ?? this.brandEmber,
      brandAction: brandAction ?? this.brandAction,
      brandTint: brandTint ?? this.brandTint,
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceSelected: surfaceSelected ?? this.surfaceSelected,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textMin: textMin ?? this.textMin,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      successTint: successTint ?? this.successTint,
      warningTint: warningTint ?? this.warningTint,
      dangerTint: dangerTint ?? this.dangerTint,
      infoTint: infoTint ?? this.infoTint,
      onBrand: onBrand ?? this.onBrand,
      headerTop: headerTop ?? this.headerTop,
      headerBottom: headerBottom ?? this.headerBottom,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
    );
  }

  @override
  FoxColors lerp(ThemeExtension<FoxColors>? other, double t) {
    if (other is! FoxColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return FoxColors(
      brandFlame: c(brandFlame, other.brandFlame),
      brandEmber: c(brandEmber, other.brandEmber),
      brandAction: c(brandAction, other.brandAction),
      brandTint: c(brandTint, other.brandTint),
      surfaceBase: c(surfaceBase, other.surfaceBase),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      surfaceSunken: c(surfaceSunken, other.surfaceSunken),
      surfaceSelected: c(surfaceSelected, other.surfaceSelected),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      textMin: c(textMin, other.textMin),
      textDisabled: c(textDisabled, other.textDisabled),
      border: c(border, other.border),
      divider: c(divider, other.divider),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      danger: c(danger, other.danger),
      info: c(info, other.info),
      successTint: c(successTint, other.successTint),
      warningTint: c(warningTint, other.warningTint),
      dangerTint: c(dangerTint, other.dangerTint),
      infoTint: c(infoTint, other.infoTint),
      onBrand: c(onBrand, other.onBrand),
      headerTop: c(headerTop, other.headerTop),
      headerBottom: c(headerBottom, other.headerBottom),
      glassFill: c(glassFill, other.glassFill),
      glassBorder: c(glassBorder, other.glassBorder),
    );
  }
}
