import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/fox_theme.dart';

class FoxField extends StatelessWidget {
  const FoxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.helper,
    this.keyboardType,
    this.prefix,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final String? helper;
  final TextInputType? keyboardType;
  final String? prefix;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: context.type.overline.copyWith(color: c.textMin)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: context.type.body.copyWith(color: c.textPrimary),
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: context.type.body.copyWith(color: c.textTertiary),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper!,
              style: context.type.caption.copyWith(color: c.textMin)),
        ],
      ],
    );
  }
}

class FoxNumberStepper extends StatelessWidget {
  const FoxNumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.step = 1,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: context.type.bodySm.copyWith(color: c.textPrimary)),
        ),
        _StepButton(
          icon: Icons.remove,
          onTap: value > min ? () => onChanged(value - step) : null,
        ),
        SizedBox(
          width: 52,
          child: Text('$value',
              textAlign: TextAlign.center, style: context.type.figureMd),
        ),
        _StepButton(
          icon: Icons.add,
          onTap: value < max ? () => onChanged(value + step) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Material(
      color: c.surfaceRaised,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon,
              size: 18,
              color: onTap == null ? c.textDisabled : c.brandAction),
        ),
      ),
    );
  }
}

class FoxToggleRow extends StatelessWidget {
  const FoxToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.detail,
    this.trailing,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? detail;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: value ? c.brandAction : c.textDisabled,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: context.type.bodySm
                          .copyWith(color: c.textPrimary)),
                  if (detail != null) ...[
                    const SizedBox(height: 2),
                    Text(detail!,
                        style:
                            context.type.caption.copyWith(color: c.textMin)),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
