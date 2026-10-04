import 'package:flutter/material.dart';

import '../access/capability.dart';
import '../access/role.dart';
import '../features/dashboard/role_dashboard.dart';
import '../features/reports/reports_hub.dart';
import '../features/reservations/reservation_dashboard.dart';
import '../features/rooms/rooms_board.dart';
import '../features/settings/permissions_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../theme/fox_theme.dart';
import '../widgets/fox_header.dart';
import 'scope.dart';
import '../widgets/fox_brand_text.dart';

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.builder,
    this.capability,
  });

  final String label;
  final IconData icon;
  final WidgetBuilder builder;

  /// Null means always available. Otherwise the destination is not built at
  /// all unless the role can see it — hidden, not disabled.
  final Capability? capability;
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.onSignOut,
    required this.onToggleTheme,
    required this.onOpenSetup,
  });

  final VoidCallback onSignOut;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenSetup;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final role = context.role;
    final repo = context.repo;

    final all = <_Destination>[
      _Destination(
          label: 'Home',
          icon: Icons.dashboard_outlined,
          builder: (_) => RoleDashboard(onOpenSetup: widget.onOpenSetup)),
      _Destination(
        label: 'Reservations',
        icon: Icons.event_note_outlined,
        capability: Capability.reservationDashboard,
        builder: (_) => const ReservationDashboard(),
      ),
      _Destination(
        label: 'Rooms',
        icon: Icons.meeting_room_outlined,
        capability: Capability.roomInventoryStatus,
        builder: (_) => const RoomsBoard(),
      ),
      _Destination(
        label: 'Tasks',
        icon: Icons.checklist_outlined,
        capability: Capability.taskExecuteOwn,
        builder: (_) => TasksScreen(
          onlyMine: role == FoxRole.executive,
          me: 'Suresh Pillai',
        ),
      ),
      _Destination(
        label: 'Reports',
        icon: Icons.insights_outlined,
        capability: Capability.revenueAnalyticsReports,
        builder: (_) => const ReportsHub(),
      ),
    ];

    final available = all
        .where((d) => d.capability == null || context.can(d.capability!))
        .toList();
    final index = _index.clamp(0, available.length - 1);
    final current = available[index];

    return Scaffold(
      appBar: FoxHeader(
        // Home opens on a greeting, the way the reference header does; the
        // other tabs name the section instead, because a greeting repeated on
        // every tab stops meaning anything.
        title: index == 0 ? _greeting() : current.label,
        // The role is already on the badge beside it; the second line
        // carries where you are instead of repeating who you are.
        subtitle: '${repo.property.name} · ${repo.property.city}',
        trailing: context.can(Capability.chainSwitch)
            ? _SwitchPropertyButton(onPressed: () => _switchProperty(context))
            : FoxHeaderBadge(label: role.label),
        actions: [
          FoxHeaderAction(
            icon: Icons.brightness_6_outlined,
            tooltip: 'Toggle light and dark',
            onPressed: widget.onToggleTheme,
          ),
          FoxHeaderAction(
            icon: Icons.shield_outlined,
            tooltip: 'Permissions',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Permissions')),
                  body: const PermissionsScreen(),
                ),
              ),
            ),
          ),
          FoxHeaderAction(
            icon: Icons.logout_outlined,
            tooltip: 'Switch role',
            onPressed: widget.onSignOut,
          ),
        ],
      ),
      body: SafeArea(child: current.builder(context)),
      bottomNavigationBar: available.length < 2
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in available)
                  NavigationDestination(icon: Icon(d.icon), label: d.label),
              ],
            ),
    );
  }
}

/// Home greets by time of day. Front desk runs in shifts, so the greeting is
/// one of the few things on screen that tells a tired person which one they
/// are on.
String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// The property switcher, dressed for the gradient rather than for a surface.
class _SwitchPropertyButton extends StatelessWidget {
  const _SwitchPropertyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Material(
      color: c.glassFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: c.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Switch',
                  style: context.type.caption.copyWith(color: Colors.white)),
              const Icon(Icons.expand_more, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

void _switchProperty(BuildContext context) {
  final repo = context.repo;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Switch property', style: context.type.h3),
          ),
          for (final p in repo.properties)
            ListTile(
              title: FoxBrandText(p.name, style: context.type.body),
              subtitle: Text('${p.city} · ${p.totalRooms} rooms',
                  style: context.type.caption),
              trailing: p.id == repo.property.id
                  ? Icon(Icons.check, color: context.fox.brandAction)
                  : null,
              onTap: () {
                repo.property = p;
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}
