/// Every gated capability in the app, one per row of PRD §7.
enum Capability {
  dashboardRevenue('Dashboard — revenue & financials'),
  dashboardOps('Dashboard — occupancy & ops'),
  bookingsView('Bookings — view'),
  bookingsManage('Bookings — create/modify/cancel'),
  roomInventoryStatus('Room & inventory status'),
  taskCreateAssign('Task management — create/assign'),
  taskExecuteOwn('Task management — execute own'),
  guestRequestsQueue('Guest requests queue'),
  revenueAnalyticsReports('Revenue & analytics reports'),
  rateAvailabilityRead('Rate / availability (read)'),
  teamView('Team / staff — view'),
  teamManage('Team / staff — manage'),
  approvals('Approvals & escalations'),
  guestChat('Guest chat / communication'),
  settingsOwnProfile('Settings — own profile'),
  reportsExport('Reports export'),
  propertySetup('Property setup / onboarding'),
  reservationDashboard('Reservation dashboard'),
  reportsAdvanced('Reports — advanced'),
  revenueModule('Revenue module'),
  guestManagement('Guest management'),
  corporateData('Corporate data'),
  chainSwitch('Chain / multi-property switch');

  const Capability(this.label);
  final String label;
}

/// PRD §7 legend: F = full, V = view only, A = approve/oversee, — = none.
enum Access {
  full('F', 'Full'),
  view('V', 'View only'),
  approve('A', 'Approve / oversee'),
  none('—', 'No access');

  const Access(this.code, this.label);
  final String code;
  final String label;

  bool get canSee => this != Access.none;
  bool get canEdit => this == Access.full;
  bool get canApprove => this == Access.full || this == Access.approve;
}
