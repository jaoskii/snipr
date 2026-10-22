import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../domain/entities/video_clip.dart';

class TimelineRangeScrubber extends StatefulWidget {
  final VideoClip clip;
  final Duration currentPosition;
  final void Function(Duration start, Duration end) onRangeChanged;
  final ValueChanged<Duration>? onSeek;

  const TimelineRangeScrubber({
    super.key,
    required this.clip,
    required this.currentPosition,
    required this.onRangeChanged,
    this.onSeek,
  });

  @override
  State<TimelineRangeScrubber> createState() => _TimelineRangeScrubberState();
}

class _TimelineRangeScrubberState extends State<TimelineRangeScrubber> {
  final List<String> _thumbnailPaths = [];
  bool _isLoadingThumbnails = false;
  static const int _thumbnailCount = 8;

  @override
  void initState() {
    super.initState();
    _extractTimelineThumbnails();
  }

  @override
  void didUpdateWidget(covariant TimelineRangeScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clip.sourcePath != widget.clip.sourcePath) {
      _extractTimelineThumbnails();
    }
  }

  Future<void> _extractTimelineThumbnails() async {
    final totalDuration = widget.clip.totalDuration;
    if (totalDuration.inMilliseconds <= 0) return;

    if (mounted) {
      setState(() {
        _isLoadingThumbnails = true;
        _thumbnailPaths.clear();
      });
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final stepMs = totalDuration.inMilliseconds / _thumbnailCount;
      final List<String> paths = [];

      for (int i = 0; i < _thumbnailCount; i++) {
        final sec = ((i * stepMs) + (stepMs / 2)) / 1000.0;
        final outImg = p.join(tempDir.path, 'thumb_${timestamp}_$i.jpg');
        final cmd = '-y -ss $sec -i "${widget.clip.sourcePath}" -vframes 1 -vf "scale=160:-1" "$outImg"';
        final session = await FFmpegKit.execute(cmd);
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode) && await File(outImg).exists()) {
          paths.add(outImg);
        }
      }

      if (mounted) {
        setState(() {
          _thumbnailPaths.addAll(paths);
          _isLoadingThumbnails = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingThumbnails = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalMs = widget.clip.totalDuration.inMilliseconds.toDouble();
    if (totalMs <= 0) return const SizedBox.shrink();

    final double startMs = widget.clip.trimStart.inMilliseconds.toDouble().clamp(0.0, totalMs);
    final double endMs = widget.clip.trimEnd.inMilliseconds.toDouble().clamp(startMs, totalMs);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.movie_creation_rounded, size: 16, color: AppColors.neonCyan),
                  SizedBox(width: 8),
                  Text(
                    'VIDEO TIMELINE & HIGHLIGHT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.discordIndigo.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  TimeFormatter.format(widget.clip.selectedDuration),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filmstrip Timeline Track with Drag Handles
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final startRatio = totalMs > 0 ? (startMs / totalMs) : 0.0;
              final endRatio = totalMs > 0 ? (endMs / totalMs) : 1.0;

              final startPos = (startRatio * trackWidth).clamp(0.0, trackWidth);
              final endPos = (endRatio * trackWidth).clamp(startPos, trackWidth);
              final selectionWidth = (endPos - startPos).clamp(24.0, trackWidth);

              return Column(
                children: [
                  Container(
                    height: 58,
                    width: trackWidth,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Thumbnails filmstrip background
                        if (_thumbnailPaths.isNotEmpty)
                          Positioned.fill(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _thumbnailPaths.map((path) {
                                return Expanded(
                                  child: Image.file(
                                    File(path),
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        else
                          Positioned.fill(
                            child: Container(
                              color: AppColors.surfaceElevated.withValues(alpha: 0.5),
                              child: Center(
                                child: _isLoadingThumbnails
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonCyan),
                                      )
                                    : const Icon(Icons.movie_outlined, size: 22, color: AppColors.textMuted),
                              ),
                            ),
                          ),

                        // Dimmed out areas (Left of selection)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: startPos,
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ),

                        // Dimmed out areas (Right of selection)
                        Positioned(
                          left: endPos,
                          top: 0,
                          bottom: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ),

                        // Highlight Selection Box with Neon Glow Border
                        Positioned(
                          left: startPos,
                          top: 0,
                          bottom: 0,
                          width: selectionWidth,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                  color: AppColors.neonCyan,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Left Trim Handle (Drag Anchor)
                        Positioned(
                          left: (startPos - 12).clamp(0.0, trackWidth - 24),
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) {
                              final newStartPos = (startPos + details.delta.dx).clamp(0.0, endPos - 20);
                              final newStartRatio = newStartPos / trackWidth;
                              final newStartMs = newStartRatio * totalMs;
                              final newDuration = Duration(milliseconds: newStartMs.toInt());
                              widget.onRangeChanged(newDuration, widget.clip.trimEnd);
                              widget.onSeek?.call(newDuration);
                            },
                            child: Container(
                              width: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.coralSun, AppColors.hotPink],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonCyan.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.chevron_left_rounded, size: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ),

                        // Right Trim Handle (Drag Anchor)
                        Positioned(
                          left: (endPos - 12).clamp(startPos, trackWidth - 24),
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) {
                              final newEndPos = (endPos + details.delta.dx).clamp(startPos + 20, trackWidth);
                              final newEndRatio = newEndPos / trackWidth;
                              final newEndMs = newEndRatio * totalMs;
                              final newDuration = Duration(milliseconds: newEndMs.toInt());
                              widget.onRangeChanged(widget.clip.trimStart, newDuration);
                              widget.onSeek?.call(newDuration);
                            },
                            child: Container(
                              width: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.coralSun, AppColors.hotPink],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonCyan.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.chevron_right_rounded, size: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Range Slider Scrub Fine-Tuning
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.neonCyan,
                      inactiveTrackColor: AppColors.surfaceElevated.withValues(alpha: 0.6),
                      thumbColor: Colors.white,
                      overlayColor: AppColors.neonCyan.withValues(alpha: 0.2),
                      trackHeight: 4,
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 6,
                        elevation: 3,
                      ),
                    ),
                    child: RangeSlider(
                      values: RangeValues(startMs, endMs),
                      min: 0.0,
                      max: totalMs,
                      onChanged: (RangeValues values) {
                        final newStart = Duration(milliseconds: values.start.toInt());
                        final newEnd = Duration(milliseconds: values.end.toInt());
                        widget.onRangeChanged(newStart, newEnd);
                        if (values.start != startMs) {
                          widget.onSeek?.call(newStart);
                        } else if (values.end != endMs) {
                          widget.onSeek?.call(newEnd);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 14, color: AppColors.neonCyan),
                    const SizedBox(width: 4),
                    Text(
                      'Start: ${TimeFormatter.format(widget.clip.trimStart)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'End: ${TimeFormatter.format(widget.clip.trimEnd)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.stop_rounded, size: 14, color: AppColors.neonPurple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
