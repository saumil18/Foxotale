import 'package:flutter/material.dart';

import 'package:foxotale_ui/foxotale_ui.dart';
import 'package:foxotale_domain/foxotale_domain.dart';

/// A live rendering of Design System v1, for review on device.
/// This is a review surface, not a product screen.
class DesignSystemReference extends StatefulWidget {
  const DesignSystemReference({super.key});

  @override
  State<DesignSystemReference> createState() => _DesignSystemReferenceState();
}

class _DesignSystemReferenceState extends State<DesignSystemReference> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _ColourTab(),
      const _TypeTab(),
      const _ComponentsTab(),
      const _ChartsTab(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.palette_outlined), label: 'Colour'),
          NavigationDestination(
              icon: Icon(Icons.text_fields_outlined), label: 'Type'),
          NavigationDestination(
              icon: Icon(Icons.widgets_outlined), label: 'Components'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined), label: 'Charts'),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.note});

  final String title;
  final String? note;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.type.h2),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note!, style: context.type.bodySm.copyWith(color: c.textMin)),
        ],
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 28),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.color, this.name, this.meta);

  final Color color;
  final String name;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: c.divider),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: context.type.caption.copyWith(
            color: c.textPrimary, fontWeight: FontWeight.w600)),
        Text(meta, style: context.type.caption.copyWith(color: c.textMin)),
      ],
    );
  }
}

class _ColourTab extends StatelessWidget {
  const _ColourTab();

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Brand',
          note: 'Fox Deep is the only orange permitted behind white text.',
          children: [
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
              children: [
                _Swatch(c.brandFlame, 'Fox Flame', '#FF4200 · fills'),
                _Swatch(c.brandEmber, 'Fox Ember', '#EA5F04 · mark'),
                _Swatch(c.brandAction, 'Fox Deep', '5.05:1 · text'),
              ],
            ),
          ],
        ),
        _Section(
          title: 'Semantic',
          note: 'Reserved. Never a chart series, never decorative.',
          children: [
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.72,
              children: [
                _Swatch(c.success, 'Success', '5.37:1'),
                _Swatch(c.warning, 'Warning', '5.10:1'),
                _Swatch(c.danger, 'Danger', '5.91:1'),
                _Swatch(c.info, 'Info', '6.47:1'),
              ],
            ),
          ],
        ),
        _Section(
          title: 'Text ramp',
          note: 'Nothing readable goes below textMin.',
          children: [
            for (final (style, label) in [
              (c.textPrimary, 'textPrimary · 17.98:1'),
              (c.textSecondary, 'textSecondary · 11.71:1'),
              (c.textTertiary, 'textTertiary · 7.50:1'),
              (c.textMin, 'textMin · 4.86:1 — the floor'),
              (c.textDisabled, 'textDisabled · 3.06:1 — not for content'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(label,
                    style: context.type.body.copyWith(color: style)),
              ),
          ],
        ),
      ],
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab();

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final c = context.fox;

    Widget row(String name, TextStyle style, String sample) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.toUpperCase(),
                  style: t.overline.copyWith(color: c.textMin)),
              const SizedBox(height: 4),
              Text(sample, style: style),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Scale',
          note: 'Inter for work. Lora only for the wordmark.',
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WORDMARK · LORA',
                      style: t.overline.copyWith(color: c.textMin)),
                  const SizedBox(height: 4),
                  FoxBrandText('FoxOtale', style: t.wordmark),
                ],
              ),
            ),
            row('figure.xl · tabular', t.figureXl, rupees(1248600)),
            row('figure.lg · tabular', t.figureLg, rupees(284000)),
            row('h1', t.h1, 'Reservations'),
            row('h2', t.h2, 'Arrivals today'),
            row('h3', t.h3, 'Room 204 · Deluxe King'),
            row('body', t.body, 'Payment received against this reservation.'),
            row('bodySm', t.bodySm, 'Updated 4 minutes ago by R. Sharma'),
            row('label', t.label, 'PAYMENT STATUS'),
            row('caption', t.caption, 'Queued while offline'),
          ],
        ),
        _Section(
          title: 'Tabular figures',
          note: 'Digits must align down the column. This is the whole point.',
          children: [
            for (final v in [8400, 6200, 1124750, 911, 284000])
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Folio', style: t.bodySm),
                    Text(rupees(v), style: t.figureMd),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Text('Abbreviated — tiles and axes only, never in a table',
                style: t.caption.copyWith(color: c.textMin)),
            const SizedBox(height: 4),
            Text('${rupeesShort(284000)}   ·   ${rupeesShort(12450000)}',
                style: t.figureMd),
            const SizedBox(height: 10),
            Text('Variance carries its sign', style: t.caption.copyWith(color: c.textMin)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(signedRupees(118000),
                    style: t.figureMd.copyWith(color: c.success)),
                const SizedBox(width: 16),
                Text(signedRupees(-42000),
                    style: t.figureMd.copyWith(color: c.danger)),
                const SizedBox(width: 16),
                Text(orDash(null, rupees),
                    style: t.figureMd.copyWith(color: c.textMin)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ComponentsTab extends StatelessWidget {
  const _ComponentsTab();

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Stat tiles',
          note: 'Orange only where the figure needs action.',
          children: [
            Row(
              children: [
                const Expanded(
                    child: FoxStatTile(label: 'Arrivals', value: '12')),
                const SizedBox(width: 10),
                const Expanded(
                    child: FoxStatTile(label: 'In-house', value: '64')),
                const SizedBox(width: 10),
                Expanded(
                  child: FoxStatTile(
                    label: 'Pending',
                    value: rupeesShort(284000),
                    qualifier: '8 folios',
                    needsAttention: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        _Section(
          title: 'Buttons',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton(onPressed: () {}, child: const Text('New booking')),
                OutlinedButton(onPressed: () {}, child: const Text('Assign')),
                TextButton(onPressed: () {}, child: const Text('View report')),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(backgroundColor: c.danger),
                  child: const Text('Cancel booking'),
                ),
              ],
            ),
          ],
        ),
        _Section(
          title: 'Room state',
          children: [
            Wrap(spacing: 8, runSpacing: 8, children: const [
              FoxStatusChip(
                  label: 'Vacant clean',
                  tone: FoxStatusTone.success,
                  icon: Icons.check_circle_outline),
              FoxStatusChip(
                  label: 'Vacant dirty',
                  tone: FoxStatusTone.warning,
                  icon: Icons.cleaning_services_outlined),
              FoxStatusChip(
                  label: 'Occupied',
                  tone: FoxStatusTone.info,
                  icon: Icons.person_outline),
              FoxStatusChip(
                  label: 'Out of order',
                  tone: FoxStatusTone.danger,
                  icon: Icons.block_outlined),
              FoxStatusChip(
                  label: 'Out of service', tone: FoxStatusTone.neutral),
            ]),
          ],
        ),
        _Section(
          title: 'Payment state',
          children: [
            Wrap(spacing: 8, runSpacing: 8, children: const [
              FoxStatusChip(label: 'Paid', tone: FoxStatusTone.success),
              FoxStatusChip(label: 'Part paid', tone: FoxStatusTone.info),
              FoxStatusChip(label: 'Pending', tone: FoxStatusTone.warning),
              FoxStatusChip(label: 'Overdue', tone: FoxStatusTone.danger),
            ]),
          ],
        ),
        _Section(
          title: 'Roles',
          note: 'Text in a neutral badge — never a per-role hue.',
          children: [
            Wrap(spacing: 6, runSpacing: 6, children: const [
              FoxRoleBadge(role: 'Owner'),
              FoxRoleBadge(role: 'Area GM'),
              FoxRoleBadge(role: 'GM / HM'),
              FoxRoleBadge(role: 'Ops Manager'),
              FoxRoleBadge(role: 'Supervisor'),
              FoxRoleBadge(role: 'Executive'),
            ]),
          ],
        ),
        _Section(
          title: 'Table row',
          note: 'Numbers right-aligned and tabular. Status as a chip.',
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: c.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    color: c.surfaceRaised,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 44,
                            child: Text('ROOM',
                                style: t.overline.copyWith(color: c.textMin))),
                        Expanded(
                            child: Text('GUEST',
                                style: t.overline.copyWith(color: c.textMin))),
                        Text('AMOUNT',
                            style: t.overline.copyWith(color: c.textMin)),
                      ],
                    ),
                  ),
                  for (final r in const [
                    ('204', 'Sharma, R.', 8400, 'Paid', FoxStatusTone.success),
                    ('118', 'Iyer, M.', 6200, 'Pending', FoxStatusTone.warning),
                    ('302', 'Khan, A.', 24750, 'Part paid', FoxStatusTone.info),
                    ('221', 'Deshpande, V.', 11900, 'Overdue',
                        FoxStatusTone.danger),
                  ])
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: c.divider)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 44,
                              child: Text(r.$1, style: t.figureMd)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(r.$2,
                                    style: t.bodySm
                                        .copyWith(color: c.textPrimary)),
                                const SizedBox(height: 3),
                                FoxStatusChip(label: r.$4, tone: r.$5),
                              ],
                            ),
                          ),
                          Text(rupees(r.$3), style: t.figureMd),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        _Section(
          title: 'Empty state',
          note: 'The one place the app is allowed to be warm.',
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: c.surfaceSunken,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.task_alt, size: 32, color: c.brandAction),
                  const SizedBox(height: 12),
                  Text('No tasks in your queue', style: t.h3),
                  const SizedBox(height: 4),
                  Text('You are caught up for this shift.',
                      style: t.bodySm.copyWith(color: c.textMin)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartsTab extends StatelessWidget {
  const _ChartsTab();

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;
    final brightness = Theme.of(context).brightness;
    final cat = FoxCharts.categorical(brightness);

    const segments = [
      ('Corporate', 4820000, 1284),
      ('OTA', 3140000, 902),
      ('Direct', 2260000, 640),
      ('Travel agent', 1180000, 331),
      ('Walk-in', 640000, 188),
      ('Banquet', 410000, 0),
    ];
    const maxRevenue = 4820000;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Segment productivity',
          note: 'Ranked bars, not a pie. Values labelled directly.',
          children: [
            for (var i = 0; i < segments.length; i++) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(segments[i].$1,
                        style: t.bodySm.copyWith(color: c.textPrimary)),
                  ),
                  Text(rupeesShort(segments[i].$2), style: t.figureMd),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    flex: (segments[i].$2 * 100 ~/ maxRevenue),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: cat[i],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 100 - (segments[i].$2 * 100 ~/ maxRevenue),
                      child: const SizedBox()),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
        _Section(
          title: 'Categorical palette',
          note: 'Validated for deuteranopia, protanopia and tritanopia.',
          children: [
            Row(
              children: [
                for (final col in cat)
                  Expanded(
                    child: Container(height: 34, color: col),
                  ),
              ],
            ),
          ],
        ),
        _Section(
          title: 'Sequential — occupancy',
          note: 'One hue, light to dark. Never a rainbow.',
          children: [
            Row(
              children: [
                for (final col in FoxCharts.sequential)
                  Expanded(child: Container(height: 28, color: col)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0%', style: t.caption.copyWith(color: c.textMin)),
                Text('100%', style: t.caption.copyWith(color: c.textMin)),
              ],
            ),
          ],
        ),
        _Section(
          title: 'Diverging — budget vs actual',
          note: 'Neutral grey midpoint, never a third hue.',
          children: [
            Row(
              children: [
                for (final col in FoxCharts.diverging)
                  Expanded(child: Container(height: 28, color: col)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('−30%', style: t.caption.copyWith(color: c.textMin)),
                Text('on plan', style: t.caption.copyWith(color: c.textMin)),
                Text('+30%', style: t.caption.copyWith(color: c.textMin)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
