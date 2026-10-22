enum ImageOutputFormat { png, jpeg, webp }

class ImageExportConfig {
  final ImageOutputFormat format;
  final int quality; // 1 - 100
  final double scaleFactor; // 1.0 (original), 0.75, 0.5
  final bool lockAspectRatio;

  const ImageExportConfig({
    this.format = ImageOutputFormat.jpeg,
    this.quality = 85,
    this.scaleFactor = 1.0,
    this.lockAspectRatio = true,
  });

  ImageExportConfig copyWith({
    ImageOutputFormat? format,
    int? quality,
    double? scaleFactor,
    bool? lockAspectRatio,
  }) {
    return ImageExportConfig(
      format: format ?? this.format,
      quality: quality ?? this.quality,
      scaleFactor: scaleFactor ?? this.scaleFactor,
      lockAspectRatio: lockAspectRatio ?? this.lockAspectRatio,
    );
  }
}
