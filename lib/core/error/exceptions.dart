class FFmpegException implements Exception {
  final String message;
  final int? returnCode;
  const FFmpegException(this.message, {this.returnCode});

  @override
  String toString() => 'FFmpegException: $message (ReturnCode: $returnCode)';
}

class CanvasRenderException implements Exception {
  final String message;
  const CanvasRenderException(this.message);

  @override
  String toString() => 'CanvasRenderException: $message';
}

class MediaStorageException implements Exception {
  final String message;
  const MediaStorageException(this.message);

  @override
  String toString() => 'MediaStorageException: $message';
}
