import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

enum HistoryMediaType { video, image }

class HistoryItem {
  final int? id;
  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final Color tint;
  final String actionLabel;
  final HistoryMediaType mediaType;
  final String directoryPath;
  final String? filePath;
  final String? previewAsset;
  final String? previewVideoUrl;
  final String durationLabel;
  final String resolution;
  final String createdLabel;
  final String fileSize;

  const HistoryItem({
    this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.tint,
    this.actionLabel = 'Open',
    this.mediaType = HistoryMediaType.video,
    this.directoryPath = '',
    this.filePath,
    this.previewAsset,
    this.previewVideoUrl,
    this.durationLabel = '',
    this.resolution = '',
    this.createdLabel = '',
    this.fileSize = '',
  });

  bool get isVideo => mediaType == HistoryMediaType.video;
}

class RecentHistoryList extends StatelessWidget {
  final String title;
  final List<HistoryItem> items;
  final ValueChanged<HistoryItem>? onAction;

  const RecentHistoryList({
    super.key,
    required this.title,
    required this.items,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.display(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 14),
            child: _HistoryCard(
              item: item,
              onAction: onAction == null ? null : () => onAction!(item),
            ),
          );
        }),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback? onAction;

  const _HistoryCard({required this.item, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: item.tint.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: item.tint.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 78,
                        height: 78,
                        child: item.previewAsset != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(item.previewAsset!, fit: BoxFit.cover),
                                  if (item.isVideo)
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      child: const Icon(
                                        Icons.play_circle_fill_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                ],
                              )
                            : ColoredBox(
                                color: AppColors.background.withValues(alpha: 0.45),
                                child: Icon(item.icon, size: 34, color: AppColors.coralSun),
                              ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      left: -4,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                          size: 14,
                          color: AppColors.hotPink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.meta,
                              style: AppTheme.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neonTeal,
                              ),
                            ),
                          ),
                          Material(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: onAction,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                child: Text(
                                  item.actionLabel,
                                  style: AppTheme.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
