import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cached_image_widget.dart';

class CommonAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final File? imageFile;
  final ImageProvider? imageProvider;
  final Widget? fallbackWidget;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;

  const CommonAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.imageFile,
    this.imageProvider,
    this.fallbackWidget,
    this.size = 50.0,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    this.backgroundColor = AppColors.lightGrey,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
        boxShadow: boxShadow,
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedImageWidget(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: fallbackWidget ?? _defaultFallback(),
      );
    } else if (imageFile != null) {
      return Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallbackWidget ?? _defaultFallback(),
      );
    } else if (imageProvider != null) {
      return Image(
        image: imageProvider!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallbackWidget ?? _defaultFallback(),
      );
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallbackWidget ?? _defaultFallback(),
      );
    } else {
      return fallbackWidget ?? _defaultFallback();
    }
  }

  Widget _defaultFallback() {
    return Icon(
      Icons.person,
      size: size * 0.6,
      color: AppColors.grey,
    );
  }
}
