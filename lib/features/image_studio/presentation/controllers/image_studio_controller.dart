import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/canvas_rasterizer_datasource.dart';
import '../../data/repositories/image_processor_repository_impl.dart';
import '../../domain/entities/annotation_item.dart';
import '../../domain/usecases/render_annotations_to_image.dart';
import 'image_studio_state.dart';

final canvasDataSourceProvider = Provider<CanvasRasterizerDataSource>((ref) {
  return CanvasRasterizerDataSource();
});

final imageRepositoryProvider = Provider<ImageProcessorRepositoryImpl>((ref) {
  return ImageProcessorRepositoryImpl(ref.watch(canvasDataSourceProvider));
});

final renderAnnotationsUseCaseProvider = Provider<RenderAnnotationsToImage>((ref) {
  return RenderAnnotationsToImage(ref.watch(imageRepositoryProvider));
});

final imageStudioControllerProvider =
    StateNotifierProvider.autoDispose.family<ImageStudioController, ImageStudioState, String>(
        (ref, imagePath) {
  return ImageStudioController(
    imagePath: imagePath,
    renderAnnotationsUseCase: ref.watch(renderAnnotationsUseCaseProvider),
  );
});

class ImageStudioController extends StateNotifier<ImageStudioState> {
  final RenderAnnotationsToImage _renderAnnotationsUseCase;

  ImageStudioController({
    required String imagePath,
    required RenderAnnotationsToImage renderAnnotationsUseCase,
  })  : _renderAnnotationsUseCase = renderAnnotationsUseCase,
        super(ImageStudioState(imagePath: imagePath));

  void selectTool(AnnotationType tool) {
    state = state.copyWith(selectedTool: tool);
  }

  void selectColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  void addAnnotation(AnnotationItem item) {
    state = state.copyWith(
      annotations: [...state.annotations, item],
      redoStack: [], // Reset redo history on new action
    );
  }

  void undo() {
    if (!state.canUndo) return;
    final lastItem = state.annotations.last;
    state = state.copyWith(
      annotations: state.annotations.sublist(0, state.annotations.length - 1),
      redoStack: [...state.redoStack, lastItem],
    );
  }

  void redo() {
    if (!state.canRedo) return;
    final itemToRestore = state.redoStack.last;
    state = state.copyWith(
      annotations: [...state.annotations, itemToRestore],
      redoStack: state.redoStack.sublist(0, state.redoStack.length - 1),
    );
  }

  void clearAll() {
    state = state.copyWith(annotations: [], redoStack: []);
  }

  Future<String?> exportImage({
    required RenderRepaintBoundary boundary,
    double pixelRatio = 3.0,
  }) async {
    state = state.copyWith(isExporting: true);

    try {
      final path = await _renderAnnotationsUseCase(RenderAnnotationsParams(
        boundary: boundary,
        config: state.exportConfig,
        pixelRatio: pixelRatio,
      ));

      state = state.copyWith(
        isExporting: false,
        exportedFilePath: path,
      );
      return path;
    } catch (e) {
      state = state.copyWith(isExporting: false);
      return null;
    }
  }
}
