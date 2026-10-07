import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat_doctors/views/patient_chat_screen.dart';
import '../models/doctor_model.dart';

class DoctorProfileScreen extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;

                    return isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: _LeftSection(doctor: doctor),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: _RightSection(doctor: doctor),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _LeftSection(doctor: doctor),
                              const SizedBox(height: 20),
                              _RightSection(doctor: doctor),
                            ],
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : AppColors.white.withValues(alpha: .95)),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: (Theme.of(context).brightness == Brightness.dark
                ? AppColors.colorFF60A5FA
                : AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            AppLocalizations.of(context)!.doctorProfile,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white
                  : AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }
}

class _LeftSection extends StatelessWidget {
  final DoctorModel doctor;

  const _LeftSection({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileCard(doctor: doctor),
        const SizedBox(height: 20),
        _StatsCard(doctor: doctor),
        const SizedBox(height: 20),
        _MessageButton(doctor: doctor),
      ],
    );
  }
}

class _MessageButton extends StatelessWidget {
  final DoctorModel doctor;

  const _MessageButton({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: CommonButton(
        text: AppLocalizations.of(context)!.chatMessage,
        onPressed: () {
          Get.to(() => PatientChatScreen(doctor: doctor));
        },
        icon: Icons.chat_bubble_rounded,
        iconPosition: IconPosition.left,
        type: CommonButtonType.primary,
        backgroundColor: (Theme.of(context).brightness == Brightness.dark
            ? AppColors.colorFF60A5FA
            : AppColors.primary),
        foregroundColor: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final DoctorModel doctor;

  const _ProfileCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.accent.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: CachedNetworkImageProvider(doctor.image),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            doctor.name,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w700,
              color: (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white
                  : AppColors.textPrimary),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            doctor.title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.colorFF60A5FA
                  : AppColors.primary),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.white70
                    : AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.cityMedicalCenter,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final DoctorModel doctor;

  const _StatsCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          _StatItem("15+", "Years Exp."),
          _Divider(),
          _StatItem("${doctor.rating}", "Rating", isStar: true),
          _Divider(),
          _StatItem("${doctor.reviews}+", "Patients"),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isStar;

  const _StatItem(this.value, this.label, {this.isStar = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.colorFF60A5FA
                        : AppColors.primary),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isStar)
                  const Icon(Icons.star, color: AppColors.amber, size: 18),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 60, color: AppColors.outlineVariant);
  }
}

class _RightSection extends StatelessWidget {
  final DoctorModel doctor;

  const _RightSection({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AboutCard(doctor: doctor),
        const SizedBox(height: 20),
        _Specializations(),
        const SizedBox(height: 20),
        _Credentials(),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  final DoctorModel doctor;

  const _AboutCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.about,
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            "Dr. ${doctor.name.split(' ').last} is a specialist in ${doctor.title}.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Specializations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.specializations,
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: const [
              _SpecItem(Icons.air, "Asthma"),
              _SpecItem(Icons.health_and_safety, "COPD"),
              _SpecItem(Icons.bed, "Sleep"),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SpecItem(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark
            ? AppColors.transparent
            : AppColors.surfaceContainer),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Credentials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          _CredentialItem(Icons.school, "MD, Pulmonology", "University"),
          SizedBox(height: 12),
          _CredentialItem(Icons.verified, "Board Certified", "Medical Board"),
        ],
      ),
    );
  }
}

class _CredentialItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CredentialItem(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(
        color: (Theme.of(context).brightness == Brightness.dark
            ? AppColors.colorFF60A5FA.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.06)),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
