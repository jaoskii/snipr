import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../video_processor/presentation/screens/video_studio_screen.dart';
import '../widgets/asset_upload_zone.dart';

/// Videos tab. Callers: home navigation (legacy/alternate).
/// User: "can you remove the history (placeholder data for the history / recent clips and images)"
class VideoTabScreen extends StatefulWidget {
  final bool showPageHeader;
  final bool compact;

  const VideoTabScreen({
    super.key,
    this.showPageHeader = true,
    this.compact = false,
  });

  @override
  State<VideoTabScreen> createState() => _VideoTabScreenState();
}

class _VideoTabScreenState extends State<VideoTabScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoStudioScreen(videoPath: file.path),
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
            onTap: _pickVideo,
            icon: Icons.file_upload_outlined,
            title: 'Tap to Upload',
            formats: 'MP4, MOV, MKV',
            badge: '2-Pass Discord Fit',
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
