import 'package:flutter/material.dart';

import 'fox_colors.dart';
import 'fox_spacing.dart';
import 'fox_typography.dart';

/// Convenience accessors so widgets read tokens rather than literals.
extension FoxThemeContext on BuildContext {
  FoxColors get fox => Theme.of(this).extension<FoxColors>()!;
  FoxTypography get type => Theme.of(this).extension<FoxTypography>()!;
  FoxSpacing get space => Theme.of(this).extension<FoxSpacing>()!;
}

class FoxTheme {
  const FoxTheme._();

  static ThemeData light() => _build(FoxColors.light, Brightness.light);
  static ThemeData dark() => _build(FoxColors.dark, Brightness.dark);

  static ThemeData _build(FoxColors c, Brightness brightness) {
    final type = FoxTypography.of(c.textPrimary, c.textSecondary);

    // Declared explicitly rather than via ColorScheme.fromSeed: a generated
    // tonal palette substitutes its own values and silently voids the
    // contrast ratios the design system measured.
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.brandAction,
      onPrimary: c.onBrand,
      primaryContainer: c.brandTint,
      onPrimaryContainer: c.textPrimary,
      secondary: c.brandEmber,
      onSecondary: c.onBrand,
      surface: c.surfaceBase,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceRaised,
      onSurfaceVariant: c.textTertiary,
      error: c.danger,
      onError: Colors.white,
      errorContainer: c.dangerTint,
      onErrorContainer: c.danger,
      outline: c.border,
      outlineVariant: c.divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfaceBase,
      fontFamily: 'packages/foxotale_ui/Inter',
      splashFactory: InkSparkle.splashFactory,
      extensions: [c, type, const FoxSpacing()],
      appBarTheme: AppBarTheme(
        // Orange chrome in light; in dark the bar drops to a raised surface —
        // a saturated orange bar on near-black is the harshest thing the
        // palette can produce, and it is looked at for a whole shift.
        backgroundColor:
            brightness == Brightness.light ? c.brandAction : c.surfaceRaised,
        foregroundColor:
            brightness == Brightness.light ? c.onBrand : c.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: type.h1.copyWith(
          color: brightness == Brightness.light ? c.onBrand : c.textPrimary,
        ),
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: c.surfaceBase,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.divider),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brandAction,
          foregroundColor: c.onBrand,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: type.h3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.brandAction,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: type.h3,
          side: BorderSide(color: c.brandAction, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.brandAction,
          minimumSize: const Size(0, 44),
          textStyle: type.h3,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.brandFlame,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceBase,
        hintStyle: type.body.copyWith(color: c.textDisabled),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.brandAction, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            brightness == Brightness.light ? c.brandAction : c.surfaceRaised,
        indicatorColor: brightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.18)
            : c.brandAction.withValues(alpha: 0.22),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.all(
          type.caption.copyWith(
            color: brightness == Brightness.light ? c.onBrand : c.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.all(
          IconThemeData(
            color: brightness == Brightness.light ? c.onBrand : c.textPrimary,
            size: 24,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: type.display,
        headlineLarge: type.h1,
        headlineMedium: type.h2,
        titleMedium: type.h3,
        bodyLarge: type.body,
        bodyMedium: type.bodySm,
        labelLarge: type.label,
        bodySmall: type.caption,
        labelSmall: type.overline,
      ),
    );
  }
}
