import 'package:flutter/foundation.dart';

/// Build-time switches for affordances that exist so the app can be reviewed
/// before there is a backend, and that must not reach a real property.
class FoxBuild {
  const FoxBuild._();

  /// Shows the sign-in affordances that stand in for a missing identity
  /// provider: the role picker and the social sign-up buttons.
  ///
  /// Solution Design FR-S001 is that login *resolves* one role, and the
  /// architecture carries that role as a JWT claim — so a picker that lets the
  /// person choose their own permissions is not a login, it is a bypass of the
  /// §7 matrix. Social sign-up belongs to the Guest App (FR-G001); the Staff
  /// auth row does not mention it, and Staff accounts are provisioned rather
  /// than self-registered.
  ///
  /// Both stay on in debug so the simulator review keeps working, and both are
  /// off in release until the real provider lands. Override deliberately with:
  ///
  ///   flutter run --dart-define=FOXOTALE_REVIEW_SIGN_IN=true
  static const bool reviewSignIn = bool.fromEnvironment(
    'FOXOTALE_REVIEW_SIGN_IN',
    defaultValue: kDebugMode,
  );
}
