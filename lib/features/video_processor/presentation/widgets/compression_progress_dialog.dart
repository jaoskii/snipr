import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../domain/entities/processing_progress.dart';

class CompressionProgressDialog extends StatelessWidget {
  final ProcessingProgress progress;
  final VoidCallback onCancel;
  final void Function(String outputPath)? onShare;

  const CompressionProgressDialog({
    super.key,
    required this.progress,
    required this.onCancel,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress.stage == ProcessingStage.completed;
    final isFailed = progress.stage == ProcessingStage.failed;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCompleted && !isFailed) ...[
              const SizedBox(
                height: 56,
                width: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                progress.statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.percentage,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.discordIndigo),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress.percentage * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel Encoding', style: TextStyle(color: AppColors.dangerRed)),
              ),
            ] else if (isCompleted) ...[
              const Icon(Icons.check_circle_rounded, size: 60, color: AppColors.neonGreen),
              const SizedBox(height: 16),
              const Text(
                'Ready to Share!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (progress.outputSizeBytes != null)
                Text(
                  'Final Size: ${FileSizeFormatter.format(progress.outputSizeBytes!)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neonCyan,
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (progress.outputPath != null && onShare != null) {
                          onShare!(progress.outputPath!);
                        }
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.discordIndigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.dangerRed),
              const SizedBox(height: 16),
              const Text(
                'Encoding Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.dangerRed),
              ),
              const SizedBox(height: 8),
              Text(
                progress.statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
