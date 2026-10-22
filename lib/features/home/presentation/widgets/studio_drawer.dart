import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class StudioDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  /// 0 = all history, 1 = videos only, 2 = photos only (when opening History tab)
  final ValueChanged<int>? onHistorySection;

  const StudioDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    this.onHistorySection,
  });

  void _go(BuildContext context, int index, {int? historySection}) {
    Navigator.of(context).pop();
    onNavigate(index);
    if (historySection != null) {
      onHistorySection?.call(historySection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/brand/snipr-app-icon-teal.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      semanticLabel: 'Snipr',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/brand/snipr-wordmark-on-dark.png',
                          height: 22,
                          alignment: Alignment.centerLeft,
                          semanticLabel: 'Snipr',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'EVERY PLAY DESERVES A REPLAY',
                          style: AppTheme.motto(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surfaceBorder, height: 1),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Text(
                'NAVIGATE',
                style: AppTheme.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.neonTeal,
                ),
              ),
            ),
            _DrawerTile(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => _go(context, 0),
            ),
            _DrawerTile(
              icon: Icons.movie_outlined,
              selectedIcon: Icons.movie_filter_rounded,
              label: 'Videos',
              selected: currentIndex == 1,
              onTap: () => _go(context, 1),
            ),
            _DrawerTile(
              icon: Icons.photo_outlined,
              selectedIcon: Icons.photo_rounded,
              label: 'Photos',
              selected: currentIndex == 2,
              onTap: () => _go(context, 2),
            ),
            _DrawerTile(
              icon: Icons.history_rounded,
              selectedIcon: Icons.history_rounded,
              label: 'History',
              selected: currentIndex == 3,
              onTap: () => _go(context, 3, historySection: 0),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.surfaceBorder, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Text(
                'HISTORY',
                style: AppTheme.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.neonTeal,
                ),
              ),
            ),
            _DrawerTile(
              icon: Icons.videocam_outlined,
              selectedIcon: Icons.videocam_rounded,
              label: 'Video history',
              selected: false,
              dense: true,
              onTap: () => _go(context, 3, historySection: 1),
            ),
            _DrawerTile(
              icon: Icons.image_outlined,
              selectedIcon: Icons.image_rounded,
              label: 'Photo history',
              selected: false,
              dense: true,
              onTap: () => _go(context, 3, historySection: 2),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Text(
                'Clip it. Ship it.',
                style: AppTheme.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool dense;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.neonTeal : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.neonTeal.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: dense ? 10 : 12,
            ),
            child: Row(
              children: [
                Icon(selected ? selectedIcon : icon, size: dense ? 20 : 22, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.body(
                      fontSize: dense ? 14 : 15,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.neonTeal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
