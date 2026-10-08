import 'package:flutter/material.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

/// Pulsing placeholder shown while bookings load (no extra packages needed).
class AppointmentsLoadingView extends StatefulWidget {
  final int itemCount;
  const AppointmentsLoadingView({super.key, this.itemCount = 4});

  @override
  State<AppointmentsLoadingView> createState() =>
      _AppointmentsLoadingViewState();
}

class _AppointmentsLoadingViewState extends State<AppointmentsLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.45, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: widget.itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  Widget _bar(double width, double height, {double radius = 8}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.grey200,
      borderRadius: BorderRadius.circular(radius),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _bar(52, 52, radius: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(140, 14),
                    const SizedBox(height: 8),
                    _bar(90, 11),
                  ],
                ),
              ),
              _bar(60, 24, radius: 10),
            ],
          ),
          const SizedBox(height: 14),
          _bar(double.infinity, 44, radius: 16),
        ],
      ),
    );
  }
}
