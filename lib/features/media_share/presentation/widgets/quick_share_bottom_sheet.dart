import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../data/datasources/native_share_datasource.dart';
import '../../data/repositories/media_share_repository_impl.dart';
import '../../domain/usecases/save_to_gallery.dart';
import '../../domain/usecases/share_media_to_platform.dart';

final shareDataSourceProvider = Provider<NativeShareDataSource>((ref) {
  return NativeShareDataSource();
});

final shareRepositoryProvider = Provider<MediaShareRepositoryImpl>((ref) {
  return MediaShareRepositoryImpl(ref.watch(shareDataSourceProvider));
});

final shareMediaUseCaseProvider = Provider<ShareMediaToPlatform>((ref) {
  return ShareMediaToPlatform(ref.watch(shareRepositoryProvider));
});

final saveToGalleryUseCaseProvider = Provider<SaveToGallery>((ref) {
  return SaveToGallery(ref.watch(shareRepositoryProvider));
});

class QuickShareBottomSheet extends ConsumerStatefulWidget {
  final String filePath;
  final bool isVideo;

  const QuickShareBottomSheet({
    super.key,
    required this.filePath,
    required this.isVideo,
  });

  static Future<void> show(BuildContext context, {required String filePath, required bool isVideo}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuickShareBottomSheet(filePath: filePath, isVideo: isVideo),
    );
  }

  @override
  ConsumerState<QuickShareBottomSheet> createState() => _QuickShareBottomSheetState();
}

class _QuickShareBottomSheetState extends ConsumerState<QuickShareBottomSheet> {
  int _fileSizeBytes = 0;
  bool _isSavedToGallery = false;

  @override
  void initState() {
    super.initState();
    _loadFileStats();
  }

  Future<void> _loadFileStats() async {
    final file = File(widget.filePath);
    if (await file.exists()) {
      final size = await file.length();
      if (mounted) {
        setState(() {
          _fileSizeBytes = size;
        });
      }
    }
  }

  Future<void> _handleShare() async {
    final shareUseCase = ref.read(shareMediaUseCaseProvider);
    await shareUseCase(ShareMediaParams(
      filePath: widget.filePath,
      mimeType: widget.isVideo ? 'video/mp4' : 'image/png',
    ));
  }

  Future<void> _handleSaveToGallery() async {
    try {
      final saveUseCase = ref.read(saveToGalleryUseCaseProvider);
      final success = await saveUseCase(SaveToGalleryParams(
        filePath: widget.filePath,
        isVideo: widget.isVideo,
      ));

      if (mounted) {
        if (success) {
          setState(() {
            _isSavedToGallery = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved to Gallery!'),
              backgroundColor: AppColors.neonGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not save to gallery. Please check storage permissions.'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save error: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle pill
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.discordIndigo.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.isVideo ? Icons.movie_filter_rounded : Icons.image_rounded,
                    color: AppColors.neonCyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Media Ready for Sharing',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Final Size: ${FileSizeFormatter.format(_fileSizeBytes)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.neonGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Output Directory Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded, size: 20, color: AppColors.neonCyan),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OUTPUT LOCATION',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.filePath,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Actions
            ElevatedButton.icon(
              onPressed: _handleShare,
              icon: const Icon(Icons.send_rounded, size: 20),
              label: const Text('Share to Apps / Messenger'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.discordIndigo,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isSavedToGallery ? null : _handleSaveToGallery,
              icon: Icon(
                _isSavedToGallery ? Icons.check_circle_rounded : Icons.download_rounded,
                size: 20,
                color: _isSavedToGallery ? AppColors.neonGreen : AppColors.textPrimary,
              ),
              label: Text(_isSavedToGallery ? 'Saved to Photos' : 'Save to Gallery'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
