class VideoClip {
  final String sourcePath;
  final Duration totalDuration;
  final Duration trimStart;
  final Duration trimEnd;
  final int originalSizeBytes;
  final int width;
  final int height;
  final double fps;

  const VideoClip({
    required this.sourcePath,
    required this.totalDuration,
    required this.trimStart,
    required this.trimEnd,
    required this.originalSizeBytes,
    required this.width,
    required this.height,
    required this.fps,
  });

  Duration get selectedDuration => trimEnd - trimStart;

  bool get isTrimmed =>
      trimStart > Duration.zero || trimEnd < totalDuration;

  VideoClip copyWith({
    String? sourcePath,
    Duration? totalDuration,
    Duration? trimStart,
    Duration? trimEnd,
    int? originalSizeBytes,
    int? width,
    int? height,
    double? fps,
  }) {
    return VideoClip(
      sourcePath: sourcePath ?? this.sourcePath,
      totalDuration: totalDuration ?? this.totalDuration,
      trimStart: trimStart ?? this.trimStart,
      trimEnd: trimEnd ?? this.trimEnd,
      originalSizeBytes: originalSizeBytes ?? this.originalSizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
    );
  }
}
