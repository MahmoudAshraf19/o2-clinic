import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';

class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key});

  static const String _heroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAXLdvpiYdPA7s-XmNyZLEsZpyr5Lp87slasXpki2Kx_Bu5ssBS4yS5DAsGef9ZzCJibFz8CUXsaNvwm79_GoEu34gGgzgsyNEOaxDZuzc0jKR5_3s_aE2dmAFte6zooMFUwyPic7DO7G5Ggz56Kg93o8A9FQXiycs_pwddzjRqVfJsHqntLB9zIIENq-XdzG7uMW0EZWHRyE81bCecqChXDHS5DxZQRMRX4xTRjLAVIfnJemO0Dzei26tmg8WokT7Zqvn_Zfrrmcs';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hero image frame.
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft shape behind the image.
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF69D1C5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              // Main image.
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F4),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedImageWidget(imageUrl: _heroImageUrl, fit: BoxFit.cover),
              ),

              // Top-right glass badge.
              Positioned(
                top: 14,
                right: 14,
                child: _GlassBadge(
                  icon: Icons.air,
                  iconColor: const Color(0xFF00685F),
                  title: AppLocalizations.of(context)!.o2,
                  subtitle: AppLocalizations.of(context)!.clinic,
                ),
              ),

              // Bottom-left glass badge.
              Positioned(
                bottom: 14,
                left: 14,
                child: _GlassBadge(
                  icon: Icons.favorite,
                  iconColor: const Color(0xFF8980F5),
                  title: AppLocalizations.of(context)!.patient,
                  subtitle: AppLocalizations.of(context)!.first,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Text block.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.startYournhealthJourney,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                  color: const Color(0xFF181C1D),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppLocalizations.of(context)!.signInToAccessYour,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  color: const Color(0xFF3E4947),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  color: const Color(0xFF181C1D),
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  color: const Color(0xFF6B6058),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

