import 'package:flutter/material.dart';

/// Chart palettes, machine-validated for lightness banding, chroma floor,
/// contrast against the chart surface, and separation under deuteranopia,
/// protanopia and tritanopia.
///
/// Re-run the validator before adding a colour here. Series colour is assigned
/// from an entity's stable identity, never from its position after sorting.
class FoxCharts {
  const FoxCharts._();

  static const categoricalLight = <Color>[
    Color(0xFFC2410C),
    Color(0xFF0D9488),
    Color(0xFF7C3AED),
    Color(0xFFA16207),
    Color(0xFF2563EB),
    Color(0xFFDB2777),
    Color(0xFF65A30D),
    Color(0xFF9333EA),
  ];

  static const categoricalDark = <Color>[
    Color(0xFFE35F2C),
    Color(0xFF12A794),
    Color(0xFF9075E8),
    Color(0xFFB4881F),
    Color(0xFF4E88E4),
    Color(0xFFDE6099),
    Color(0xFF78A026),
    Color(0xFF9C71DE),
  ];

  /// One hue, light to dark. Occupancy heat map, demand calendar.
  static const sequential = <Color>[
    Color(0xFFFFF1E6),
    Color(0xFFFFD9C0),
    Color(0xFFFFB98F),
    Color(0xFFFF8F52),
    Color(0xFFF26A22),
    Color(0xFFC74000),
    Color(0xFF963000),
    Color(0xFF6B2200),
  ];

  /// Two hues around a neutral midpoint. Budget versus actual variance.
  static const diverging = <Color>[
    Color(0xFF0F766E),
    Color(0xFF5EAAA3),
    Color(0xFFB7CFCB),
    Color(0xFFE5E1DC),
    Color(0xFFF3C4A8),
    Color(0xFFE08A52),
    Color(0xFFC2410C),
  ];

  static List<Color> categorical(Brightness b) =>
      b == Brightness.dark ? categoricalDark : categoricalLight;

  /// A ninth category folds into Other rather than generating a new hue.
  static Color series(Brightness b, int index) {
    final p = categorical(b);
    return index < p.length ? p[index] : const Color(0xFF78706A);
  }
}
