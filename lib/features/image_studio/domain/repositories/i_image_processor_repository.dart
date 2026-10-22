import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../entities/image_export_config.dart';

abstract class IImageProcessorRepository {
  /// Rasterizes a RepaintBoundary key containing the background image and annotations
  /// into compressed image bytes (PNG/JPEG/WebP) and saves to a temporary file.
  Future<String> exportAnnotatedImage({
    required RenderRepaintBoundary boundary,
    required ImageExportConfig config,
    required double pixelRatio,
  });

  /// Saves image bytes to cache directory and returns file path
  Future<String> saveTemporaryImageBytes(Uint8List bytes, String extension);
}
