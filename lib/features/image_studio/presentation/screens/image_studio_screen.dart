import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../media_share/presentation/widgets/quick_share_bottom_sheet.dart';
import '../../domain/entities/annotation_item.dart';
import '../controllers/image_studio_controller.dart';
import '../widgets/annotation_painter.dart';
import '../widgets/meme_text_dialog.dart';
import '../widgets/tool_selector_toolbar.dart';

class ImageStudioScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const ImageStudioScreen({
    super.key,
    required this.imagePath,
  });

  @override
  ConsumerState<ImageStudioScreen> createState() => _ImageStudioScreenState();
}

class _ImageStudioScreenState extends ConsumerState<ImageStudioScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  Offset? _dragStart;
  Offset? _dragCurrent;
  List<Offset> _freehandPoints = [];
  ui.Image? _watermarkLogo;

  @override
  void initState() {
    super.initState();
    _loadWatermarkLogo();
  }

  Future<void> _loadWatermarkLogo() async {
    final data = await rootBundle.load('assets/brand/snipr-logo-on-dark.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() => _watermarkLogo = frame.image);
  }

  @override
  void dispose() {
    _watermarkLogo?.dispose();
    super.dispose();
  }

  void _onPanStart(DragDownDetails details) {
    setState(() {
      _dragStart = details.localPosition;
      _dragCurrent = details.localPosition;
      _freehandPoints = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragCurrent = details.localPosition;
      _freehandPoints.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragStart == null || _dragCurrent == null) return;

    final state = ref.read(imageStudioControllerProvider(widget.imagePath));
    final controller = ref.read(imageStudioControllerProvider(widget.imagePath).notifier);

    final item = AnnotationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: state.selectedTool,
      startPoint: _dragStart!,
      endPoint: _dragCurrent!,
      points: List.from(_freehandPoints),
      color: state.selectedColor,
      strokeWidth: state.strokeWidth,
    );

    controller.addAnnotation(item);

    setState(() {
      _dragStart = null;
      _dragCurrent = null;
      _freehandPoints = [];
    });
  }

  void _showMemeDialog() {
    showDialog(
      context: context,
      builder: (_) => MemeTextDialog(
        onSubmitted: (text, isMemeStyle) {
          final state = ref.read(imageStudioControllerProvider(widget.imagePath));
          final controller = ref.read(imageStudioControllerProvider(widget.imagePath).notifier);

          final item = AnnotationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: isMemeStyle ? AnnotationType.memeText : AnnotationType.subtitleText,
            startPoint: const Offset(50, 40),
            endPoint: const Offset(300, 100),
            text: text,
            color: state.selectedColor,
            fontSize: isMemeStyle ? 32 : 18,
          );
          controller.addAnnotation(item);
        },
      ),
    );
  }

  Future<void> _exportAndShare() async {
    final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final controller = ref.read(imageStudioControllerProvider(widget.imagePath).notifier);
    final outputPath = await controller.exportImage(boundary: boundary);

    if (outputPath != null && mounted) {
      QuickShareBottomSheet.show(context, filePath: outputPath, isVideo: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageStudioControllerProvider(widget.imagePath));
    final controller = ref.read(imageStudioControllerProvider(widget.imagePath).notifier);

    AnnotationItem? currentDrawing;
    if (_dragStart != null && _dragCurrent != null) {
      currentDrawing = AnnotationItem(
        id: 'active_drawing',
        type: state.selectedTool,
        startPoint: _dragStart!,
        endPoint: _dragCurrent!,
        points: _freehandPoints,
        color: state.selectedColor,
        strokeWidth: state.strokeWidth,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Annotate & Crop'),
        actions: [
          TextButton.icon(
            onPressed: state.isExporting ? null : _exportAndShare,
            icon: state.isExporting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.share_rounded, size: 18, color: AppColors.neonCyan),
            label: const Text('Share', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas Area
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      // Background Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Annotation Drawing Layer
                      Positioned.fill(
                        child: GestureDetector(
                          onPanDown: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: CustomPaint(
                            painter: AnnotationPainter(
                              annotations: state.annotations,
                              currentDrawing: currentDrawing,
                              watermarkLogo: _watermarkLogo,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Toolbar
          ToolSelectorToolbar(
            selectedTool: state.selectedTool,
            selectedColor: state.selectedColor,
            canUndo: state.canUndo,
            canRedo: state.canRedo,
            onSelectTool: controller.selectTool,
            onSelectColor: controller.selectColor,
            onUndo: controller.undo,
            onRedo: controller.redo,
            onAddMemeText: _showMemeDialog,
          ),
        ],
      ),
    );
  }
}
