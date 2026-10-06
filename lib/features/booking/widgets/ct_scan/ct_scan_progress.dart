import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CTScanProgress extends StatelessWidget {
  const CTScanProgress({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final items = <_StepMeta>[
      _StepMeta(
        icon: Icons.design_services_rounded,
        label: AppLocalizations.of(context)!.service,
      ),
      _StepMeta(
        icon: Icons.person_rounded,
        label: AppLocalizations.of(context)!.doctor,
      ),
      _StepMeta(
        icon: Icons.access_time_rounded,
        label: AppLocalizations.of(context)!.time,
      ),
      _StepMeta(
        icon: Icons.verified_rounded,
        label: AppLocalizations.of(context)!.confirm,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _StepNode(meta: items[i], active: currentStep >= i + 1),
          if (i != items.length - 1)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: currentStep >= i + 2
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        )
                      : null,
                  color: currentStep >= i + 2 ? null : AppColors.border,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepMeta {
  const _StepMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.meta, required this.active});

  final _StepMeta meta;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  )
                : null,
            color: active ? null : const Color(0xffF1F4FA),
            border: Border.all(
              color: active ? Colors.transparent : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: active
                    ? AppColors.primary.withValues(alpha: .18)
                    : Colors.black.withValues(alpha: .03),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            meta.icon,
            size: 18,
            color: active ? Colors.white : AppColors.grey,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          meta.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.primary : AppColors.grey,
          ),
        ),
      ],
    );
  }
}
