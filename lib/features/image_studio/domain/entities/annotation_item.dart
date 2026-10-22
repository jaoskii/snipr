import 'package:flutter/material.dart';

enum AnnotationType {
  arrow,
  rectangle,
  spotlight,
  redactBlur,
  memeText,
  subtitleText,
  freehandPen,
}

class AnnotationItem {
  final String id;
  final AnnotationType type;
  final Offset startPoint;
  final Offset endPoint;
  final List<Offset> points; // For freehand pen
  final Color color;
  final double strokeWidth;
  final String? text;
  final double fontSize;
  final bool isFilled;

  const AnnotationItem({
    required this.id,
    required this.type,
    required this.startPoint,
    required this.endPoint,
    this.points = const [],
    this.color = Colors.redAccent,
    this.strokeWidth = 4.0,
    this.text,
    this.fontSize = 28.0,
    this.isFilled = false,
  });

  Rect get boundingBox => Rect.fromPoints(startPoint, endPoint);

  AnnotationItem copyWith({
    String? id,
    AnnotationType? type,
    Offset? startPoint,
    Offset? endPoint,
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    String? text,
    double? fontSize,
    bool? isFilled,
  }) {
    return AnnotationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      isFilled: isFilled ?? this.isFilled,
    );
  }
}
