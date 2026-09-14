import 'capability.dart';
import 'role.dart';

/// PRD §7, transcribed cell by cell. The matrix is authoritative.
///
/// It was confirmed that the matrix — not assumption 1's "strict ladder" — is
/// correct where the two disagree. The ladder describes *visibility scope*, not
/// capability inheritance: an Owner sees every property, but does not modify
/// bookings or answer guest chat. Those are operational acts that belong to the
/// people running the property. An owner who also runs a hotel signs in under
/// the GM/HM role and gets those capabilities there.
///
/// So a role's power is not a superset of the role beneath it, and any future
/// change must not "fix" this by making it one.
class Permissions {
  const Permissions._();

  static const _f = Access.full;
  static const _v = Access.view;
  static const _a = Access.approve;
  static const _n = Access.none;

  // Column order: owner, areaGm, areaHm, gmHm, opsManager, supervisor, executive
  static const Map<Capability, List<Access>> _matrix = {
    Capability.dashboardRevenue: [_f, _f, _v, _f, _v, _n, _n],
    Capability.dashboardOps: [_f, _f, _f, _f, _f, _v, _n],
    Capability.bookingsView: [_v, _v, _v, _f, _f, _v, _v],
    Capability.bookingsManage: [_n, _n, _v, _f, _f, _v, _n],
    Capability.roomInventoryStatus: [_v, _v, _v, _f, _f, _f, _v],
    Capability.taskCreateAssign: [_v, _v, _v, _f, _f, _f, _n],
    Capability.taskExecuteOwn: [_n, _n, _f, _f, _f, _f, _f],
    Capability.guestRequestsQueue: [_v, _v, _v, _f, _f, _f, _f],
    Capability.revenueAnalyticsReports: [_f, _f, _v, _f, _v, _n, _n],
    Capability.rateAvailabilityRead: [_v, _v, _v, _f, _f, _v, _n],
    Capability.teamView: [_f, _f, _f, _f, _f, _v, _n],
    Capability.teamManage: [_a, _v, _v, _f, _v, _n, _n],
    Capability.approvals: [_a, _a, _a, _f, _v, _n, _n],
    Capability.guestChat: [_n, _n, _v, _f, _f, _f, _f],
    Capability.settingsOwnProfile: [_f, _f, _f, _f, _f, _f, _f],
    Capability.reportsExport: [_f, _f, _v, _f, _v, _n, _n],
    Capability.propertySetup: [_f, _v, _v, _f, _v, _n, _n],
    Capability.reservationDashboard: [_f, _f, _f, _f, _f, _v, _n],
    Capability.reportsAdvanced: [_f, _f, _v, _f, _v, _n, _n],
    Capability.revenueModule: [_f, _f, _v, _f, _v, _n, _n],
    Capability.guestManagement: [_f, _f, _v, _f, _v, _n, _n],
    Capability.corporateData: [_f, _f, _v, _f, _v, _n, _n],
    Capability.chainSwitch: [_f, _f, _f, _n, _n, _n, _n],
  };

  static Access of(FoxRole role, Capability capability) =>
      _matrix[capability]![role.index];

  /// Unauthorised capabilities are hidden, not disabled (PRD P0-1).
  static bool canSee(FoxRole role, Capability c) => of(role, c).canSee;
  static bool canEdit(FoxRole role, Capability c) => of(role, c).canEdit;

  static List<Capability> visibleTo(FoxRole role) =>
      Capability.values.where((c) => canSee(role, c)).toList();
}
