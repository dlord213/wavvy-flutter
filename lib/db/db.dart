import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DbHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
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
}
