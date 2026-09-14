import 'package:flutter/material.dart';

/// Type tokens. Inter carries all UI and data; Lora is confined to the
/// wordmark and splash.
@immutable
class FoxTypography extends ThemeExtension<FoxTypography> {
  const FoxTypography({
    required this.wordmark,
    required this.display,
    required this.figureXl,
    required this.figureLg,
    required this.figureMd,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.body,
    required this.bodySm,
    required this.label,
    required this.caption,
    required this.overline,
  });

  final TextStyle wordmark;
  final TextStyle display;

  /// Figure styles carry tabular figures so currency columns align.
  final TextStyle figureXl;
  final TextStyle figureLg;
  final TextStyle figureMd;

  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle body;
  final TextStyle bodySm;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle overline;

  static const _tabular = [FontFeature.tabularFigures()];

  static FoxTypography of(Color ink, Color secondary) => FoxTypography(
        wordmark: TextStyle(
          fontFamily: 'Lora',
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        display: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          height: 34 / 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: ink,
        ),
        figureXl: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          height: 36 / 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          fontFeatures: _tabular,
          color: ink,
        ),
        figureLg: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          height: 26 / 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          fontFeatures: _tabular,
          color: ink,
        ),
        figureMd: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          height: 20 / 15,
          fontWeight: FontWeight.w600,
          fontFeatures: _tabular,
          color: ink,
        ),
        h1: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          height: 28 / 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: ink,
        ),
        h2: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: ink,
        ),
        h3: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          height: 20 / 15,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        body: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          height: 22 / 15,
          fontWeight: FontWeight.w400,
          color: secondary,
        ),
        bodySm: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          height: 19 / 13,
          fontWeight: FontWeight.w400,
          color: secondary,
        ),
        label: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          height: 16 / 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.6,
          color: secondary,
        ),
        caption: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: secondary,
        ),
        overline: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: secondary,
        ),
      );

  @override
  FoxTypography copyWith({
    TextStyle? wordmark,
    TextStyle? display,
    TextStyle? figureXl,
    TextStyle? figureLg,
    TextStyle? figureMd,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? body,
    TextStyle? bodySm,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? overline,
  }) {
    return FoxTypography(
      wordmark: wordmark ?? this.wordmark,
      display: display ?? this.display,
      figureXl: figureXl ?? this.figureXl,
      figureLg: figureLg ?? this.figureLg,
      figureMd: figureMd ?? this.figureMd,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      body: body ?? this.body,
      bodySm: bodySm ?? this.bodySm,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      overline: overline ?? this.overline,
    );
  }

  @override
  FoxTypography lerp(ThemeExtension<FoxTypography>? other, double t) {
    if (other is! FoxTypography) return this;
    TextStyle s(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return FoxTypography(
      wordmark: s(wordmark, other.wordmark),
      display: s(display, other.display),
      figureXl: s(figureXl, other.figureXl),
      figureLg: s(figureLg, other.figureLg),
      figureMd: s(figureMd, other.figureMd),
      h1: s(h1, other.h1),
      h2: s(h2, other.h2),
      h3: s(h3, other.h3),
      body: s(body, other.body),
      bodySm: s(bodySm, other.bodySm),
      label: s(label, other.label),
      caption: s(caption, other.caption),
      overline: s(overline, other.overline),
    );
  }
}
