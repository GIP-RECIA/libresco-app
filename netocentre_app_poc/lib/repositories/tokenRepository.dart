import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TokenRepository {
  final log = Logger('TokenRepository');

  TokenRepository._privateConstructor();

  static final TokenRepository _instance =
      TokenRepository._privateConstructor();

  static TokenRepository get instance => _instance;

  /// DB connection
  Future<Database> getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'token_manager.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tokens('
          'id INTEGER, '
          'TGC VARCHAR(255), '
          'JSESSIONID VARCHAR(255), '
          'idPortal VARCHAR(255)'
          ')',
        );
      },
      version: 1,
    );
  }

  /// Add DB tokens
  Future<void> insertTokens() async {
    final db = await getDB();

    await db.insert(
        'tokens',
        {
          'id': TokenManager().currentProfileID,
          'TGC': TokenManager().TGC,
          'JSESSIONID': TokenManager().JSESSIONID,
          'idPortal': TokenManager().idPortal
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    log.fine('Save in database for ${TokenManager().toString()}');
  }

  /// Update DB tokens
  Future<void> updateTokens() async {
    final db = await getDB();

    await db.update(
      'tokens',
      {
        'id': TokenManager().currentProfileID,
        'TGC': TokenManager().TGC,
        'JSESSIONID': TokenManager().JSESSIONID,
        'idPortal': TokenManager().idPortal
      },
      where: 'id=1',
    );
    log.fine('Update in database for ${TokenManager().toString()}');
  }

  /// Synchronize tokens from TokenManager singleton with tokens who are in the database
  Future<void> flushTokens() async {
    final db = await getDB();

    log.fine('Flush in database for ${TokenManager().toString()}');

    int? count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tokens'));
    if (count! > 0) {
      updateTokens();
    } else {
      insertTokens();
    }
  }

  Future<void> deleteCookiesForCurrentProfile() async {
    log.fine('Delete in database');
    final db = await getDB();
    await db.execute(
        "DELETE FROM tokens where id = ${TokenManager().currentProfileID}");
  }

  Future<void> getCookiesInDB() async {
    final db = await getDB();
    log.fine('Get from database');
    int? count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tokens'));
    if (count! > 0) {
      List<Map<String, Object?>> res = await db.query('tokens',
          where: 'id = ?',
          whereArgs: [TokenManager().currentProfileID],
          limit: 1);
      TokenManager().setTGC(res.first["TGC"].toString());
      TokenManager().setJSESSIONID(res.first["JSESSIONID"].toString());
      TokenManager().setIdPortal(res.first["idPortal"].toString());
      log.fine(
          'TokenManager after getting values from database : ${TokenManager().toString()}');
    } else {
      log.fine("Empty database");
    }
  }

  Future<List<int>> getProfilesList() async {
    final db = await getDB();
    log.fine('Get profiles from database');
    final results = await db.query('tokens', columns: ['id'], distinct: true);
    return results.map((row) => row['id'] as int).toList();
  }
}
