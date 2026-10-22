import '../../../../core/usecases/usecase.dart';
import '../entities/compression_config.dart';
import '../entities/processing_progress.dart';
import '../entities/video_clip.dart';
import '../repositories/i_video_processor_repository.dart';

class CompressVideoParams {
  final VideoClip clip;
  final CompressionConfig config;

  const CompressVideoParams({
    required this.clip,
    required this.config,
  });
}

class CompressVideoToTargetSize
    implements UseCase<Stream<ProcessingProgress>, CompressVideoParams> {
  final IVideoProcessorRepository _repository;

  CompressVideoToTargetSize(this._repository);

  @override
  Stream<ProcessingProgress> call(CompressVideoParams params) {
    return _repository.compressVideo(
      clip: params.clip,
      config: params.config,
    );
  }
}
