import '../../domain/repositories/i_media_share_repository.dart';
import '../datasources/native_share_datasource.dart';

class MediaShareRepositoryImpl implements IMediaShareRepository {
  final NativeShareDataSource _dataSource;

  MediaShareRepositoryImpl(this._dataSource);

  @override
  Future<void> shareFile({
    required String filePath,
    String? mimeType,
    String? caption,
  }) {
    return _dataSource.shareFile(
      filePath: filePath,
      mimeType: mimeType,
      caption: caption,
    );
  }

  @override
  Future<bool> saveToGallery({
    required String filePath,
    required bool isVideo,
  }) {
    return _dataSource.saveToGallery(
      filePath: filePath,
      isVideo: isVideo,
    );
  }
}
