import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../home/presentation/widgets/recent_history_list.dart';

/// CRUD + search over local history/directories.
/// Callers: HomeScreen. No placeholder seed data.
class HistoryDirectory {
  const HistoryDirectory({
    required this.id,
    required this.path,
    required this.label,
    required this.lastUsedAt,
  });

  final int id;
  final String path;
  final String label;
  final DateTime lastUsedAt;
}

class HistoryRepository {
  HistoryRepository({AppDatabase? database})
      : _appDb = database ?? AppDatabase.instance;

  final AppDatabase _appDb;

  Future<Database> get _db => _appDb.database;

  Future<List<HistoryItem>> getHistory({
    HistoryMediaType? mediaType,
    String query = '',
  }) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];

    if (mediaType != null) {
      where.add('media_type = ?');
      args.add(mediaType == HistoryMediaType.video ? 'video' : 'image');
    }

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      where.add(
        '(LOWER(title) LIKE ? OR LOWER(subtitle) LIKE ? OR LOWER(directory_path) LIKE ? OR LOWER(meta) LIKE ?)',
      );
      final like = '%${_escapeLike(q)}%';
      args.addAll([like, like, like, like]);
    }

    final rows = await db.query(
      'history_items',
      where: where.isEmpty
          ? null
          : where.join(' AND ').replaceAll(
                'LIKE ?',
                'LIKE ? ESCAPE \'\\\'',
              ),
      whereArgs: where.isEmpty ? null : args,
      orderBy: 'created_at DESC, id DESC',
    );

    return rows.map(_mapItem).toList();
  }

  Future<List<HistoryDirectory>> getDirectories({String query = ''}) async {
    final db = await _db;
    final q = query.trim().toLowerCase();
    final rows = await db.query(
      'directories',
      where: q.isEmpty
          ? null
          : '(LOWER(path) LIKE ? ESCAPE \'\\\' OR LOWER(label) LIKE ? ESCAPE \'\\\')',
      whereArgs:
          q.isEmpty ? null : ['%${_escapeLike(q)}%', '%${_escapeLike(q)}%'],
      orderBy: 'last_used_at DESC',
    );

    return rows
        .map(
          (r) => HistoryDirectory(
            id: r['id'] as int,
            path: r['path'] as String,
            label: r['label'] as String,
            lastUsedAt: DateTime.tryParse(r['last_used_at'] as String) ??
                DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> rememberDirectory(String path, {String? label}) async {
    if (path.isEmpty) return;
    final db = await _db;
    final name = label ?? path.split('/').where((s) => s.isNotEmpty).last;
    await db.insert(
      'directories',
      {
        'path': path,
        'label': name,
        'last_used_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    final db = await _db;
    await rememberDirectory(item.directoryPath);
    await db.insert('history_items', {
      'title': item.title,
      'subtitle': item.subtitle,
      'meta': item.meta,
      'media_type': item.isVideo ? 'video' : 'image',
      'directory_path': item.directoryPath,
      'file_path': item.filePath,
      'tint_value': item.tint.toARGB32(),
      'icon_code_point': item.icon.codePoint,
      'preview_asset': item.previewAsset,
      'preview_video_url': item.previewVideoUrl,
      'duration_label': item.durationLabel,
      'resolution': item.resolution,
      'created_label': item.createdLabel,
      'file_size': item.fileSize,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static String _escapeLike(String input) {
    return input
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  HistoryItem _mapItem(Map<String, Object?> row) {
    final media = (row['media_type'] as String) == 'image'
        ? HistoryMediaType.image
        : HistoryMediaType.video;
    final codePoint = row['icon_code_point'] as int;
    return HistoryItem(
      id: row['id'] as int?,
      icon: _iconFor(codePoint, media),
      title: row['title'] as String,
      subtitle: row['subtitle'] as String,
      meta: row['meta'] as String,
      tint: Color(row['tint_value'] as int),
      mediaType: media,
      directoryPath: row['directory_path'] as String,
      filePath: row['file_path'] as String?,
      previewAsset: row['preview_asset'] as String?,
      previewVideoUrl: row['preview_video_url'] as String?,
      durationLabel: row['duration_label'] as String? ?? '',
      resolution: row['resolution'] as String? ?? '',
      createdLabel: row['created_label'] as String? ?? '',
      fileSize: row['file_size'] as String? ?? '',
    );
  }

  static IconData _iconFor(int codePoint, HistoryMediaType media) {
    final known = <IconData>[
      Icons.sports_esports_rounded,
      Icons.bolt_rounded,
      Icons.emoji_events_rounded,
      Icons.campaign_rounded,
      Icons.blur_on_rounded,
      Icons.highlight_rounded,
      Icons.movie_filter_rounded,
      Icons.photo_rounded,
    ];
    for (final icon in known) {
      if (icon.codePoint == codePoint) return icon;
    }
    return media == HistoryMediaType.image
        ? Icons.photo_rounded
        : Icons.movie_filter_rounded;
  }
}
