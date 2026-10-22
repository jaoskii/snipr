import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Local SQLite bootstrap for Snipr history + directories.
/// Callers: HistoryRepository via AppDatabase.instance.
/// Schema: directories, history_items, meta.
/// User: local database for history and directories.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'snipr.db';
  static const _dbVersion = 4;

  Database? _db;
  Future<Database>? _opening;

  Future<Database> get database async {
    if (_db != null) return _db!;
    return _opening ??= _open().then((db) {
      _db = db;
      return db;
    });
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS meta (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            UPDATE history_items
            SET preview_asset = REPLACE(preview_asset, 'snipr-app-icon-pink.png', 'snipr-app-icon-teal.png')
            WHERE preview_asset LIKE '%snipr-app-icon-pink.png%'
          ''');
          await db.execute('''
            UPDATE history_items
            SET preview_asset = REPLACE(
              preview_asset,
              'snip-character-avatar.png',
              'snip-character-avatar-teal.png'
            )
            WHERE preview_asset LIKE '%snip-character-avatar.png%'
              AND preview_asset NOT LIKE '%snip-character-avatar-teal.png%'
          ''');
        }
        if (oldVersion < 4) {
          // Drop placeholder seed history / directories.
          await db.delete('history_items');
          await db.delete('directories');
          await db.delete('meta');
        }
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE directories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        label TEXT NOT NULL,
        last_used_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE history_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        meta TEXT NOT NULL,
        media_type TEXT NOT NULL,
        directory_path TEXT NOT NULL,
        file_path TEXT,
        tint_value INTEGER NOT NULL,
        icon_code_point INTEGER NOT NULL,
        preview_asset TEXT,
        preview_video_url TEXT,
        duration_label TEXT NOT NULL DEFAULT '',
        resolution TEXT NOT NULL DEFAULT '',
        created_label TEXT NOT NULL DEFAULT '',
        file_size TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_history_title ON history_items(title)',
    );
    await db.execute(
      'CREATE INDEX idx_history_directory ON history_items(directory_path)',
    );
  }
}
