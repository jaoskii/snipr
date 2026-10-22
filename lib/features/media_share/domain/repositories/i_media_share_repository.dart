abstract class IMediaShareRepository {
  /// Invokes system share sheet to share file directly to Discord, WhatsApp, etc.
  Future<void> shareFile({
    required String filePath,
    String? mimeType,
    String? caption,
  });

  /// Saves the processed file into the user's phone Photo/Video Gallery
  Future<bool> saveToGallery({
    required String filePath,
    required bool isVideo,
  });
}
