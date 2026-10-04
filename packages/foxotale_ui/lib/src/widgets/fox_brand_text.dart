import 'package:flutter/material.dart';

import '../theme/fox_theme.dart';

/// Renders any text containing the brand name with its capital O in the brand
/// colour, matching the FOXOTALE logo lockup.
///
/// The O uses Fox Deep rather than Fox Flame: at body size on a light surface
/// Fox Flame measures 3.48:1 and fails AA, while Fox Deep passes at 5.05:1 and
/// is indistinguishable at this scale. The logo artwork keeps the original.
class FoxBrandText extends StatelessWidget {
  const FoxBrandText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.accent,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  /// Override the O's colour. Pass the surrounding text colour on brand-orange
  /// chrome, where a Fox Deep O would vanish into the background.
  final Color? accent;

  static const _brand = 'FoxOtale';
  static const _oIndex = 3;

  @override
  Widget build(BuildContext context) {
    final base = style ?? context.type.body;
    final accented =
        base.copyWith(color: accent ?? context.fox.brandAction);

    final spans = <TextSpan>[];
    var cursor = 0;
    while (true) {
      final hit = text.indexOf(_brand, cursor);
      if (hit == -1) {
        spans.add(TextSpan(text: text.substring(cursor)));
        break;
      }
      if (hit > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, hit)));
      }
      spans
        ..add(TextSpan(text: _brand.substring(0, _oIndex)))
        ..add(TextSpan(text: _brand[_oIndex], style: accented))
        ..add(TextSpan(text: _brand.substring(_oIndex + 1)));
      cursor = hit + _brand.length;
    }

    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
