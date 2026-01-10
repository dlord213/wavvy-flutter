import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DbHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = p.join(await getDatabasesPath(), "wavvy_playlists.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
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
      },
    );
  }

  Future<void> initStatsTable() async {
    final db = await this.db;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS song_stats (
        song_id INTEGER PRIMARY KEY,
        play_count INTEGER DEFAULT 0,
        last_played INTEGER
      )
    ''');
  }

  Future<void> logSongPlay(int songId) async {
    final db = await this.db;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Try to update existing row
    int count = await db.rawUpdate(
      '''
      UPDATE song_stats 
      SET play_count = play_count + 1, last_played = ? 
      WHERE song_id = ?
    ''',
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
    return await db.query(
      'song_stats',
      orderBy: 'play_count DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getRecentlyPlayed(int limit) async {
    final db = await this.db;
    return await db.query(
      'song_stats',
      orderBy: 'last_played DESC',
      limit: limit,
    );
  }
}
