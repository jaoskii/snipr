import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../domain/entities/annotation_item.dart';

/// Draws annotations + snipR logo watermark.
/// Callers: ImageStudioScreen CustomPaint.
/// User: "change the watermark also to the snipR logo but have the opacity to 40%"
class AnnotationPainter extends CustomPainter {
  final List<AnnotationItem> annotations;
  final AnnotationItem? currentDrawing;
  final ui.Image? watermarkLogo;

  AnnotationPainter({
    required this.annotations,
    this.currentDrawing,
    this.watermarkLogo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final allItems = [...annotations];
    if (currentDrawing != null) {
      allItems.add(currentDrawing!);
    }

    for (final item in allItems) {
      _drawAnnotation(canvas, size, item);
    }

    _drawWatermark(canvas, size);
  }

  void _drawWatermark(Canvas canvas, Size size) {
    final logo = watermarkLogo;
    if (logo == null) return;

    final targetH = (size.height * 0.07).clamp(18.0, 40.0);
    final scale = targetH / logo.height;
    final targetW = logo.width * scale;
    final insetX = size.width * 0.03;
    final insetY = size.height * 0.03;
    final dst = Rect.fromLTWH(
      size.width - targetW - insetX,
      size.height - targetH - insetY,
      targetW,
      targetH,
    );

    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = const Color(0x66FFFFFF), // 40% opacity
    );
    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  void _drawAnnotation(Canvas canvas, Size size, AnnotationItem item) {
    final paint = Paint()
      ..color = item.color
      ..strokeWidth = item.strokeWidth
      ..style = item.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (item.type) {
      case AnnotationType.arrow:
        _drawArrow(canvas, item.startPoint, item.endPoint, paint);
        break;

      case AnnotationType.rectangle:
        canvas.drawRect(Rect.fromPoints(item.startPoint, item.endPoint), paint);
        break;

      case AnnotationType.spotlight:
        _drawSpotlight(canvas, size, item.boundingBox);
        break;

      case AnnotationType.redactBlur:
        _drawRedactionBox(canvas, item.boundingBox);
        break;

      case AnnotationType.freehandPen:
        if (item.points.length > 1) {
          final path = Path()..moveTo(item.points.first.dx, item.points.first.dy);
          for (int i = 1; i < item.points.length; i++) {
            path.lineTo(item.points[i].dx, item.points[i].dy);
          }
          canvas.drawPath(path, paint);
        }
        break;

      case AnnotationType.memeText:
        _drawMemeText(canvas, item.text ?? '', item.startPoint, size, item.fontSize);
        break;

      case AnnotationType.subtitleText:
        _drawSubtitlePill(canvas, item.text ?? '', item.startPoint, item.fontSize);
        break;
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    // Draw shaft
    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    final double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const double arrowSize = 22.0;
    const double arrowAngle = math.pi / 6;

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * math.cos(angle - arrowAngle),
        end.dy - arrowSize * math.sin(angle - arrowAngle),
      )
      ..lineTo(
        end.dx - arrowSize * math.cos(angle + arrowAngle),
        end.dy - arrowSize * math.sin(angle + arrowAngle),
      )
      ..close();

    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, arrowPaint);
  }

  void _drawSpotlight(Canvas canvas, Size canvasSize, Rect focusRect) {
    // Dim background
    final darkLayer = Paint()..color = Colors.black.withValues(alpha: 0.65);
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
    final circlePath = Path()..addOval(focusRect);
    final dimmedPath = Path.combine(PathOperation.difference, backgroundPath, circlePath);
    canvas.drawPath(dimmedPath, darkLayer);

    // Spotlight glow border
    final borderPaint = Paint()
      ..color = const Color(0xFFFF3D6E)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawOval(focusRect, borderPaint);
  }

  void _drawRedactionBox(Canvas canvas, Rect rect) {
    // Pixelated / Dark Redaction Box
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.95);
    canvas.drawRect(rect, bgPaint);

    final patternPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5;

    // Diagonal stripes pattern indicating redacted content
    for (double x = rect.left; x < rect.right + rect.height; x += 12) {
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x - rect.height, rect.bottom),
        patternPaint,
      );
    }
  }

  void _drawMemeText(Canvas canvas, String text, Offset position, Size size, double fontSize) {
    if (text.isEmpty) return;

    final textSpan = TextSpan(
      text: text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Impact',
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: const [
          Shadow(offset: Offset(-2, -2), color: Colors.black),
          Shadow(offset: Offset(2, -2), color: Colors.black),
          Shadow(offset: Offset(2, 2), color: Colors.black),
          Shadow(offset: Offset(-2, 2), color: Colors.black),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 32);

    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, position.dy),
    );
  }

  void _drawSubtitlePill(Canvas canvas, String text, Offset position, double fontSize) {
    if (text.isEmpty) return;

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 320);

    final rect = Rect.fromLTWH(
      position.dx - 10,
      position.dy - 6,
      textPainter.width + 20,
      textPainter.height + 12,
    );

    final pillPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), pillPaint);
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) => true;
}
