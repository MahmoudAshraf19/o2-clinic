import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../../data/models/dashboard_health_chip_model.dart';

class DashboardHealthChips extends StatelessWidget {
  const DashboardHealthChips({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      final chips = controller.healthChips;

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [for (final chip in chips) _HealthChip(model: chip)],
      );
    });
  }
}

class _HealthChip extends StatelessWidget {
  const _HealthChip({required this.model});

  final DashboardHealthChipModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: model.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: model.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(model.icon, size: 16, color: model.foregroundColor),
          const SizedBox(width: 6),
          Text(
            model.title,
            style: TextStyle(
              color: model.foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
