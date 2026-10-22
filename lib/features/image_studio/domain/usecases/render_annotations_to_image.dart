import 'package:flutter/rendering.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/image_export_config.dart';
import '../repositories/i_image_processor_repository.dart';

class RenderAnnotationsParams {
  final RenderRepaintBoundary boundary;
  final ImageExportConfig config;
  final double pixelRatio;

  const RenderAnnotationsParams({
    required this.boundary,
    required this.config,
    this.pixelRatio = 3.0,
  });
}

class RenderAnnotationsToImage
    implements UseCase<Future<String>, RenderAnnotationsParams> {
  final IImageProcessorRepository _repository;

  RenderAnnotationsToImage(this._repository);

  @override
  Future<String> call(RenderAnnotationsParams params) {
    return _repository.exportAnnotatedImage(
      boundary: params.boundary,
      config: params.config,
      pixelRatio: params.pixelRatio,
    );
  }
}
