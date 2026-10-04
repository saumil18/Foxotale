import 'package:flutter/material.dart';

import '../../app/scope.dart';
import 'package:foxotale_domain/foxotale_domain.dart';
import 'package:foxotale_ui/foxotale_ui.dart';
import 'setup_fields.dart';

class BasicsStep extends StatelessWidget {
  const BasicsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final d = repo.draft;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const FoxSectionHeader('Property',
            note: 'What guests see first, and what every report is filed under'),
        FoxField(
          label: 'Property name',
          value: d.name,
          hint: 'FoxOtale Jaipur',
          onChanged: (v) {
            d.name = v;
            repo.touchDraft();
          },
        ),
        const SizedBox(height: 18),
        FoxField(
          label: 'City',
          value: d.city,
          hint: 'Jaipur',
          onChanged: (v) {
            d.city = v;
            repo.touchDraft();
          },
        ),
        const SizedBox(height: 18),
        FoxField(
          label: 'Address',
          value: d.address,
          hint: 'Civil Lines, Jaipur, Rajasthan 302006',
          maxLines: 3,
          onChanged: (v) {
            d.address = v;
            repo.touchDraft();
          },
        ),
        const SizedBox(height: 22),
        Text('STAR RATING',
            style: context.type.overline.copyWith(color: context.fox.textMin)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final star in ['3', '4', '5'])
              ChoiceChip(
                label: Text('$star star'),
                selected: d.starRating == star,
                onSelected: (_) {
                  d.starRating = star;
                  repo.touchDraft();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class RoomsStep extends StatelessWidget {
  const RoomsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final d = repo.draft;
    final c = context.fox;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FoxSectionHeader('Room types',
            note: '${d.roomCount} rooms across ${d.rooms.length} types'),
        for (var i = 0; i < d.rooms.length; i++) ...[
          _RoomTypeCard(
            room: d.rooms[i],
            onChanged: repo.touchDraft,
            onRemove: d.rooms.length > 1
                ? () {
                    d.rooms.removeAt(i);
                    repo.touchDraft();
                  }
                : null,
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(
          onPressed: () {
            d.rooms.add(RoomTypeDraft(name: ''));
            repo.touchDraft();
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add room type'),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.surfaceSunken,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: c.textTertiary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Inventory count is how many of this type exist, not how many '
                  'are free today.',
                  style: context.type.caption.copyWith(color: c.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoomTypeCard extends StatelessWidget {
  const _RoomTypeCard({
    required this.room,
    required this.onChanged,
    this.onRemove,
  });

  final RoomTypeDraft room;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceBase,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: room.isComplete ? c.divider : c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: FoxField(
                  label: 'Type name',
                  value: room.name,
                  hint: 'Deluxe King',
                  onChanged: (v) {
                    room.name = v;
                    onChanged();
                  },
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_outline, color: c.textMin),
                  tooltip: 'Remove type',
                ),
            ],
          ),
          const SizedBox(height: 14),
          FoxNumberStepper(
            label: 'Rooms of this type',
            value: room.count,
            onChanged: (v) {
              room.count = v;
              onChanged();
            },
          ),
          const SizedBox(height: 6),
          FoxNumberStepper(
            label: 'Max occupancy',
            value: room.maxOccupancy,
            min: 1,
            max: 8,
            onChanged: (v) {
              room.maxOccupancy = v;
              onChanged();
            },
          ),
          const SizedBox(height: 14),
          FoxField(
            label: 'Base rate per night',
            value: room.baseRate == 0 ? '' : '${room.baseRate}',
            prefix: '₹ ',
            keyboardType: TextInputType.number,
            helper: 'Before taxes and meal plan supplements',
            onChanged: (v) {
              room.baseRate = int.tryParse(v) ?? 0;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class RatesStep extends StatelessWidget {
  const RatesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final d = repo.draft;
    final c = context.fox;
    final t = context.type;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const FoxSectionHeader('Rates',
            note: 'Base rates come from your room types. Adjust for demand here.'),
        for (final room in d.rooms)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: c.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          room.name.isEmpty ? 'Unnamed type' : room.name,
                          style: t.h3),
                    ),
                    Text(rupees(room.baseRate), style: t.figureMd),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _RateChip(
                        label: 'Weekend',
                        value: room.baseRate +
                            (room.baseRate * d.weekendUpliftPercent ~/ 100)),
                    const SizedBox(width: 8),
                    _RateChip(
                        label: 'Peak',
                        value: room.baseRate +
                            (room.baseRate * d.peakSeasonUpliftPercent ~/ 100)),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const FoxSectionHeader('Uplift'),
        FoxNumberStepper(
          label: 'Weekend uplift %',
          value: d.weekendUpliftPercent,
          max: 100,
          step: 5,
          onChanged: (v) {
            d.weekendUpliftPercent = v;
            repo.touchDraft();
          },
        ),
        const SizedBox(height: 6),
        FoxNumberStepper(
          label: 'Peak season uplift %',
          value: d.peakSeasonUpliftPercent,
          max: 200,
          step: 5,
          onChanged: (v) {
            d.peakSeasonUpliftPercent = v;
            repo.touchDraft();
          },
        ),
        const SizedBox(height: 12),
        FoxToggleRow(
          label: 'Rates include taxes',
          detail: 'Turn off if GST is added at checkout',
          value: d.taxInclusive,
          onChanged: (v) {
            d.taxInclusive = v;
            repo.touchDraft();
          },
        ),
      ],
    );
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label ${rupees(value)}',
          style: context.type.caption.copyWith(color: c.textSecondary)),
    );
  }
}

class MealPlansStep extends StatelessWidget {
  const MealPlansStep({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final d = repo.draft;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const FoxSectionHeader('Meal plans',
            note: 'What a rate includes, and what each upgrade adds'),
        for (final meal in d.mealPlans)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(color: context.fox.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                FoxToggleRow(
                  label: '${meal.plan.code} · ${meal.plan.label}',
                  detail: meal.plan.includes,
                  value: meal.enabled,
                  onChanged: (v) {
                    meal.enabled = v;
                    repo.touchDraft();
                  },
                ),
                if (meal.enabled && meal.plan != MealPlanCode.ep)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: FoxField(
                      label: 'Supplement per person per night',
                      value: meal.supplement == 0 ? '' : '${meal.supplement}',
                      prefix: '₹ ',
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        meal.supplement = int.tryParse(v) ?? 0;
                        repo.touchDraft();
                      },
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class FacilitiesStep extends StatelessWidget {
  const FacilitiesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final d = repo.draft;

    const groupLabels = {
      FacilityGroup.property: 'Property',
      FacilityGroup.room: 'In the room',
      FacilityGroup.dining: 'Dining',
      FacilityGroup.wellness: 'Wellness',
      FacilityGroup.business: 'Business & events',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FoxSectionHeader('Facilities',
            note: '${d.facilityCount} selected'),
        for (final group in FacilityGroup.values) ...[
          Text(groupLabels[group]!.toUpperCase(),
              style: context.type.overline
                  .copyWith(color: context.fox.textMin)),
          const SizedBox(height: 4),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border.all(color: context.fox.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (final f
                    in d.facilities.where((f) => f.group == group))
                  FoxToggleRow(
                    label: f.name,
                    value: f.available,
                    onChanged: (v) {
                      f.available = v;
                      repo.touchDraft();
                    },
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class NearbyStep extends StatelessWidget {
  const NearbyStep({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final d = repo.draft;
    final c = context.fox;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const FoxSectionHeader('Nearby & distances',
            note: 'How a guest judges whether you are convenient'),
        for (final landmark in d.landmarks)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: c.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(landmark.kind.label.toUpperCase(),
                    style: context.type.overline.copyWith(color: c.brandAction)),
                const SizedBox(height: 8),
                FoxField(
                  label: 'Name',
                  value: landmark.name,
                  onChanged: (v) {
                    landmark.name = v;
                    repo.touchDraft();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FoxField(
                        label: 'Distance',
                        value: landmark.distanceKm == 0
                            ? ''
                            : landmark.distanceKm.toString(),
                        hint: '12.4',
                        helper: 'km',
                        onChanged: (v) {
                          landmark.distanceKm = double.tryParse(v) ?? 0;
                          repo.touchDraft();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FoxField(
                        label: 'Drive time',
                        value:
                            landmark.minutes == 0 ? '' : '${landmark.minutes}',
                        hint: '28',
                        helper: 'minutes',
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          landmark.minutes = int.tryParse(v) ?? 0;
                          repo.touchDraft();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key, required this.onGoToStep});

  final ValueChanged<SetupStep> onGoToStep;

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final d = repo.draft;
    final c = context.fox;
    final t = context.type;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FoxSectionHeader(
          d.canPublish ? 'Ready to publish' : 'Not ready yet',
          note: d.canPublish
              ? 'Publishing makes this property bookable.'
              : d.incompleteSteps.length == 1
                  ? 'One step still needs attention.'
                  : '${d.incompleteSteps.length} steps still need attention.',
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: d.canPublish ? c.successTint : c.warningTint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                d.canPublish ? Icons.check_circle_outline : Icons.error_outline,
                size: 20,
                color: d.canPublish ? c.success : c.warning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FoxBrandText(
                  d.canPublish
                      ? '${d.name.isEmpty ? "This property" : d.name} has everything it needs to go live.'
                      : 'Finish the steps below before publishing.',
                  style: t.bodySm.copyWith(
                      color: d.canPublish ? c.success : c.warning),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (final step in SetupStep.values.where((s) => s != SetupStep.review))
          InkWell(
            onTap: () => onGoToStep(step),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: c.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.label, style: t.h3),
                        const SizedBox(height: 2),
                        Text(_summaryFor(step, d),
                            style: t.caption.copyWith(color: c.textMin)),
                      ],
                    ),
                  ),
                  FoxStatusChip(
                    label: d.isStepComplete(step) ? 'Complete' : 'Incomplete',
                    tone: d.isStepComplete(step)
                        ? FoxStatusTone.success
                        : FoxStatusTone.warning,
                  ),
                  Icon(Icons.chevron_right, color: c.textMin),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: d.canPublish && !d.published
              ? () {
                  repo.publishDraft();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${d.name} published — now bookable'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              : null,
          child: Text(d.published ? 'Published' : 'Publish property'),
        ),
        if (!d.canPublish) ...[
          const SizedBox(height: 8),
          Text(
            'Cannot publish — ${d.incompleteSteps.map((s) => s.label.toLowerCase()).join(", ")} incomplete.',
            style: t.caption.copyWith(color: c.warning),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _summaryFor(SetupStep step, PropertyDraft d) => switch (step) {
        SetupStep.basics =>
          d.name.isEmpty ? 'No name yet' : '${d.name} · ${d.city}',
        SetupStep.rooms => '${d.roomCount} rooms · ${d.rooms.length} types',
        SetupStep.rates =>
          'Weekend +${d.weekendUpliftPercent}% · Peak +${d.peakSeasonUpliftPercent}%',
        SetupStep.mealPlans => '${d.mealPlanCount} plans enabled',
        SetupStep.facilities => '${d.facilityCount} facilities',
        SetupStep.nearby =>
          '${d.landmarks.where((l) => l.isComplete).length} landmarks mapped',
        SetupStep.review => '',
      };
}
