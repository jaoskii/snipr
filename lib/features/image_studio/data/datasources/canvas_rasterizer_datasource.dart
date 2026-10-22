import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/image_export_config.dart';

class CanvasRasterizerDataSource {
  Future<String> exportBoundaryToImage({
    required RenderRepaintBoundary boundary,
    required ImageExportConfig config,
    required double pixelRatio,
  }) async {
    try {
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio * config.scaleFactor);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw const CanvasRenderException('Failed to extract byte data from canvas image');
      }

      final Uint8List uint8list = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = p.join(tempDir.path, 'annotated_image_$timestamp.png');

      final file = File(filePath);
      await file.writeAsBytes(uint8list);

      return filePath;
    } catch (e) {
      throw CanvasRenderException(e.toString());
    }
  }

  Future<String> saveTemporaryBytes(Uint8List bytes, String extension) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(tempDir.path, 'image_export_$timestamp.$extension');
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }
}
