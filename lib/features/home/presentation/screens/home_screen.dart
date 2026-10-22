import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/floating_bottom_nav.dart';
import '../../../history/data/history_repository.dart';
import '../../../image_studio/presentation/screens/image_studio_screen.dart';
import '../../../video_processor/presentation/screens/video_studio_screen.dart';
import '../widgets/asset_upload_zone.dart';
import '../widgets/recent_history_list.dart';
import '../widgets/studio_action_cards.dart';
import '../widgets/studio_drawer.dart';
import 'history_detail_screen.dart';

/// Home shell: search (local DB), tabs, edge-to-edge nav.
/// Callers: app router / SnipRApp. User: "fix the alignment of the text
/// inside the textbox / also search is not working… local database…
/// / also can you fix the curves below the background"
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  final _picker = ImagePicker();
  final _historyRepo = HistoryRepository();

  int _navIndex = 0;
  int _historySection = 0;
  String _searchQuery = '';
  bool _loadingHistory = true;
  bool _historyReady = false;
  int _loadToken = 0;
  List<HistoryItem> _clipHistory = const [];
  List<HistoryItem> _photoHistory = const [];
  List<HistoryDirectory> _directories = const [];
  Timer? _searchDebounce;

  static const _navItems = [
    FloatingBottomNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    FloatingBottomNavItem(
      label: 'Videos',
      icon: Icons.movie_outlined,
      selectedIcon: Icons.movie_filter_rounded,
    ),
    FloatingBottomNavItem(
      label: 'Photos',
      icon: Icons.photo_outlined,
      selectedIcon: Icons.photo_rounded,
    ),
    FloatingBottomNavItem(
      label: 'History',
      icon: Icons.history_rounded,
      selectedIcon: Icons.history_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadHistory();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      final next = _searchController.text;
      if (next == _searchQuery) return;
      setState(() => _searchQuery = next);
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final token = ++_loadToken;
    final showSpinner = !_historyReady;
    if (showSpinner) setState(() => _loadingHistory = true);
    try {
      final clips = await _historyRepo.getHistory(
        mediaType: HistoryMediaType.video,
        query: _searchQuery,
      );
      final photos = await _historyRepo.getHistory(
        mediaType: HistoryMediaType.image,
        query: _searchQuery,
      );
      final dirs = await _historyRepo.getDirectories(query: _searchQuery);
      if (!mounted || token != _loadToken) return;
      setState(() {
        _clipHistory = clips;
        _photoHistory = photos;
        _directories = dirs;
        _loadingHistory = false;
        _historyReady = true;
      });
    } catch (_) {
      if (!mounted || token != _loadToken) return;
      setState(() {
        _loadingHistory = false;
        _historyReady = true;
      });
    }
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _goTo(int index, {int historySection = 0}) {
    setState(() {
      _navIndex = index;
      if (index == 3) _historySection = historySection;
      if (index != 0 && _searchQuery.isNotEmpty) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
    if (index != 0) _loadHistory();
  }

  Future<void> _uploadClip() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    final dir = p.dirname(file.path);
    await _historyRepo.rememberDirectory(dir);
    await _historyRepo.addHistoryItem(
      HistoryItem(
        icon: Icons.movie_filter_rounded,
        title: p.basename(file.path),
        subtitle: 'Imported from gallery',
        meta: _fileSizeLabel(file.path),
        tint: AppColors.hotPink,
        mediaType: HistoryMediaType.video,
        directoryPath: dir,
        filePath: file.path,
        createdLabel: 'Just now',
        fileSize: _fileSizeLabel(file.path),
      ),
    );
    await _loadHistory();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VideoStudioScreen(videoPath: file.path)),
    );
  }

  Future<void> _editImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    final dir = p.dirname(file.path);
    await _historyRepo.rememberDirectory(dir);
    await _historyRepo.addHistoryItem(
      HistoryItem(
        icon: Icons.photo_rounded,
        title: p.basename(file.path),
        subtitle: 'Imported from gallery',
        meta: _fileSizeLabel(file.path),
        tint: AppColors.neonTeal,
        mediaType: HistoryMediaType.image,
        directoryPath: dir,
        filePath: file.path,
        createdLabel: 'Just now',
        fileSize: _fileSizeLabel(file.path),
      ),
    );
    await _loadHistory();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ImageStudioScreen(imagePath: file.path)),
    );
  }

  String _fileSizeLabel(String path) {
    try {
      final bytes = File(path).lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  void _openHistoryDetail(HistoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HistoryDetailScreen(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      extendBody: true,
      drawer: StudioDrawer(
        currentIndex: _navIndex,
        onNavigate: (i) => _goTo(i),
        onHistorySection: (section) => _goTo(3, historySection: section),
      ),
      body: Stack(
        children: [
          // Square full-bleed fill so bottom display corners aren't clipped/curved.
          const Positioned.fill(
            child: ColoredBox(color: AppColors.background),
          ),
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.hotPink.withValues(alpha: 0.28),
              ),
            ),
          ),
          Positioned(
            top: 180,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonTeal.withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: const SizedBox.expand(),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 96 + MediaQuery.paddingOf(context).bottom,
              ),
              child: _buildBody(),
            ),
          ),
          // Square strip under the floating pill (no radius) to the device edges.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.paddingOf(context).bottom + 8,
            child: const ColoredBox(color: AppColors.background),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingBottomNav(
              items: _navItems,
              currentIndex: _navIndex,
              onTap: (i) => _goTo(i, historySection: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton() {
    return IconButton(
      onPressed: _openDrawer,
      icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 1:
        return _buildUploadPage(
          title: 'Videos',
          subtitle: 'Import gaming highlights to trim and compress.',
          child: AssetUploadZone(
            onTap: _uploadClip,
            icon: Icons.file_upload_outlined,
            title: 'Tap to Upload',
            formats: 'MP4, MOV, MKV',
            badge: '2-Pass Discord Fit',
          ),
        );
      case 2:
        return _buildUploadPage(
          title: 'Photos',
          subtitle: 'Import stills for marks, blur, and memes.',
          child: AssetUploadZone(
            onTap: _editImage,
            icon: Icons.file_upload_outlined,
            title: 'Tap to Upload',
            formats: 'PNG, JPG, WEBP',
            badge: 'Studio Tools',
          ),
        );
      case 3:
        return _buildHistoryPage();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildUploadPage({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(children: [_menuButton(), const Spacer()]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.display(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(subtitle, style: AppTheme.body(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryPage() {
    final showVideos = _historySection == 0 || _historySection == 1;
    final showPhotos = _historySection == 0 || _historySection == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(children: [_menuButton(), const Spacer()]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('History', style: AppTheme.display(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'Your past clips and photo edits.',
                style: AppTheme.body(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _HistoryChip(label: 'All', selected: _historySection == 0, onTap: () => setState(() => _historySection = 0)),
                    const SizedBox(width: 8),
                    _HistoryChip(label: 'Videos', selected: _historySection == 1, onTap: () => setState(() => _historySection = 1)),
                    const SizedBox(width: 8),
                    _HistoryChip(label: 'Photos', selected: _historySection == 2, onTap: () => setState(() => _historySection = 2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingHistory
              ? const Center(child: CircularProgressIndicator(color: AppColors.neonTeal))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: Column(
                    children: [
                      if (showVideos && _clipHistory.isNotEmpty)
                        RecentHistoryList(
                          title: 'Videos',
                          items: _clipHistory,
                          onAction: _openHistoryDetail,
                        ),
                      if (showVideos &&
                          showPhotos &&
                          _clipHistory.isNotEmpty &&
                          _photoHistory.isNotEmpty)
                        const SizedBox(height: 28),
                      if (showPhotos && _photoHistory.isNotEmpty)
                        RecentHistoryList(
                          title: 'Photos',
                          items: _photoHistory,
                          onAction: _openHistoryDetail,
                        ),
                      if ((showVideos ? _clipHistory.isEmpty : true) &&
                          (showPhotos ? _photoHistory.isEmpty : true))
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            _searchQuery.trim().isNotEmpty
                                ? 'No results for “$_searchQuery”'
                                : 'No history yet. Upload a clip or photo to get started.',
                            style: AppTheme.body(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    final recentClips = _clipHistory.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              _menuButton(),
              const Spacer(),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.hotPink.withValues(alpha: 0.5), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/brand/snip-character-avatar-teal.png',
                  fit: BoxFit.cover,
                  semanticLabel: 'Snip profile',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Snipr Studio', style: AppTheme.display(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'Everything you need in one place.',
                style: AppTheme.body(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              _SearchField(controller: _searchController),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loadingHistory
              ? const Center(child: CircularProgressIndicator(color: AppColors.neonTeal))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_searchQuery.trim().isEmpty) ...[
                        StudioActionCards(
                          onUploadClip: () => _goTo(1),
                          onEditImage: () => _goTo(2),
                        ),
                        if (recentClips.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          RecentHistoryList(
                            title: 'Recent clips',
                            items: recentClips,
                            onAction: _openHistoryDetail,
                          ),
                        ],
                      ] else ...[
                        Text(
                          'Results',
                          style: AppTheme.display(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        if (_directories.isNotEmpty) ...[
                          Text(
                            'Directories',
                            style: AppTheme.body(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._directories.map(
                            (d) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.folder_outlined, size: 18, color: AppColors.neonTeal),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      d.label,
                                      style: AppTheme.body(fontSize: 14),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      d.path,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                      style: AppTheme.body(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (_clipHistory.isNotEmpty)
                          RecentHistoryList(
                            title: 'Videos',
                            items: _clipHistory,
                            onAction: _openHistoryDetail,
                          ),
                        if (_clipHistory.isNotEmpty && _photoHistory.isNotEmpty)
                          const SizedBox(height: 24),
                        if (_photoHistory.isNotEmpty)
                          RecentHistoryList(
                            title: 'Photos',
                            items: _photoHistory,
                            onAction: _openHistoryDetail,
                          ),
                        if (_clipHistory.isEmpty &&
                            _photoHistory.isEmpty &&
                            _directories.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: Text(
                              'No results for “$_searchQuery”',
                              style: AppTheme.body(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/// Vertically centered search field. User: "fix the alignment of the text inside the textbox"
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTheme.body(fontSize: 14),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search here...',
                hintStyle: AppTheme.body(fontSize: 14, color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
        ],
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.neonTeal.withValues(alpha: 0.18) : AppColors.surface.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.neonTeal : AppColors.surfaceBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.body(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.neonTeal : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
