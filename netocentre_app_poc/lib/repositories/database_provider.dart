import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider instance = DatabaseProvider._();

  static final String tableName = 'user_data';

  Database? _database;

  Future<Database> get db async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            CASSessionCookie VARCHAR(255),
            PortalSessionCookie VARCHAR(255),
            IDPortalCookie VARCHAR(255),
            uid VARCHAR(255),
            name VARCHAR(255),
            picture VARCHAR(255),
            currentEtabName VARCHAR(255),
            domain VARCHAR(255),
            lastLogin INTEGER
          );
        ''');
      },
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }
}
