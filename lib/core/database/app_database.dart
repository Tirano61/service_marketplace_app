import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static Database? _instance;

  /// Returns a singleton [Database] instance configured for the app.
  static Future<Database> get database async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = await _openDatabase();
    return _instance!;
  }

  static Future<Database> _openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'service_marketplace.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
    );
  }

  static Future<void> _createSchema(Database db) async {
    // Define your initial tables here. Example placeholders:
    await db.execute('''
      CREATE TABLE IF NOT EXISTS providers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        coverage_radius REAL NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS services (
        id TEXT PRIMARY KEY,
        provider_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        price REAL,
        FOREIGN KEY(provider_id) REFERENCES providers(id)
      );
    ''');
  }
}
