import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/platform_presets.dart';
import '../../data/datasources/ffmpeg_video_datasource.dart';
import '../../data/repositories/video_processor_repository_impl.dart';
import '../../domain/entities/compression_config.dart';
import '../../domain/entities/processing_progress.dart';
import '../../domain/entities/video_clip.dart';
import '../../domain/usecases/compress_video_to_target_size.dart';
import '../../domain/usecases/trim_video_highlight.dart';
import 'video_studio_state.dart';

final videoDataSourceProvider = Provider<FFmpegVideoDataSource>((ref) {
  return FFmpegVideoDataSource();
});

final videoRepositoryProvider = Provider<VideoProcessorRepositoryImpl>((ref) {
  return VideoProcessorRepositoryImpl(ref.watch(videoDataSourceProvider));
});

final compressVideoUseCaseProvider = Provider<CompressVideoToTargetSize>((ref) {
  return CompressVideoToTargetSize(ref.watch(videoRepositoryProvider));
});

final trimVideoUseCaseProvider = Provider<TrimVideoHighlight>((ref) {
  return TrimVideoHighlight(ref.watch(videoRepositoryProvider));
});

final videoStudioControllerProvider =
    StateNotifierProvider.autoDispose<VideoStudioController, VideoStudioState>((ref) {
  return VideoStudioController(
    compressVideoUseCase: ref.watch(compressVideoUseCaseProvider),
    trimVideoUseCase: ref.watch(trimVideoUseCaseProvider),
    repository: ref.watch(videoRepositoryProvider),
  );
});

class VideoStudioController extends StateNotifier<VideoStudioState> {
  final CompressVideoToTargetSize _compressVideoUseCase;
  final TrimVideoHighlight _trimVideoUseCase;
  final VideoProcessorRepositoryImpl _repository;
  StreamSubscription<ProcessingProgress>? _progressSub;

  VideoStudioController({
    required CompressVideoToTargetSize compressVideoUseCase,
    required TrimVideoHighlight trimVideoUseCase,
    required VideoProcessorRepositoryImpl repository,
  })  : _compressVideoUseCase = compressVideoUseCase,
        _trimVideoUseCase = trimVideoUseCase,
        _repository = repository,
        super(VideoStudioState.initial());

  Future<void> loadVideoFile(String filePath, {required Duration duration, int? width, int? height, double? fps}) async {
    final file = File(filePath);
    final sizeBytes = await file.length();

    final clip = VideoClip(
      sourcePath: filePath,
      totalDuration: duration,
      trimStart: Duration.zero,
      trimEnd: duration,
      originalSizeBytes: sizeBytes,
      width: width ?? 1920,
      height: height ?? 1080,
      fps: fps ?? 60.0,
    );

    state = state.copyWith(
      clip: clip,
      isInitialized: true,
      currentPosition: Duration.zero,
    );
  }

  void updateTrimRange(Duration start, Duration end) {
    if (state.clip == null) return;
    state = state.copyWith(
      clip: state.clip!.copyWith(
        trimStart: start,
        trimEnd: end,
      ),
    );
  }

  void selectPreset(PlatformPreset preset) {
    state = state.copyWith(
      config: CompressionConfig.fromPreset(preset),
    );
  }

  void toggleMute(bool mute) {
    state = state.copyWith(
      config: state.config.copyWith(muteAudio: mute),
    );
  }

  void toggleWatermark(bool enable) {
    state = state.copyWith(
      config: state.config.copyWith(includeWatermark: enable),
    );
  }

  void updateResolution(String resolution) {
    state = state.copyWith(
      config: state.config.copyWith(targetResolution: resolution),
    );
  }

  void updateFps(int fps) {
    state = state.copyWith(
      config: state.config.copyWith(targetFps: fps),
    );
  }

  void startCompression() {
    if (state.clip == null) return;

    _progressSub?.cancel();
    state = state.copyWith(
      progress: ProcessingProgress.running(
        stage: ProcessingStage.analyzing,
        percentage: 0.0,
        message: 'Initializing video encoding engine...',
      ),
    );

    final stream = _compressVideoUseCase(CompressVideoParams(
      clip: state.clip!,
      config: state.config,
    ));

    _progressSub = stream.listen((progress) {
      state = state.copyWith(progress: progress);
    }, onError: (err) {
      state = state.copyWith(
        progress: ProcessingProgress.error(err.toString()),
      );
    });
  }

  void startLosslessTrim() {
    if (state.clip == null) return;

    _progressSub?.cancel();
    final stream = _trimVideoUseCase(TrimHighlightParams(clip: state.clip!));

    _progressSub = stream.listen((progress) {
      state = state.copyWith(progress: progress);
    }, onError: (err) {
      state = state.copyWith(
        progress: ProcessingProgress.error(err.toString()),
      );
    });
  }

  void cancelCurrentJob() {
    _repository.cancelProcessing();
    _progressSub?.cancel();
    state = state.copyWith(progress: ProcessingProgress.initial());
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    super.dispose();
  }
}
