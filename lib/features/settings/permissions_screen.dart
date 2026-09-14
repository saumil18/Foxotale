import 'package:flutter/material.dart';

import '../../access/capability.dart';
import '../../access/permissions.dart';
import '../../app/scope.dart';
import '../../theme/fox_theme.dart';
import '../../gallery/gallery_screen.dart';
import '../../widgets/fox_common.dart';

/// A live view of PRD §7 as implemented. The matrix in the PRD is a draft to be
/// corrected, so it is inspectable on device rather than buried in code.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;
    final role = context.role;

    Color colourFor(Access a) => switch (a) {
          Access.full => c.success,
          Access.view => c.info,
          Access.approve => c.warning,
          Access.none => c.textDisabled,
        };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FoxSectionHeader('What ${role.label} can reach',
            note: 'PRD §7, as implemented. Correct anything wrong here.'),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (var i = 0; i < Capability.values.length; i++)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : Border(top: BorderSide(color: c.divider)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(Capability.values[i].label,
                            style: t.bodySm.copyWith(color: c.textPrimary)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Permissions.of(role, Capability.values[i]).label,
                        style: t.caption.copyWith(
                          color: colourFor(
                              Permissions.of(role, Capability.values[i])),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FoxSectionHeader('Why Owner cannot edit bookings',
            note: 'Confirmed — this is deliberate, not a gap'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surfaceSunken,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scope descends. Capability does not.', style: t.h3),
              const SizedBox(height: 6),
              Text(
                'The hierarchy decides how much an Owner can see — every '
                'property, every number. It does not hand them every action. '
                'Modifying a booking and answering a guest belong to the people '
                'running the property. An owner who also runs a hotel signs in '
                'as GM / HM and gets those there.',
                style: t.bodySm.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Design System v1')),
                body: const DesignSystemReference(),
              ),
            ),
          ),
          icon: const Icon(Icons.palette_outlined, size: 18),
          label: const Text('Design System v1 reference'),
        ),
        const SizedBox(height: 24),
        FoxSectionHeader('Legend'),
        for (final a in Access.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(a.code,
                      style: t.figureMd.copyWith(color: colourFor(a))),
                ),
                Text(a.label, style: t.bodySm.copyWith(color: c.textSecondary)),
              ],
            ),
          ),
      ],
    );
  }
}
