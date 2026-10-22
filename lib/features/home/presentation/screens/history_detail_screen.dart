import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/recent_history_list.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryItem item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            title: Text(
              item.isVideo ? 'Clip detail' : 'Photo detail',
              style: AppTheme.body(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediaPreviewBanner(item: item),
                  const SizedBox(height: 22),
                  Text(
                    item.title,
                    style: AppTheme.display(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subtitle,
                    style: AppTheme.body(
                      fontSize: 15,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _MetaGrid(item: item),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              item.isVideo
                                  ? 'Open in Video Studio coming soon'
                                  : 'Open in Image Studio coming soon',
                            ),
                          ),
                        );
                      },
                      icon: Icon(item.isVideo ? Icons.movie_filter_rounded : Icons.draw_rounded),
                      label: Text(item.isVideo ? 'Edit clip' : 'Edit photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hotPink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share coming soon')),
                        );
                      },
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MediaPreviewBanner extends StatefulWidget {
  final HistoryItem item;

  const MediaPreviewBanner({super.key, required this.item});

  @override
  State<MediaPreviewBanner> createState() => _MediaPreviewBannerState();
}

class _MediaPreviewBannerState extends State<MediaPreviewBanner> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  HistoryItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    if (item.isVideo && item.previewVideoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(item.previewVideoUrl!))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _ready = true);
        }).catchError((_) {
          if (!mounted) return;
          setState(() => _failed = true);
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !_ready) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: item.isVideo ? 16 / 9 : 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.tint.withValues(alpha: 0.55),
                AppColors.midnightPlum,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (item.previewAsset != null && !(item.isVideo && _ready))
                Image.asset(
                  item.previewAsset!,
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.85),
                ),
              if (item.isVideo && _ready && _controller != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              if (!item.isVideo && item.previewAsset == null)
                Center(
                  child: Icon(item.icon, size: 64, color: Colors.white.withValues(alpha: 0.85)),
                ),
              // Top type chip
              Positioned(
                left: 14,
                top: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                        size: 14,
                        color: AppColors.neonTeal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.isVideo ? 'VIDEO' : 'PHOTO',
                        style: AppTheme.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (item.isVideo && item.durationLabel.isNotEmpty)
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.durationLabel,
                      style: AppTheme.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (item.isVideo)
                Center(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _ready && !_failed ? _togglePlay : null,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Icon(
                          _ready && (_controller?.value.isPlaying ?? false)
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              if (item.isVideo && _failed)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Text(
                    'Preview banner · sample file',
                    textAlign: TextAlign.center,
                    style: AppTheme.body(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  final HistoryItem item;

  const _MetaGrid({required this.item});

  @override
  Widget build(BuildContext context) {
    final tiles = <(String, String)>[
      ('Size', item.fileSize.isNotEmpty ? item.fileSize : item.meta),
      if (item.resolution.isNotEmpty) ('Resolution', item.resolution),
      if (item.durationLabel.isNotEmpty) ('Duration', item.durationLabel),
      if (item.createdLabel.isNotEmpty) ('Created', item.createdLabel),
      ('Type', item.isVideo ? 'Video' : 'Image'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [
          for (final t in tiles)
            SizedBox(
              width: (MediaQuery.sizeOf(context).width - 40 - 32 - 12) / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.$1.toUpperCase(),
                    style: AppTheme.body(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.neonTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.$2,
                    style: AppTheme.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
