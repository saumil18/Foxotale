/// Business types shared across the FoxOtale apps. Pure Dart on purpose — no
/// Flutter import belongs in here, so the same models can back a CLI, a test
/// harness or a future server-side tool.
library;

export 'src/access/capability.dart';
export 'src/access/permissions.dart';
export 'src/access/role.dart';
export 'src/domain/models.dart';
export 'src/domain/setup_models.dart';
export 'src/util/fox_format.dart';
