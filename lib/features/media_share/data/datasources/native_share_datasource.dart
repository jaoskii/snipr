import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/error/exceptions.dart';

class NativeShareDataSource {
  Future<void> shareFile({
    required String filePath,
    String? mimeType,
    String? caption,
  }) async {
    try {
      final xFile = XFile(filePath, mimeType: mimeType);
      await Share.shareXFiles(
        [xFile],
        text: caption,
      );
    } catch (e) {
      throw MediaStorageException('Failed to open system share sheet: $e');
    }
  }

  Future<bool> saveToGallery({
    required String filePath,
    required bool isVideo,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw MediaStorageException('File does not exist: $filePath');
      }

      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && !ps.hasAccess && ps != PermissionState.limited) {
        throw const MediaStorageException('Photo library permission not granted');
      }

      if (isVideo) {
        await PhotoManager.editor.saveVideo(
          file,
          title: 'Snipr_Clip_${DateTime.now().millisecondsSinceEpoch}',
        );
        return true;
      } else {
        final bytes = await file.readAsBytes();
        await PhotoManager.editor.saveImage(
          bytes,
          title: 'Snipr_Image_${DateTime.now().millisecondsSinceEpoch}.png',
          filename: 'Snipr_Image_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        return true;
      }
    } catch (e) {
      throw MediaStorageException('Failed to save to gallery: $e');
    }
  }
}
