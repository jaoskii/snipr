import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MemeTextDialog extends StatefulWidget {
  final void Function(String text, bool isMemeStyle) onSubmitted;

  const MemeTextDialog({
    super.key,
    required this.onSubmitted,
  });

  @override
  State<MemeTextDialog> createState() => _MemeTextDialogState();
}

class _MemeTextDialogState extends State<MemeTextDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isMemeStyle = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      title: const Text('Add Text / Caption', style: TextStyle(fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter caption text...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Impact Meme Style'),
                selected: _isMemeStyle,
                onSelected: (val) => setState(() => _isMemeStyle = true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Subtitle Pill'),
                selected: !_isMemeStyle,
                onSelected: (val) => setState(() => _isMemeStyle = false),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              widget.onSubmitted(text, _isMemeStyle);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Add Text'),
        ),
      ],
    );
  }
}
