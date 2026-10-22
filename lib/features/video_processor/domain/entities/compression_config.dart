import '../../../../core/constants/platform_presets.dart';

class CompressionConfig {
  final PlatformPreset preset;
  final int targetSizeBytes;
  final int targetFps;
  final String targetResolution; // e.g. '1280x720', '1920x1080', 'original'
  final bool muteAudio;
  final bool fastStreamCopy; // lossless cut without re-encode if size already fits
  final bool includeWatermark; // overlay 'Created with MediaShrink' at bottom

  const CompressionConfig({
    required this.preset,
    required this.targetSizeBytes,
    required this.targetFps,
    required this.targetResolution,
    this.muteAudio = false,
    this.fastStreamCopy = false,
    this.includeWatermark = true,
  });

  factory CompressionConfig.fromPreset(PlatformPreset preset) {
    return CompressionConfig(
      preset: preset,
      targetSizeBytes: preset.targetSizeBytes,
      targetFps: preset.defaultFps,
      targetResolution: preset.recommendedResolution,
      includeWatermark: true,
    );
  }

  CompressionConfig copyWith({
    PlatformPreset? preset,
    int? targetSizeBytes,
    int? targetFps,
    String? targetResolution,
    bool? muteAudio,
    bool? fastStreamCopy,
    bool? includeWatermark,
  }) {
    return CompressionConfig(
      preset: preset ?? this.preset,
      targetSizeBytes: targetSizeBytes ?? this.targetSizeBytes,
      targetFps: targetFps ?? this.targetFps,
      targetResolution: targetResolution ?? this.targetResolution,
      muteAudio: muteAudio ?? this.muteAudio,
      fastStreamCopy: fastStreamCopy ?? this.fastStreamCopy,
      includeWatermark: includeWatermark ?? this.includeWatermark,
    );
  }
}
