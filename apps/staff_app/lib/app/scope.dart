import 'package:flutter/material.dart';

import 'package:foxotale_domain/foxotale_domain.dart';
import '../data/repository.dart';

class FoxScope extends InheritedNotifier<FoxRepository> {
  const FoxScope({super.key, required FoxRepository repo, required super.child})
      : super(notifier: repo);

  static FoxRepository of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FoxScope>()!.notifier!;
}

extension FoxAccess on BuildContext {
  FoxRepository get repo => FoxScope.of(this);
  FoxRole get role => FoxScope.of(this).role;

  /// Hidden, not disabled (PRD P0-1).
  bool can(Capability c) => Permissions.canSee(role, c);
  bool canEdit(Capability c) => Permissions.canEdit(role, c);
  Access access(Capability c) => Permissions.of(role, c);
}
