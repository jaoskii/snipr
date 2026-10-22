import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../image_studio/presentation/screens/image_studio_screen.dart';
import '../widgets/asset_upload_zone.dart';

/// Photos tab. Callers: home navigation (legacy/alternate).
/// User: "can you remove the history (placeholder data for the history / recent clips and images)"
class ImageTabScreen extends StatefulWidget {
  final bool showPageHeader;
  final bool compact;

  const ImageTabScreen({
    super.key,
    this.showPageHeader = true,
    this.compact = false,
  });

  @override
  State<ImageTabScreen> createState() => _ImageTabScreenState();
}

class _ImageTabScreenState extends State<ImageTabScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImageStudioScreen(imagePath: file.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.compact)
          AssetUploadZone(
            onTap: _pickImage,
            icon: Icons.file_upload_outlined,
            title: 'Tap to Upload',
            formats: 'PNG, JPG, WEBP',
            badge: 'Studio Tools',
          ),
      ],
    );

    if (widget.compact) return content;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: content,
    );
  }
}
