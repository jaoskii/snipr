import '../../domain/entities/compression_config.dart';
import '../../domain/entities/processing_progress.dart';
import '../../domain/entities/video_clip.dart';
import '../../domain/repositories/i_video_processor_repository.dart';
import '../datasources/ffmpeg_video_datasource.dart';

class VideoProcessorRepositoryImpl implements IVideoProcessorRepository {
  final FFmpegVideoDataSource _dataSource;

  VideoProcessorRepositoryImpl(this._dataSource);

  @override
  Stream<ProcessingProgress> compressVideo({
    required VideoClip clip,
    required CompressionConfig config,
  }) {
    return _dataSource.compressVideo(
      clip: clip,
      config: config,
    );
  }

  @override
  Stream<ProcessingProgress> fastTrimHighlight({
    required VideoClip clip,
  }) {
    return _dataSource.fastTrimHighlight(clip: clip);
  }

  @override
  Future<void> cancelProcessing() {
    return _dataSource.cancelProcessing();
  }
}
