import '../../../../core/constants/platform_presets.dart';
import '../../domain/entities/compression_config.dart';
import '../../domain/entities/processing_progress.dart';
import '../../domain/entities/video_clip.dart';

class VideoStudioState {
  final VideoClip? clip;
  final CompressionConfig config;
  final ProcessingProgress progress;
  final bool isInitialized;
  final bool isPlaying;
  final Duration currentPosition;

  const VideoStudioState({
    this.clip,
    required this.config,
    required this.progress,
    this.isInitialized = false,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
  });

  factory VideoStudioState.initial() => VideoStudioState(
        config: CompressionConfig.fromPreset(PlatformPreset.videoPresets.first),
        progress: ProcessingProgress.initial(),
      );

  VideoStudioState copyWith({
    VideoClip? clip,
    CompressionConfig? config,
    ProcessingProgress? progress,
    bool? isInitialized,
    bool? isPlaying,
    Duration? currentPosition,
  }) {
    return VideoStudioState(
      clip: clip ?? this.clip,
      config: config ?? this.config,
      progress: progress ?? this.progress,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}
