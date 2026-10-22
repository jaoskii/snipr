import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../../domain/entities/image_export_config.dart';
import '../../domain/repositories/i_image_processor_repository.dart';
import '../datasources/canvas_rasterizer_datasource.dart';

class ImageProcessorRepositoryImpl implements IImageProcessorRepository {
  final CanvasRasterizerDataSource _dataSource;

  ImageProcessorRepositoryImpl(this._dataSource);

  @override
  Future<String> exportAnnotatedImage({
    required RenderRepaintBoundary boundary,
    required ImageExportConfig config,
    required double pixelRatio,
  }) {
    return _dataSource.exportBoundaryToImage(
      boundary: boundary,
      config: config,
      pixelRatio: pixelRatio,
    );
  }

  @override
  Future<String> saveTemporaryImageBytes(Uint8List bytes, String extension) {
    return _dataSource.saveTemporaryBytes(bytes, extension);
  }
}
