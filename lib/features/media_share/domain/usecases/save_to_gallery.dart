import '../../../../core/usecases/usecase.dart';
import '../repositories/i_media_share_repository.dart';

class SaveToGalleryParams {
  final String filePath;
  final bool isVideo;

  const SaveToGalleryParams({
    required this.filePath,
    required this.isVideo,
  });
}

class SaveToGallery implements UseCase<Future<bool>, SaveToGalleryParams> {
  final IMediaShareRepository _repository;

  SaveToGallery(this._repository);

  @override
  Future<bool> call(SaveToGalleryParams params) {
    return _repository.saveToGallery(
      filePath: params.filePath,
      isVideo: params.isVideo,
    );
  }
}
