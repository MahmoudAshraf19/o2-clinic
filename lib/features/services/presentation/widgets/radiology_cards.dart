import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/radiology_controller.dart';
import 'radiology_card_item.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';
import 'package:o2_clinic/common/widgets/common_empty_state.dart';

class RadiologyCards extends StatelessWidget {
  RadiologyCards({super.key});

  final controller = Get.put(RadiologyController());

  int _cols(double w) {
    if (w < 600) return 1;
    if (w < 1000) return 2;
    return 3;
  }

  double _aspectRatio(double w) {
    if (w < 600) return 1.15; // 🔥 shorter cards (fix long issue)
    if (w < 1000) return 1.05;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isLoading.value && controller.services.isEmpty) {
        return const Center(child: CommonLoadingIndicator());
      }

      if (controller.services.isEmpty) {
        return const CommonEmptyState(title: "No radiology services available");
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.services.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _cols(w),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: _aspectRatio(w),
        ),
        itemBuilder: (context, index) {
          return RadiologyCardItem(model: controller.services[index]);
        },
      );
    });
  }
}
