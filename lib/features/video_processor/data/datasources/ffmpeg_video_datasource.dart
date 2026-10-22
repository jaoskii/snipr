import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/bitrate_calculator.dart';
import '../../domain/entities/compression_config.dart';
import '../../domain/entities/processing_progress.dart';
import '../../domain/entities/video_clip.dart';

class FFmpegVideoDataSource {
  int? _activeSessionId;

  Future<String> _getOrCreateWatermarkPng(Directory tempDir) async {
    // snipR logo watermark @ 40% opacity. Callers: compressVideo.
    // User: "change the watermark also to the snipR logo but have the opacity to 40%"
    final watermarkFile = File(p.join(tempDir.path, 'snipr_watermark_v4.png'));
    if (await watermarkFile.exists()) {
      return watermarkFile.path;
    }

    final data = await rootBundle.load('assets/brand/snipr-logo-on-dark.png');
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: 72,
    );
    final frame = await codec.getNextFrame();
    final src = frame.image;
    final w = src.width.toDouble();
    final h = src.height.toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0x66FFFFFF), // 40% opacity
    );
    canvas.drawImage(src, Offset.zero, Paint());
    canvas.restore();
    src.dispose();

    final picture = recorder.endRecording();
    final image = await picture.toImage(w.toInt(), h.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final bytes = byteData!.buffer.asUint8List();

    await watermarkFile.writeAsBytes(bytes);
    return watermarkFile.path;
  }

  /// Executes two-pass encoding to fit the clip into the exact target size.
  Stream<ProcessingProgress> compressVideo({
    required VideoClip clip,
    required CompressionConfig config,
  }) async* {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = p.join(tempDir.path, 'clipforge_compressed_$timestamp.mp4');
    final passlogPrefix = p.join(tempDir.path, 'ffmpeg2pass_$timestamp');

    final selectedDuration = clip.selectedDuration;
    final bitrateCalc = BitrateCalculator.calculate(
      duration: selectedDuration,
      targetSizeBytes: config.targetSizeBytes,
      includeAudio: !config.muteAudio,
    );

    final startSec = clip.trimStart.inMilliseconds / 1000.0;
    final durationSec = selectedDuration.inMilliseconds / 1000.0;

    // Build scale filter ensuring width and height are divisible by 2 for libx264
    String scaleFilter = '';
    if (config.targetResolution.contains('x')) {
      final parts = config.targetResolution.split('x');
      final targetW = parts[0];
      final targetH = parts[1];
      scaleFilter = 'scale=$targetW:$targetH:force_original_aspect_ratio=decrease,scale=trunc(iw/2)*2:trunc(ih/2)*2,fps=${config.targetFps}';
    } else {
      scaleFilter = 'scale=trunc(iw/2)*2:trunc(ih/2)*2,fps=${config.targetFps}';
    }

    String? watermarkPath;
    if (config.includeWatermark) {
      try {
        watermarkPath = await _getOrCreateWatermarkPng(tempDir);
      } catch (_) {
        watermarkPath = null;
      }
    }

    String filterArg = '';
    if (config.includeWatermark && watermarkPath != null) {
      filterArg = '-filter_complex "[0:v]$scaleFilter[base];[base][1:v]overlay=main_w-overlay_w-20:main_h-overlay_h-20"';
    } else {
      filterArg = '-vf "$scaleFilter"';
    }

    final totalDurationMs = selectedDuration.inMilliseconds;

    yield ProcessingProgress.running(
      stage: ProcessingStage.analyzing,
      percentage: 0.05,
      message: 'Analyzing video for ${config.preset.title}...',
    );

    // Stream controller to broadcast progress from FFmpegKit callbacks
    final controller = StreamController<ProcessingProgress>();

    // ----------------- PASS 1 -----------------
    final pass1Cmd = StringBuffer()
      ..write('-y ')
      ..write('-ss $startSec ')
      ..write('-t $durationSec ')
      ..write('-i "${clip.sourcePath}" ');

    if (config.includeWatermark && watermarkPath != null) {
      pass1Cmd.write('-i "$watermarkPath" ');
    }

    pass1Cmd
      ..write('$filterArg ')
      ..write('-c:v libx264 ')
      ..write('-preset medium ')
      ..write('-b:v ${bitrateCalc.videoBitrateKbps}k ')
      ..write('-pass 1 ')
      ..write('-passlogfile "$passlogPrefix" ')
      ..write('-pix_fmt yuv420p ')
      ..write('-an ')
      ..write('-f null -');

    final pass1Completer = Completer<ReturnCode?>();

    final pass1Session = await FFmpegKit.executeAsync(
      pass1Cmd.toString(),
      (session) async {
        final returnCode = await session.getReturnCode();
        pass1Completer.complete(returnCode);
      },
      null,
      (Statistics stats) {
        final timeMs = stats.getTime();
        if (totalDurationMs > 0 && timeMs > 0) {
          final progress = (timeMs / totalDurationMs).clamp(0.0, 1.0);
          // Pass 1 represents 0% to 45% of total work
          final overallProgress = 0.05 + (progress * 0.40);
          controller.add(ProcessingProgress.running(
            stage: ProcessingStage.pass1Encoding,
            percentage: overallProgress,
            message: 'Encoding Pass 1/2: ${(progress * 100).toInt()}%',
          ));
        }
      },
    );

    _activeSessionId = pass1Session.getSessionId();
    final pass1ReturnCode = await pass1Completer.future;

    if (!ReturnCode.isSuccess(pass1ReturnCode)) {
      if (ReturnCode.isCancel(pass1ReturnCode)) {
        controller.add(ProcessingProgress.error('Compression cancelled'));
      } else {
        final logs = await pass1Session.getAllLogsAsString();
        controller.add(ProcessingProgress.error('Pass 1 encoding failed: $logs'));
      }
      controller.close();
      yield* controller.stream;
      return;
    }

    // ----------------- PASS 2 -----------------
    final pass2Cmd = StringBuffer()
      ..write('-y ')
      ..write('-ss $startSec ')
      ..write('-t $durationSec ')
      ..write('-i "${clip.sourcePath}" ');

    if (config.includeWatermark && watermarkPath != null) {
      pass2Cmd.write('-i "$watermarkPath" ');
    }

    pass2Cmd
      ..write('$filterArg ')
      ..write('-c:v libx264 ')
      ..write('-preset medium ')
      ..write('-b:v ${bitrateCalc.videoBitrateKbps}k ')
      ..write('-pass 2 ')
      ..write('-passlogfile "$passlogPrefix" ')
      ..write('-pix_fmt yuv420p ');

    if (config.muteAudio) {
      pass2Cmd.write('-an ');
    } else {
      pass2Cmd.write('-c:a aac -b:a ${bitrateCalc.audioBitrateKbps}k ');
    }

    pass2Cmd.write('-movflags +faststart "$outputPath"');

    final pass2Session = await FFmpegKit.executeAsync(
      pass2Cmd.toString(),
      (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          final file = File(outputPath);
          final sizeBytes = await file.length();
          controller.add(ProcessingProgress.success(
            outputPath: outputPath,
            outputSizeBytes: sizeBytes,
          ));
        } else {
          if (ReturnCode.isCancel(returnCode)) {
            controller.add(ProcessingProgress.error('Compression cancelled'));
          } else {
            final logs = await session.getAllLogsAsString();
            controller.add(ProcessingProgress.error('Pass 2 encoding failed: $logs'));
          }
        }
        controller.close();
      },
      null,
      (Statistics stats) {
        final timeMs = stats.getTime();
        if (totalDurationMs > 0 && timeMs > 0) {
          final progress = (timeMs / totalDurationMs).clamp(0.0, 1.0);
          // Pass 2 represents 45% to 100% of total work
          final overallProgress = 0.45 + (progress * 0.55);
          controller.add(ProcessingProgress.running(
            stage: ProcessingStage.pass2Encoding,
            percentage: overallProgress,
            message: 'Finishing Pass 2/2: ${(progress * 100).toInt()}%',
          ));
        }
      },
    );

    _activeSessionId = pass2Session.getSessionId();

    yield* controller.stream;
  }

  /// Fast stream copy (lossless trimming without re-encoding)
  Stream<ProcessingProgress> fastTrimHighlight({
    required VideoClip clip,
  }) async* {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = p.join(tempDir.path, 'clipforge_highlight_$timestamp.mp4');

    final startSec = clip.trimStart.inMilliseconds / 1000.0;
    final durationSec = clip.selectedDuration.inMilliseconds / 1000.0;

    yield ProcessingProgress.running(
      stage: ProcessingStage.losslessCutting,
      percentage: 0.2,
      message: 'Extracting highlight clip (Lossless)...',
    );

    final cmd = '-y -ss $startSec -t $durationSec -i "${clip.sourcePath}" -c copy -avoid_negative_ts make_zero "$outputPath"';

    final session = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      final file = File(outputPath);
      final sizeBytes = await file.length();
      yield ProcessingProgress.success(
        outputPath: outputPath,
        outputSizeBytes: sizeBytes,
      );
    } else {
      throw const FFmpegException('Fast trim failed');
    }
  }

  Future<void> cancelProcessing() async {
    if (_activeSessionId != null) {
      await FFmpegKit.cancel(_activeSessionId!);
      _activeSessionId = null;
    }
  }
}
