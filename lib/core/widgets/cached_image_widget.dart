import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )?
  errorBuilder;
  final Widget Function(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  )?
  loadingBuilder;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorBuilder != null
          ? errorBuilder!(context, Exception("Empty URL"), null)
          : _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) {
          if (loadingBuilder != null) {
            return loadingBuilder!(context, const SizedBox.shrink(), null);
          }
          return _buildShimmer();
        },
        errorWidget: (context, url, error) {
          if (errorBuilder != null) {
            return errorBuilder!(context, error, null);
          }
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey300,
      highlightColor: AppColors.grey100,
      child: Container(width: width, height: height, color: AppColors.white),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: AppColors.grey200,
          child: const Icon(Icons.broken_image, color: AppColors.grey),
        );
  }
}
