import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../media_share/presentation/widgets/quick_share_bottom_sheet.dart';
import '../controllers/video_studio_controller.dart';
import '../widgets/compression_progress_dialog.dart';
import '../widgets/platform_preset_chips.dart';
import '../widgets/timeline_range_scrubber.dart';

class VideoStudioScreen extends ConsumerStatefulWidget {
  final String videoPath;

  const VideoStudioScreen({
    super.key,
    required this.videoPath,
  });

  @override
  ConsumerState<VideoStudioScreen> createState() => _VideoStudioScreenState();
}

class _VideoStudioScreenState extends ConsumerState<VideoStudioScreen> {
  VideoPlayerController? _videoPlayerController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final controller = VideoPlayerController.file(File(widget.videoPath));
    await controller.initialize();
    
    if (mounted) {
      setState(() {
        _videoPlayerController = controller;
      });
      
      ref.read(videoStudioControllerProvider.notifier).loadVideoFile(
        widget.videoPath,
        duration: controller.value.duration,
        width: controller.value.size.width.toInt(),
        height: controller.value.size.height.toInt(),
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(videoStudioControllerProvider);
          return CompressionProgressDialog(
            progress: state.progress,
            onCancel: () {
              ref.read(videoStudioControllerProvider.notifier).cancelCurrentJob();
              Navigator.of(ctx).pop();
            },
            onShare: (outputPath) {
              Navigator.of(ctx).pop();
              QuickShareBottomSheet.show(context, filePath: outputPath, isVideo: true);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoStudioControllerProvider);
    final clip = state.clip;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Highlight & Compress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: (clip == null || _videoPlayerController == null)
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonCyan))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Video Player Preview
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio > 0
                          ? _videoPlayerController!.value.aspectRatio
                          : 16 / 9,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_videoPlayerController!),
                          IconButton(
                            iconSize: 54,
                            icon: Icon(
                              _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_isPlaying) {
                                  _videoPlayerController!.pause();
                                  _isPlaying = false;
                                } else {
                                  _videoPlayerController!.play();
                                  _isPlaying = true;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // File Info Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Original: ${FileSizeFormatter.format(clip.originalSizeBytes)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(
                          '${clip.width}x${clip.height} • ${clip.fps.toInt()} FPS',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Timeline Scrubber with Live Drag Frame Preview
                  TimelineRangeScrubber(
                    clip: clip,
                    currentPosition: state.currentPosition,
                    onRangeChanged: (start, end) {
                      ref.read(videoStudioControllerProvider.notifier).updateTrimRange(start, end);
                    },
                    onSeek: (position) {
                      _videoPlayerController?.seekTo(position);
                    },
                  ),

                  // Preset Chips
                  PlatformPresetChips(
                    selectedPreset: state.config.preset,
                    onPresetSelected: (preset) {
                      ref.read(videoStudioControllerProvider.notifier).selectPreset(preset);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Resolution & FPS Settings (Glassmorphism)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 16, color: AppColors.neonCyan),
                            SizedBox(width: 8),
                            Text(
                              'ENCODING OPTIONS',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: state.config.targetResolution,
                                dropdownColor: AppColors.background,
                                decoration: InputDecoration(
                                  labelText: 'Resolution',
                                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  filled: true,
                                  fillColor: AppColors.surfaceElevated.withValues(alpha: 0.6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: const [
                                  DropdownMenuItem(value: '1920x1080', child: Text('1080p (FHD)')),
                                  DropdownMenuItem(value: '1280x720', child: Text('720p (HD)')),
                                  DropdownMenuItem(value: '854x480', child: Text('480p (SD)')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(videoStudioControllerProvider.notifier).updateResolution(val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: state.config.targetFps,
                                dropdownColor: AppColors.background,
                                decoration: InputDecoration(
                                  labelText: 'Framerate',
                                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  filled: true,
                                  fillColor: AppColors.surfaceElevated.withValues(alpha: 0.6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 60, child: Text('60 FPS')),
                                  DropdownMenuItem(value: 30, child: Text('30 FPS')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(videoStudioControllerProvider.notifier).updateFps(val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Mute Audio Track', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          value: state.config.muteAudio,
                          activeThumbColor: AppColors.neonCyan,
                          onChanged: (val) {
                            ref.read(videoStudioControllerProvider.notifier).toggleMute(val);
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Snipr Watermark', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Adds watermark tag at bottom', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          value: state.config.includeWatermark,
                          activeThumbColor: AppColors.neonCyan,
                          onChanged: (val) {
                            ref.read(videoStudioControllerProvider.notifier).toggleWatermark(val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _showProgressDialog();
                            ref.read(videoStudioControllerProvider.notifier).startCompression();
                          },
                          icon: const Icon(Icons.compress_rounded, size: 20),
                          label: Text('Compress for ${state.config.preset.title}'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: AppColors.discordIndigo,
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            _showProgressDialog();
                            ref.read(videoStudioControllerProvider.notifier).startLosslessTrim();
                          },
                          icon: const Icon(Icons.cut_rounded, size: 18),
                          label: const Text('Instant Lossless Cut (No Re-encode)'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            side: const BorderSide(color: AppColors.surfaceBorder),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
