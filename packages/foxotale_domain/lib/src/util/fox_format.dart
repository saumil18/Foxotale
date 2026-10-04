/// Indian numbering: last three digits, then groups of two.
String groupIndian(int value) {
  final neg = value < 0;
  final s = value.abs().toString();
  if (s.length <= 3) return neg ? '-$s' : s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  final out = '${parts.join(',')},$last3';
  return neg ? '-$out' : out;
}

/// Full precision, for table cells and anything the user may compare down.
String rupees(int value) => '₹ ${groupIndian(value)}';

/// Abbreviated, for stat tiles and axis ticks where width is constrained.
/// Never use inside a table.
String rupeesShort(int value) {
  final a = value.abs();
  final sign = value < 0 ? '-' : '';
  if (a >= 10000000) {
    return '$sign₹ ${(a / 10000000).toStringAsFixed(2)}Cr';
  }
  if (a >= 100000) return '$sign₹ ${(a / 100000).toStringAsFixed(2)}L';
  return '$sign₹ ${groupIndian(a)}';
}

/// Variance always carries its sign, so direction is never inferred from colour.
String signedRupees(int value) =>
    value >= 0 ? '+${rupees(value)}' : '-${rupees(value.abs())}';

/// A figure not yet keyed in is an em dash, never a zero. In v1 all revenue
/// data is entered by hand, so "nobody entered this" and "this is zero" are
/// different facts.
String orDash(int? value, String Function(int) fmt) =>
    value == null ? '—' : fmt(value);
