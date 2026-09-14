import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../domain/models.dart';
import '../../theme/fox_theme.dart';
import '../../util/fox_format.dart';
import '../../widgets/fox_common.dart';
import '../../widgets/fox_stat_tile.dart';
import '../../widgets/fox_status_chip.dart';

/// PRD P0-10 — arrivals, departures, in-house, revenue, paid vs pending.
class ReservationDashboard extends StatefulWidget {
  const ReservationDashboard({super.key});

  @override
  State<ReservationDashboard> createState() => _ReservationDashboardState();
}

class _ReservationDashboardState extends State<ReservationDashboard> {
  int _view = 0;

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final c = context.fox;
    final t = context.type;

    final lists = [repo.arrivals, repo.departures, repo.inHouse];
    final labels = ['Arrivals', 'Departures', 'In-house'];
    final current = lists[_view];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: FoxStatTile(
                  label: 'Arrivals', value: '${repo.arrivals.length}'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FoxStatTile(
                  label: 'Departures', value: '${repo.departures.length}'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FoxStatTile(
                  label: 'In-house',
                  value: '${repo.inHouse.length}',
                  qualifier: '${repo.occupancyPercent}% occupancy'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FoxStatTile(
                label: 'Payment received',
                value: rupeesShort(repo.paymentReceived),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FoxStatTile(
                label: 'Pending',
                value: rupeesShort(repo.paymentPending),
                qualifier: '${repo.pendingFolios} folios',
                needsAttention: repo.paymentPending > 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SegmentedButton<int>(
          segments: [
            for (var i = 0; i < labels.length; i++)
              ButtonSegment(
                  value: i, label: Text('${labels[i]} ${lists[i].length}')),
          ],
          selected: {_view},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _view = s.first),
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(t.caption),
            foregroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? c.onBrand
                  : c.textSecondary,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? c.brandAction
                  : c.surfaceBase,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (current.isEmpty)
          FoxEmptyState(
            headline: 'No ${labels[_view].toLowerCase()} today',
            detail: 'Nothing is scheduled for this date.',
            icon: Icons.event_available_outlined,
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: c.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var i = 0; i < current.length; i++)
                  _BookingRow(booking: current[i], first: i == 0),
              ],
            ),
          ),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking, required this.first});

  final Booking booking;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: c.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(booking.roomNumber, style: t.figureMd),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.guestName,
                    style: t.bodySm.copyWith(color: c.textPrimary)),
                const SizedBox(height: 2),
                Text('${booking.roomType} · ${booking.nights}N · ${booking.source}',
                    style: t.caption.copyWith(color: c.textMin)),
                const SizedBox(height: 6),
                FoxStatusChip(
                  label: booking.paymentState.label,
                  tone: toneForPayment(booking.paymentState),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rupees(booking.totalAmount), style: t.figureMd),
              if (booking.balance > 0) ...[
                const SizedBox(height: 2),
                Text('${rupees(booking.balance)} due',
                    style: t.caption.copyWith(color: c.warning)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
