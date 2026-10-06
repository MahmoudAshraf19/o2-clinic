import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';

class MediaCompressor {
  /// Compresses an image and returns the compressed file path.
  static Future<String?> compressImage(String path) async {
    if (kIsWeb) return path;

    try {
      final ext = path.split('.').last.toLowerCase();
      if (ext == 'gif') return path; // Skip GIF compression

      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}${Platform.pathSeparator}COMP_${DateTime.now().millisecondsSinceEpoch}.jpg';

      CompressFormat format = CompressFormat.jpeg;
      if (ext == 'png') {
        // If it's PNG we can either compress as PNG or JPEG.
        // JPEG yields smaller sizes for photos, but we'll stick to original extension.
        format = CompressFormat.png;
      } else if (ext == 'webp') {
        format = CompressFormat.webp;
      }

      final targetPathWithExt =
          '${tempDir.path}${Platform.pathSeparator}COMP_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPathWithExt,
        quality:
            70, // 70% quality reduces size significantly while keeping good visual fidelity
        minWidth: 1080,
        minHeight: 1080,
        format: format,
      );

      return result?.path ?? path;
    } catch (e) {
      debugPrint('Image compression error: $e');
      return path; // fallback to original
    }
  }

  /// Compresses a video and returns the compressed file path.
  static Future<String?> compressVideo(String path) async {
    if (kIsWeb) return path;

    try {
      // Compress to Medium Quality (typically 720p or 480p depending on original)
      final info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      return info?.path ?? path;
    } catch (e) {
      debugPrint('Video compression error: $e');
      return path; // fallback to original
    }
  }

  /// Cancel video compression if needed
  static Future<void> cancelVideoCompression() async {
    if (kIsWeb) return;
    await VideoCompress.cancelCompression();
  }
}
