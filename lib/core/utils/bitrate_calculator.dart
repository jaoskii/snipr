import 'dart:math' as math;

class BitrateCalculationResult {
  final int videoBitrateKbps;
  final int audioBitrateKbps;
  final int estimatedSizeBytes;
  final bool isSafeForTarget;

  const BitrateCalculationResult({
    required this.videoBitrateKbps,
    required this.audioBitrateKbps,
    required this.estimatedSizeBytes,
    required this.isSafeForTarget,
  });
}

class BitrateCalculator {
  static const int defaultAudioBitrateKbps = 128;
  static const int lowAudioBitrateKbps = 96;
  static const double safetyHeadroom = 0.95; // 5% container/muxing overhead margin

  /// Calculates video and audio bitrates required to strictly stay under [targetSizeBytes]
  /// for a given [duration].
  static BitrateCalculationResult calculate({
    required Duration duration,
    required int targetSizeBytes,
    bool includeAudio = true,
  }) {
    final double durationSeconds = math.max(0.5, duration.inMilliseconds / 1000.0);
    
    // Choose appropriate audio bitrate based on target budget
    int audioBitrateKbps = 0;
    if (includeAudio) {
      if (targetSizeBytes <= 5 * 1024 * 1024) {
        audioBitrateKbps = lowAudioBitrateKbps;
      } else {
        audioBitrateKbps = defaultAudioBitrateKbps;
      }
    }

    // Total available bits with 5% safety margin
    final double totalSafeBits = (targetSizeBytes * 8.0) * safetyHeadroom;
    final double totalBitrateKbps = totalSafeBits / durationSeconds / 1000.0;

    int videoBitrateKbps = (totalBitrateKbps - audioBitrateKbps).floor();
    
    // Clamp to minimum reasonable video bitrate
    if (videoBitrateKbps < 120) {
      videoBitrateKbps = 120;
    }

    // Estimate final size: ((video_kbps + audio_kbps) * 1000 / 8) * duration_sec
    final double totalKbps = (videoBitrateKbps + audioBitrateKbps).toDouble();
    final int estimatedSizeBytes = ((totalKbps * 1000.0 / 8.0) * durationSeconds / safetyHeadroom).round();

    return BitrateCalculationResult(
      videoBitrateKbps: videoBitrateKbps,
      audioBitrateKbps: audioBitrateKbps,
      estimatedSizeBytes: estimatedSizeBytes,
      isSafeForTarget: estimatedSizeBytes <= targetSizeBytes,
    );
  }
}
