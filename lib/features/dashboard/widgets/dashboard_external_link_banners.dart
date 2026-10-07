import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/common_button.dart';
import '../../services_firestore/models/banner_model.dart';
import '../../services_firestore/services/banner_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

class ExternalLinkBannersSection extends StatelessWidget {
  const ExternalLinkBannersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerService bannerService = BannerService();

    debugPrint('[Banners] ExternalLinkBannersSection built.');
    debugPrint('[Banners] Listening for active external banners stream...');

    return StreamBuilder<List<BannerModel>>(
      stream: bannerService.watchActiveBanners(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('[Banners] Stream error: ${snapshot.error}');

          return SizedBox(
            height: 170,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _FallbackBannerCard(
                title: AppLocalizations.of(context)!.bannersUnavailable,
                subtitle: AppLocalizations.of(context)!.pleaseTryAgainLater,
                buttonText: AppLocalizations.of(context)!.retry,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          debugPrint('[Banners] Stream is loading...');

          return const SizedBox(
            height: 170,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _LoadingBannerCard(),
            ),
          );
        }

        final allBanners = snapshot.data ?? const <BannerModel>[];
        final banners = allBanners
            .where((b) => b.type == 'external_link')
            .toList();

        debugPrint('[Banners] Received ${banners.length} banner(s).');

        for (final banner in banners) {
          debugPrint(
            '[Banners] Banner -> id: ${banner.id}, '
            'title: ${banner.title}, '
            'order: ${banner.order}, '
            'isActive: ${banner.isActive}, '
            'withBackground: ${banner.withBackground}, '
            'imageUrl: ${banner.imageUrl.isEmpty ? 'EMPTY' : banner.imageUrl}',
          );
        }

        if (banners.isEmpty) {
          debugPrint('[Banners] No active banners found. Showing fallback UI.');

          return SizedBox(
            height: 170,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _FallbackBannerCard(
                title: AppLocalizations.of(context)!.noActiveBanners,
                subtitle: AppLocalizations.of(
                  context,
                )!.newPromotionsWillAppearHere,
                buttonText: AppLocalizations.of(context)!.refresh,
              ),
            ),
          );
        }

        if (banners.length == 1) {
          return SizedBox(
            height: 170,
            width: double.infinity,
            child: _BannerCard(banner: banners.first),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: banners.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: _BannerCard(banner: banner),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final BannerModel banner;

  Future<void> _navigateToScreen(BuildContext context) async {
    if (banner.url == null || banner.url!.isEmpty) return;

    final Uri url = Uri.parse(banner.url!);

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the link")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool useRemoteBackground =
        banner.withBackground && banner.imageUrl.trim().isNotEmpty;
    final langCode = Localizations.localeOf(context).languageCode;

    final localizedBadge = banner.getLocalizedBadge(langCode);
    final localizedTitle = banner.getLocalizedTitle(langCode);
    final localizedSubtitle = banner.getLocalizedSubtitle(langCode);
    final localizedButtonText = banner.getLocalizedButtonText(langCode);

    debugPrint(
      '[Banners] Building banner card -> id: ${banner.id}, '
      'useRemoteBackground: $useRemoteBackground',
    );

    return GestureDetector(
      onTap: () => _navigateToScreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: useRemoteBackground
                  ? CachedImageWidget(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        debugPrint(
                          '[Banners] Failed to load network image for banner id: ${banner.id}. '
                          'Using local asset fallback.',
                        );

                        return Image.asset(
                          'assets/images/backgroung_banner.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/backgroung_banner.png',
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (localizedBadge.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        localizedBadge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  if (localizedBadge.trim().isNotEmpty)
                    const SizedBox(height: 6),
                  Text(
                    localizedTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizedSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (banner.hasButton)
                    CommonButton(
                      text: localizedButtonText.isNotEmpty
                          ? localizedButtonText
                          : AppLocalizations.of(context)!.bookNow,
                      onPressed: () => _navigateToScreen(context),
                      type: CommonButtonType.primary,
                      size: CommonButtonSize.medium,
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.colorFF00685F,
                      borderRadius: BorderRadius.circular(999),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBannerCard extends StatelessWidget {
  const _LoadingBannerCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Image.asset(
        'assets/images/backgroung_banner.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _FallbackBannerCard extends StatelessWidget {
  const _FallbackBannerCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });

  final String title;
  final String subtitle;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/backgroung_banner.png', fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                CommonButton(
                  text: buttonText,
                  onPressed: () {},
                  type: CommonButtonType.primary,
                  size: CommonButtonSize.medium,
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.colorFF00685F,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
