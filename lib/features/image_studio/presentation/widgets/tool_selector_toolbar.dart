import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/annotation_item.dart';

class ToolSelectorToolbar extends StatelessWidget {
  final AnnotationType selectedTool;
  final Color selectedColor;
  final bool canUndo;
  final bool canRedo;
  final ValueChanged<AnnotationType> onSelectTool;
  final ValueChanged<Color> onSelectColor;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onAddMemeText;

  const ToolSelectorToolbar({
    super.key,
    required this.selectedTool,
    required this.selectedColor,
    required this.canUndo,
    required this.canRedo,
    required this.onSelectTool,
    required this.onSelectColor,
    required this.onUndo,
    required this.onRedo,
    required this.onAddMemeText,
  });

  static const List<Color> _palette = [
    Color(0xFF00E5FF), // Mint
    Color(0xFFFF2BD6), // Magenta
    Color(0xFFFF3D6E), // Linear
    Color(0xFFFFB020), // Tactile
    Color(0xFF4D8BFF), // Clicky
    Color(0xFFF2F3FF), // Text white
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color Swatches + Undo / Redo
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.undo_rounded),
                  color: canUndo ? AppColors.textPrimary : AppColors.textMuted,
                  onPressed: canUndo ? onUndo : null,
                  tooltip: 'Undo',
                ),
                IconButton(
                  icon: const Icon(Icons.redo_rounded),
                  color: canRedo ? AppColors.textPrimary : AppColors.textMuted,
                  onPressed: canRedo ? onRedo : null,
                  tooltip: 'Redo',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _palette.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final color = _palette[index];
                        final isSelected = color == selectedColor;
                        return GestureDetector(
                          onTap: () => onSelectColor(color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.surfaceBorder, height: 16),
            // Tool selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildToolButton(
                  icon: Icons.arrow_outward_rounded,
                  label: 'Arrow',
                  tool: AnnotationType.arrow,
                ),
                _buildToolButton(
                  icon: Icons.crop_square_rounded,
                  label: 'Box',
                  tool: AnnotationType.rectangle,
                ),
                _buildToolButton(
                  icon: Icons.highlight_rounded,
                  label: 'Spotlight',
                  tool: AnnotationType.spotlight,
                ),
                _buildToolButton(
                  icon: Icons.blur_on_rounded,
                  label: 'Redact',
                  tool: AnnotationType.redactBlur,
                ),
                _buildToolButton(
                  icon: Icons.edit_rounded,
                  label: 'Draw',
                  tool: AnnotationType.freehandPen,
                ),
                IconButton(
                  icon: const Icon(Icons.title_rounded, color: AppColors.neonCyan),
                  onPressed: onAddMemeText,
                  tooltip: 'Add Caption / Meme Text',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required AnnotationType tool,
  }) {
    final isSelected = tool == selectedTool;
    return InkWell(
      onTap: () => onSelectTool(tool),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.discordIndigo.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.discordIndigo : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
