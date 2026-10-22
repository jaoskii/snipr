import 'dart:ui';
import '../../domain/entities/annotation_item.dart';
import '../../domain/entities/image_export_config.dart';

class ImageStudioState {
  final String imagePath;
  final List<AnnotationItem> annotations;
  final List<AnnotationItem> redoStack;
  final AnnotationType selectedTool;
  final Color selectedColor;
  final double strokeWidth;
  final ImageExportConfig exportConfig;
  final bool isExporting;
  final String? exportedFilePath;

  const ImageStudioState({
    required this.imagePath,
    this.annotations = const [],
    this.redoStack = const [],
    this.selectedTool = AnnotationType.arrow,
    this.selectedColor = const Color(0xFF00E5FF),
    this.strokeWidth = 4.0,
    this.exportConfig = const ImageExportConfig(),
    this.isExporting = false,
    this.exportedFilePath,
  });

  bool get canUndo => annotations.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  ImageStudioState copyWith({
    String? imagePath,
    List<AnnotationItem>? annotations,
    List<AnnotationItem>? redoStack,
    AnnotationType? selectedTool,
    Color? selectedColor,
    double? strokeWidth,
    ImageExportConfig? exportConfig,
    bool? isExporting,
    String? exportedFilePath,
  }) {
    return ImageStudioState(
      imagePath: imagePath ?? this.imagePath,
      annotations: annotations ?? this.annotations,
      redoStack: redoStack ?? this.redoStack,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      exportConfig: exportConfig ?? this.exportConfig,
      isExporting: isExporting ?? this.isExporting,
      exportedFilePath: exportedFilePath ?? this.exportedFilePath,
    );
  }
}
