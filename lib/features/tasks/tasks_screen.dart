import 'package:flutter/material.dart';

import '../../access/capability.dart';
import '../../app/scope.dart';
import '../../domain/models.dart';
import '../../theme/fox_theme.dart';
import '../../widgets/fox_common.dart';
import '../../widgets/fox_status_chip.dart';

/// PRD P0-5 — create/assign for authorised roles, execute/complete for the
/// assignee. Status and owner on every task.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key, this.onlyMine = false, this.me = ''});

  /// Executives see only their own work, so the list is pre-filtered rather
  /// than offering an "all tasks" toggle they may not use.
  final bool onlyMine;
  final String me;

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final canAssign = context.canEdit(Capability.taskCreateAssign);
    final tasks = onlyMine ? repo.tasksFor(me) : repo.tasks;

    final open = tasks.where((t) => t.state != TaskState.done).toList();
    final done = tasks.where((t) => t.state == TaskState.done).toList();

    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: FoxEmptyState(
          headline: 'No tasks in your queue',
          detail: 'You are caught up for this shift.',
          mascot: true,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FoxSectionHeader('Open', note: '${open.length} to clear'),
        for (final task in open)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TaskCard(task: task, canAssign: canAssign),
          ),
        if (done.isNotEmpty) ...[
          const SizedBox(height: 16),
          FoxSectionHeader('Done', note: '${done.length} this shift'),
          for (final task in done)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TaskCard(task: task, canAssign: canAssign),
            ),
        ],
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.canAssign});

  final StaffTask task;
  final bool canAssign;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;
    final repo = context.repo;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceBase,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: task.isOverdue ? c.danger : c.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(task.title, style: t.h3)),
              if (task.roomNumber != null)
                Text('Room ${task.roomNumber}',
                    style: t.caption.copyWith(color: c.textMin)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FoxStatusChip(
                  label: task.state.label, tone: toneForTask(task.state)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${task.kind.label} · ${task.assignee}',
                  style: t.caption.copyWith(color: c.textMin),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (task.isOverdue)
                Text('Overdue',
                    style: t.caption
                        .copyWith(color: c.danger, fontWeight: FontWeight.w600)),
            ],
          ),
          if (task.state != TaskState.done) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (task.state == TaskState.unassigned && canAssign)
                  OutlinedButton(
                    onPressed: () => repo.assignTask(task.id, 'Suresh Pillai'),
                    child: const Text('Assign'),
                  )
                else
                  FilledButton(
                    onPressed: () =>
                        repo.setTaskState(task.id, TaskState.done),
                    child: const Text('Mark complete'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
