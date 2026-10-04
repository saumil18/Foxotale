import 'package:flutter/material.dart';

import 'package:foxotale_domain/foxotale_domain.dart';
import '../../app/scope.dart';
import 'package:foxotale_ui/foxotale_ui.dart';

/// PRD P0-12 and R-1..R-3, R-8. Every chart has a table behind it — in v1 the
/// figures are keyed in by hand, so the operator needs to check them.
class ReportsHub extends StatefulWidget {
  const ReportsHub({super.key});

  @override
  State<ReportsHub> createState() => _ReportsHubState();
}

class _ReportsHubState extends State<ReportsHub> {
  int _range = 1;

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final c = context.fox;
    final t = context.type;
    final canExport = context.canEdit(Capability.reportsExport);
    final segments = [...repo.segments]
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Today')),
            ButtonSegment(value: 1, label: Text('MTD')),
            ButtonSegment(value: 2, label: Text('YTD')),
          ],
          selected: {_range},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _range = s.first),
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(t.caption),
            foregroundColor: WidgetStateProperty.resolveWith((s) =>
                s.contains(WidgetState.selected) ? c.onBrand : c.textSecondary),
            backgroundColor: WidgetStateProperty.resolveWith((s) =>
                s.contains(WidgetState.selected) ? c.brandAction : c.surfaceBase),
          ),
        ),
        const SizedBox(height: 20),
        FoxSectionHeader(
          'Budget vs actual',
          note: 'Revenue against plan',
          trailing: canExport
              ? TextButton(onPressed: () {}, child: const Text('Export'))
              : null,
        ),
        _VarianceTable(),
        const SizedBox(height: 28),
        const FoxSectionHeader('Segment productivity',
            note: 'Ranked by revenue. Room nights and ARR alongside.'),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                color: c.surfaceRaised,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text('SEGMENT',
                            style: t.overline.copyWith(color: c.textMin))),
                    Expanded(
                        flex: 2,
                        child: Text('NIGHTS',
                            textAlign: TextAlign.right,
                            style: t.overline.copyWith(color: c.textMin))),
                    Expanded(
                        flex: 3,
                        child: Text('REVENUE',
                            textAlign: TextAlign.right,
                            style: t.overline.copyWith(color: c.textMin))),
                  ],
                ),
              ),
              for (var i = 0; i < segments.length; i++)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.divider)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: FoxCharts.series(
                                    Theme.of(context).brightness,
                                    repo.segments.indexOf(segments[i])),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(segments[i].segment.label,
                                  style: t.bodySm
                                      .copyWith(color: c.textPrimary),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          segments[i].roomNights == 0
                              ? '—'
                              : '${segments[i].roomNights}',
                          textAlign: TextAlign.right,
                          style: t.figureMd,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(rupeesShort(segments[i].revenue),
                            textAlign: TextAlign.right, style: t.figureMd),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (context.can(Capability.corporateData)) ...[
          const SizedBox(height: 28),
          const FoxSectionHeader('Key accounts',
              note: 'Corporates, travel agents and event companies by revenue'),
          for (final account in repo.corporates)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.surfaceBase,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account.name, style: t.h3),
                        const SizedBox(height: 2),
                        Text(
                          '${account.kind} · ${account.roomNights} nights · ARR ${rupees(account.arr)}',
                          style: t.caption.copyWith(color: c.textMin),
                        ),
                      ],
                    ),
                  ),
                  Text(rupeesShort(account.revenue), style: t.figureMd),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _VarianceTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final c = context.fox;
    final t = context.type;

    Widget row(String label, String value, {Color? tone, bool bold = false}) =>
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: bold
                        ? t.h3
                        : t.bodySm.copyWith(color: c.textSecondary)),
              ),
              Text(value,
                  style: t.figureMd.copyWith(color: tone ?? c.textPrimary)),
            ],
          ),
        );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          row('Actual', rupees(repo.revenueMtd), bold: true),
          row('Budget', rupees(repo.budgetMtd)),
          row('Variance', signedRupees(repo.varianceMtd),
              tone: repo.varianceMtd >= 0 ? c.success : c.danger),
          row('ARR', rupees(repo.arr)),
          row('Occupancy', '${repo.occupancyPercent}%'),
        ],
      ),
    );
  }
}
