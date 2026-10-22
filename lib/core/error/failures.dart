abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class VideoProcessingFailure extends Failure {
  const VideoProcessingFailure(super.message);
}

class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure(super.message);
}

class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message);
}

class ShareFailure extends Failure {
  const ShareFailure(super.message);
}
