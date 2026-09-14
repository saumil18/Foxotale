import 'package:flutter/material.dart';

import '../domain/models.dart';
import '../theme/fox_theme.dart';
import 'fox_status_chip.dart';

FoxStatusTone toneForRoom(RoomState s) => switch (s) {
      RoomState.vacantClean => FoxStatusTone.success,
      RoomState.inspected => FoxStatusTone.success,
      RoomState.vacantDirty => FoxStatusTone.warning,
      RoomState.occupied => FoxStatusTone.info,
      RoomState.outOfOrder => FoxStatusTone.danger,
      RoomState.outOfService => FoxStatusTone.neutral,
    };

IconData iconForRoom(RoomState s) => switch (s) {
      RoomState.vacantClean => Icons.check_circle_outline,
      RoomState.inspected => Icons.verified_outlined,
      RoomState.vacantDirty => Icons.cleaning_services_outlined,
      RoomState.occupied => Icons.person_outline,
      RoomState.outOfOrder => Icons.block_outlined,
      RoomState.outOfService => Icons.build_outlined,
    };

FoxStatusTone toneForPayment(PaymentState s) => switch (s) {
      PaymentState.paid => FoxStatusTone.success,
      PaymentState.partPaid => FoxStatusTone.info,
      PaymentState.pending => FoxStatusTone.warning,
      PaymentState.overdue => FoxStatusTone.danger,
    };

FoxStatusTone toneForTask(TaskState s) => switch (s) {
      TaskState.done => FoxStatusTone.success,
      TaskState.inProgress => FoxStatusTone.warning,
      TaskState.assigned => FoxStatusTone.info,
      TaskState.blocked => FoxStatusTone.danger,
      TaskState.unassigned => FoxStatusTone.neutral,
    };

/// Screen section header. Sections are named, never numbered — the order of
/// cards on a dashboard is not information.
class FoxSectionHeader extends StatelessWidget {
  const FoxSectionHeader(this.title, {super.key, this.trailing, this.note});

  final String title;
  final Widget? trailing;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.type.h2),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(note!,
                      style: context.type.caption.copyWith(color: c.textMin)),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// States the fact, then offers the next action. No apology.
class FoxEmptyState extends StatelessWidget {
  const FoxEmptyState({
    super.key,
    required this.headline,
    required this.detail,
    this.icon = Icons.task_alt,
    this.action,
    this.mascot = false,
  });

  final String headline;
  final String detail;
  final IconData icon;
  final Widget? action;

  /// The one place the Staff App is allowed to be warm. Never on a report,
  /// a room board, or beside a revenue figure.
  final bool mascot;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (mascot)
            Image.asset('assets/brand/fox_mascot.png',
                height: 132, fit: BoxFit.contain)
          else
            Icon(icon, size: 32, color: c.brandAction),
          const SizedBox(height: 12),
          Text(headline, style: context.type.h3, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(detail,
              style: context.type.bodySm.copyWith(color: c.textMin),
              textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Persistent while the signal is weak, and names how many updates are queued
/// rather than just claiming to be offline.
class FoxOfflineBanner extends StatelessWidget {
  const FoxOfflineBanner({super.key, required this.queued});

  final int queued;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: c.warningTint,
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 16, color: c.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              queued == 1
                  ? 'Offline — 1 update will send when you reconnect'
                  : 'Offline — $queued updates will send when you reconnect',
              style: context.type.caption.copyWith(color: c.warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled figure. Label small and quiet, value loud.
class FoxFigure extends StatelessWidget {
  const FoxFigure({
    super.key,
    required this.label,
    required this.value,
    this.tone,
    this.sub,
  });

  final String label;
  final String value;
  final Color? tone;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(),
            style: context.type.overline.copyWith(color: c.textMin)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value,
              style: context.type.figureLg
                  .copyWith(color: tone ?? c.textPrimary)),
        ),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(sub!, style: context.type.caption.copyWith(color: c.textMin)),
        ],
      ],
    );
  }
}
