import '../../../../core/usecases/usecase.dart';
import '../entities/processing_progress.dart';
import '../entities/video_clip.dart';
import '../repositories/i_video_processor_repository.dart';

class TrimHighlightParams {
  final VideoClip clip;

  const TrimHighlightParams({
    required this.clip,
  });
}

class TrimVideoHighlight
    implements UseCase<Stream<ProcessingProgress>, TrimHighlightParams> {
  final IVideoProcessorRepository _repository;

  TrimVideoHighlight(this._repository);

  @override
  Stream<ProcessingProgress> call(TrimHighlightParams params) {
    return _repository.fastTrimHighlight(clip: params.clip);
  }
}
