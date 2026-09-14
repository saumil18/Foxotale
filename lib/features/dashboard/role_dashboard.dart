import 'package:flutter/material.dart';

import '../../access/capability.dart';
import '../../access/role.dart';
import '../../app/scope.dart';
import '../../domain/models.dart';
import '../../theme/fox_charts.dart';
import '../../theme/fox_theme.dart';
import '../../util/fox_format.dart';
import '../../widgets/fox_common.dart';
import '../../widgets/fox_stat_tile.dart';
import '../../widgets/fox_status_chip.dart';
import '../../widgets/fox_brand_text.dart';

/// PRD P0-2 — each role lands on a dashboard scoped to its permissions.
/// Owner sees money; a supervisor sees the shift queue.
class RoleDashboard extends StatelessWidget {
  const RoleDashboard({super.key, required this.onOpenSetup});

  final VoidCallback onOpenSetup;

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final role = context.role;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Greeting(role: role),
        const SizedBox(height: 20),
        if (context.canEdit(Capability.propertySetup) &&
            !repo.draft.published) ...[
          _SetupPrompt(onOpen: onOpenSetup),
          const SizedBox(height: 24),
        ],
        if (context.can(Capability.dashboardRevenue)) ...[
          const _RevenueBlock(),
          const SizedBox(height: 24),
        ],
        if (context.can(Capability.dashboardOps)) ...[
          const _OpsBlock(),
          const SizedBox(height: 24),
        ],
        if (context.can(Capability.reservationDashboard)) ...[
          const _TodayBlock(),
          const SizedBox(height: 24),
        ],
        if (context.can(Capability.revenueAnalyticsReports)) ...[
          const _SegmentBlock(),
          const SizedBox(height: 24),
        ],
        if (role == FoxRole.executive || role == FoxRole.supervisor) ...[
          FoxSectionHeader('Your queue',
              note: '${repo.openTasks} open · ${repo.overdueTasks} overdue'),
          for (final task in repo.tasks
              .where((t) => t.state != TaskState.done)
              .take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MiniTask(task: task),
            ),
        ],
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.role});

  final FoxRole role;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final repo = context.repo;
    final hour = DateTime.now().hour;
    final part = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(part, style: context.type.h1),
        const SizedBox(height: 4),
        Row(
          children: [
            FoxRoleBadge(role: role.label),
            const SizedBox(width: 8),
            Expanded(
              child: FoxBrandText(repo.property.name,
                  style: context.type.bodySm.copyWith(color: c.textMin),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );
  }
}

/// Setup is unfinished, so the property is not yet bookable. Says what is
/// missing rather than nagging.
class _SetupPrompt extends StatelessWidget {
  const _SetupPrompt({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;
    final draft = context.repo.draft;
    final left = draft.incompleteSteps;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, size: 18, color: c.brandAction),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Property is not live yet', style: t.h3),
              ),
              Text('${(draft.progress * 100).round()}%',
                  style: t.figureMd.copyWith(color: c.brandAction)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: draft.progress,
              minHeight: 6,
              backgroundColor: c.surfaceRaised,
              valueColor: AlwaysStoppedAnimation(c.brandAction),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            left.isEmpty
                ? 'Everything is filled in. Publish to go bookable.'
                : 'Still to do: ${left.map((s) => s.label.toLowerCase()).join(", ")}.',
            style: t.bodySm.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onOpen,
            child: Text(left.isEmpty ? 'Review and publish' : 'Continue setup'),
          ),
        ],
      ),
    );
  }
}

class _RevenueBlock extends StatelessWidget {
  const _RevenueBlock();

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final c = context.fox;
    final variance = repo.varianceMtd;
    final onPlan = variance >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FoxSectionHeader('Revenue',
            note: 'Month to date, against plan'),
        Row(
          children: [
            Expanded(
              child: FoxStatTile(
                  label: 'Revenue MTD', value: rupeesShort(repo.revenueMtd)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FoxStatTile(
                  label: 'Budget MTD', value: rupeesShort(repo.budgetMtd)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.surfaceBase,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.divider),
          ),
          child: Row(
            children: [
              Icon(onPlan ? Icons.trending_up : Icons.trending_down,
                  size: 18, color: onPlan ? c.success : c.danger),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  onPlan ? 'Ahead of plan' : 'Behind plan',
                  style: context.type.bodySm.copyWith(color: c.textPrimary),
                ),
              ),
              Text(
                signedRupees(variance),
                style: context.type.figureMd
                    .copyWith(color: onPlan ? c.success : c.danger),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: FoxStatTile(label: 'ARR', value: rupees(repo.arr))),
            const SizedBox(width: 10),
            Expanded(
              child: FoxStatTile(
                  label: 'Occupancy', value: '${repo.occupancyPercent}%'),
            ),
          ],
        ),
      ],
    );
  }
}

class _OpsBlock extends StatelessWidget {
  const _OpsBlock();

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FoxSectionHeader('Operations', note: 'Right now'),
        Row(
          children: [
            Expanded(
              child: FoxStatTile(
                  label: 'Open tasks',
                  value: '${repo.openTasks}',
                  qualifier: '${repo.overdueTasks} overdue',
                  needsAttention: repo.overdueTasks > 0),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FoxStatTile(
                  label: 'Requests', value: '${repo.openRequests}'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FoxStatTile(
                  label: 'Out of order',
                  value: '${repo.roomsInState(RoomState.outOfOrder)}',
                  needsAttention:
                      repo.roomsInState(RoomState.outOfOrder) > 0),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodayBlock extends StatelessWidget {
  const _TodayBlock();

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FoxSectionHeader('Today', note: 'Reservation position'),
        Row(
          children: [
            Expanded(
                child: FoxStatTile(
                    label: 'Arrivals', value: '${repo.arrivals.length}')),
            const SizedBox(width: 10),
            Expanded(
                child: FoxStatTile(
                    label: 'Departures', value: '${repo.departures.length}')),
            const SizedBox(width: 10),
            Expanded(
                child: FoxStatTile(
                    label: 'In-house', value: '${repo.inHouse.length}')),
          ],
        ),
      ],
    );
  }
}

class _SegmentBlock extends StatelessWidget {
  const _SegmentBlock();

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final c = context.fox;
    final t = context.type;
    final palette = FoxCharts.categorical(Theme.of(context).brightness);
    final segments = [...repo.segments]
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    final max = segments.first.revenue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FoxSectionHeader('Where business comes from',
            note: 'Revenue by segment, month to date'),
        for (var i = 0; i < segments.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: Text(segments[i].segment.label,
                    style: t.bodySm.copyWith(color: c.textPrimary)),
              ),
              Text(rupeesShort(segments[i].revenue), style: t.figureMd),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: segments[i].revenue / max,
              minHeight: 10,
              backgroundColor: c.surfaceRaised,
              valueColor: AlwaysStoppedAnimation(
                  palette[repo.segments.indexOf(segments[i])]),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${segments[i].roomNights} room nights · ARR ${rupees(segments[i].arr)}',
            style: t.caption.copyWith(color: c.textMin),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _MiniTask extends StatelessWidget {
  const _MiniTask({required this.task});

  final StaffTask task;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceBase,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: task.isOverdue ? c.danger : c.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: context.type.h3),
                const SizedBox(height: 4),
                Text(
                  task.roomNumber == null
                      ? task.kind.label
                      : '${task.kind.label} · Room ${task.roomNumber}',
                  style: context.type.caption.copyWith(color: c.textMin),
                ),
              ],
            ),
          ),
          FoxStatusChip(
              label: task.state.label, tone: toneForTask(task.state)),
        ],
      ),
    );
  }
}
