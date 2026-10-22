import '../entities/compression_config.dart';
import '../entities/processing_progress.dart';
import '../entities/video_clip.dart';

abstract class IVideoProcessorRepository {
  /// Compresses [clip] according to [config] targeting exact file size and resolution
  Stream<ProcessingProgress> compressVideo({
    required VideoClip clip,
    required CompressionConfig config,
  });

  /// Extracts a highlight segment instantly using fast stream copy without re-encoding
  Stream<ProcessingProgress> fastTrimHighlight({
    required VideoClip clip,
  });

  /// Cancels an ongoing video encoding session
  Future<void> cancelProcessing();
}
