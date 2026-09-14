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
import '../widgets/fox_status_chip.dart';
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
      appBar: AppBar(
        title: Text(current.label),
        actions: [
          IconButton(
            tooltip: 'Toggle light and dark',
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.brightness_6_outlined),
          ),
          IconButton(
            tooltip: 'Permissions',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Permissions')),
                  body: const PermissionsScreen(),
                ),
              ),
            ),
            icon: const Icon(Icons.shield_outlined),
          ),
          IconButton(
            tooltip: 'Switch role',
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _ContextBar(
            role: role,
            property: repo.property.name,
            canSwitch: context.can(Capability.chainSwitch),
          ),
        ),
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

class _ContextBar extends StatelessWidget {
  const _ContextBar({
    required this.role,
    required this.property,
    required this.canSwitch,
  });

  final FoxRole role;
  final String property;
  final bool canSwitch;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final repo = context.repo;
    final light = Theme.of(context).brightness == Brightness.light;
    final onBar = light ? c.onBrand : c.textPrimary;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(Icons.apartment_outlined, size: 15, color: onBar),
          const SizedBox(width: 8),
          Expanded(
            child: FoxBrandText(
              property,
              style: context.type.caption.copyWith(color: onBar),
              // On the orange bar the brand O would disappear into the
              // chrome, so the name reads in one colour there.
              accent: light ? onBar : null,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (canSwitch)
            TextButton(
              onPressed: () => _switchProperty(context),
              style: TextButton.styleFrom(
                foregroundColor: onBar,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Row(
                children: [
                  Text('Switch', style: context.type.caption.copyWith(color: onBar)),
                  Icon(Icons.expand_more, size: 16, color: onBar),
                ],
              ),
            )
          else
            FoxRoleBadge(role: repo.role.label),
        ],
      ),
    );
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
}
