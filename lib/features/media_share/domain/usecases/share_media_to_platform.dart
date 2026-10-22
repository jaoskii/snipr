import '../../../../core/usecases/usecase.dart';
import '../repositories/i_media_share_repository.dart';

class ShareMediaParams {
  final String filePath;
  final String? mimeType;
  final String? caption;

  const ShareMediaParams({
    required this.filePath,
    this.mimeType,
    this.caption,
  });
}

class ShareMediaToPlatform implements UseCase<Future<void>, ShareMediaParams> {
  final IMediaShareRepository _repository;

  ShareMediaToPlatform(this._repository);

  @override
  Future<void> call(ShareMediaParams params) {
    return _repository.shareFile(
      filePath: params.filePath,
      mimeType: params.mimeType,
      caption: params.caption,
    );
  }
}
