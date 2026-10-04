import 'package:flutter/material.dart';

import '../../app/scope.dart';
import 'package:foxotale_domain/foxotale_domain.dart';
import 'package:foxotale_ui/foxotale_ui.dart';
import 'setup_steps.dart';

/// PRD P0-9 — Owner/GM configures rooms, rates, meal plans, inventory,
/// facilities, nearby points and distances. The property becomes bookable
/// when complete.
class SetupWizard extends StatefulWidget {
  const SetupWizard({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  SetupStep _step = SetupStep.basics;

  void _go(SetupStep s) => setState(() => _step = s);

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final d = repo.draft;
    final c = context.fox;
    final t = context.type;

    final index = SetupStep.values.indexOf(_step);
    final isLast = _step == SetupStep.review;
    final canAdvance = isLast || d.isStepComplete(_step);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up property'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Leave setup',
          onPressed: widget.onFinished,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Step ${index + 1} of ${SetupStep.values.length} · ${_step.detail}',
                        style: t.caption.copyWith(
                            color: Theme.of(context).brightness ==
                                    Brightness.light
                                ? c.onBrand
                                : c.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(d.progress * 100).round()}%',
                      style: t.caption.copyWith(
                          color: Theme.of(context).brightness ==
                                  Brightness.light
                              ? c.onBrand
                              : c.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: d.progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : c.brandAction,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepRail(current: _step, draft: d, onTap: _go),
            Divider(height: 1, color: c.divider),
            Expanded(child: _body()),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surfaceBase,
            border: Border(top: BorderSide(color: c.divider)),
          ),
          child: Row(
            children: [
              if (index > 0)
                OutlinedButton(
                  onPressed: () => _go(SetupStep.values[index - 1]),
                  child: const Text('Back'),
                ),
              const Spacer(),
              if (!isLast)
                FilledButton(
                  onPressed: canAdvance
                      ? () => _go(SetupStep.values[index + 1])
                      : null,
                  child: Text(
                      _step == SetupStep.nearby ? 'Review' : 'Continue'),
                )
              else
                FilledButton(
                  onPressed: widget.onFinished,
                  child: Text(d.published ? 'Go to app' : 'Finish later'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() => switch (_step) {
        SetupStep.basics => const BasicsStep(),
        SetupStep.rooms => const RoomsStep(),
        SetupStep.rates => const RatesStep(),
        SetupStep.mealPlans => const MealPlansStep(),
        SetupStep.facilities => const FacilitiesStep(),
        SetupStep.nearby => const NearbyStep(),
        SetupStep.review => ReviewStep(onGoToStep: _go),
      };
}

/// A horizontal rail rather than a stepper: seven steps do not fit as a
/// Material stepper on a phone, and the rail lets someone jump back to the one
/// thing they left incomplete.
class _StepRail extends StatelessWidget {
  const _StepRail({
    required this.current,
    required this.draft,
    required this.onTap,
  });

  final SetupStep current;
  final PropertyDraft draft;
  final ValueChanged<SetupStep> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final step in SetupStep.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => onTap(step),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: step == current ? c.brandAction : c.surfaceRaised,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      if (step != SetupStep.review)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            draft.isStepComplete(step)
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 13,
                            color: step == current
                                ? c.onBrand
                                : draft.isStepComplete(step)
                                    ? c.success
                                    : c.textMin,
                          ),
                        ),
                      Text(
                        step.label,
                        style: t.caption.copyWith(
                          color:
                              step == current ? c.onBrand : c.textSecondary,
                          fontWeight: step == current
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
