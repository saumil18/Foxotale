import 'package:flutter/material.dart';

import '../../access/capability.dart';
import '../../app/scope.dart';
import '../../domain/models.dart';
import '../../theme/fox_theme.dart';
import '../../widgets/fox_common.dart';
import '../../widgets/fox_status_chip.dart';

/// PRD P0-4 — live room states; authorised roles can update.
class RoomsBoard extends StatelessWidget {
  const RoomsBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final c = context.fox;
    final canEdit = context.canEdit(Capability.roomInventoryStatus);
    final floors = repo.rooms.map((r) => r.floor).toSet().toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in RoomState.values)
              FoxStatusChip(
                label: '${s.label} ${repo.roomsInState(s)}',
                tone: toneForRoom(s),
                icon: iconForRoom(s),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (!canEdit)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              'You can see room status but not change it.',
              style: context.type.caption.copyWith(color: c.textMin),
            ),
          ),
        const SizedBox(height: 16),
        for (final floor in floors) ...[
          FoxSectionHeader('Floor $floor'),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.92,
            children: [
              for (final room
                  in repo.rooms.where((r) => r.floor == floor))
                _RoomCell(room: room, canEdit: canEdit),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _RoomCell extends StatelessWidget {
  const _RoomCell({required this.room, required this.canEdit});

  final Room room;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;
    final tone = toneForRoom(room.state);
    final (fg, bg) = switch (tone) {
      FoxStatusTone.success => (c.success, c.successTint),
      FoxStatusTone.warning => (c.warning, c.warningTint),
      FoxStatusTone.danger => (c.danger, c.dangerTint),
      FoxStatusTone.info => (c.info, c.infoTint),
      FoxStatusTone.neutral => (c.textTertiary, c.surfaceRaised),
    };

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: canEdit ? () => _pickState(context) : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: fg.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(room.number,
                      style: t.figureMd.copyWith(color: c.textPrimary)),
                  Icon(iconForRoom(room.state), size: 14, color: fg),
                ],
              ),
              const Spacer(),
              Text(room.state.label,
                  style: t.caption.copyWith(color: fg),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  void _pickState(BuildContext context) {
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
              child: Text('Room ${room.number} · ${room.type}',
                  style: context.type.h3),
            ),
            for (final s in RoomState.values)
              ListTile(
                leading: Icon(iconForRoom(s), size: 20),
                title: Text(s.label, style: context.type.body),
                trailing: s == room.state
                    ? Icon(Icons.check, color: context.fox.brandAction)
                    : null,
                onTap: () {
                  repo.setRoomState(room.number, s);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
