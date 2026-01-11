import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DbHelper {
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();
  factory DbHelper() => instance;

  static Database? _db;

  static const int _dbVersion = 2;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = p.join(await getDatabasesPath(), "wavvy_playlists.db");

    return await openDatabase(
      path,
      version: _dbVersion,

      // For NEW users (Runs once when app is installed)
      onCreate: (db, version) async {
        await _createPlaylistTables(db);
        await _createStatsTable(db);
      },

      // For EXISTING users (Runs if they have Ver 1 and upgrade to Ver 2)
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createStatsTable(db);
        }
      },
    );
  }

  Future<void> _createPlaylistTables(Database db) async {
    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE playlist_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER,
        song_id INTEGER,
        FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createStatsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS song_stats (
        song_id INTEGER PRIMARY KEY,
        play_count INTEGER DEFAULT 0,
        last_played INTEGER
      )
    ''');
  }

  // --- QUERY METHODS ---

  Future<void> logSongPlay(int songId) async {
    final db = await this.db;
    final now = DateTime.now().millisecondsSinceEpoch;
    int count = await db.rawUpdate(
      'UPDATE song_stats SET play_count = play_count + 1, last_played = ? WHERE song_id = ?',
      [now, songId],
    );
    if (count == 0) {
      await db.insert('song_stats', {
        'song_id': songId,
        'play_count': 1,
        'last_played': now,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getMostPlayed(int limit) async {
    final db = await this.db;
    try {
      return await db.query(
        'song_stats',
        orderBy: 'play_count DESC',
        limit: limit,
      );
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentlyPlayed(int limit) async {
    final db = await this.db;
    try {
      return await db.query(
        'song_stats',
        orderBy: 'last_played DESC',
        limit: limit,
      );
    } catch (e) {
      return [];
    }
  }
}
