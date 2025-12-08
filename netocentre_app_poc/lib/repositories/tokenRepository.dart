import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';
import 'package:netocentre_app_poc/singletons/userInfo.dart';
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
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'TGC VARCHAR(255), '
          'JSESSIONID VARCHAR(255), '
          'idPortal VARCHAR(255), '
          'uid VARCHAR(255), '
          'name VARCHAR(255), '
          'picture VARCHAR(255)'
          ')',
        );
      },
      onDowngrade: onDatabaseDowngradeDelete,
      version: 1,
    );
  }

  /// Add DB tokens
  Future<void> insertTokens() async {
    final db = await getDB();

    int id = await db.insert(
        'tokens',
        {
          'TGC': TokenManager().TGC,
          'JSESSIONID': TokenManager().JSESSIONID,
          'idPortal': TokenManager().idPortal
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    TokenManager().setId(id.toString());
    log.fine('Save in database for ${TokenManager().toString()}');
  }

  /// Update DB tokens
  Future<void> updateTokens() async {
    final db = await getDB();

    await db.update(
      'tokens',
      {
        'TGC': TokenManager().TGC,
        'JSESSIONID': TokenManager().JSESSIONID,
        'idPortal': TokenManager().idPortal
      },
      where: 'id = ${TokenManager().id}',
    );
    log.fine('Update in database for ${TokenManager().toString()}');
  }

  Future<void> flushUserInfo() async {
    final db = await getDB();

    await db.update(
      'tokens',
      {
        'uid': UserInfo().uid,
        'name': UserInfo().name,
        'picture': UserInfo().picture
      },
      where: 'id = ${TokenManager().id}',
    );
    log.fine('Update in database for ${TokenManager().toString()}');
  }

  /// Synchronize tokens from TokenManager singleton with tokens who are in the database
  Future<void> flushTokens() async {
    log.fine('Flush in database for ${TokenManager().toString()}');

    if (TokenManager().id != "") {
      updateTokens();
    } else {
      insertTokens();
    }
  }

  Future<void> deleteCookiesForCurrentProfile() async {
    log.fine('Delete in database');
    final db = await getDB();
    await db.execute(
        "DELETE FROM tokens where id = ${TokenManager().id}");
  }

  Future<void> getCookiesInDB() async {
    final db = await getDB();
    log.fine('Get from database');
    int? count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tokens'));
    if (count! > 0) {
      List<Map<String, Object?>> res = await db.query('tokens',
          where: 'id = ${TokenManager().id}');
      TokenManager().setTGC(res.first["TGC"].toString());
      TokenManager().setJSESSIONID(res.first["JSESSIONID"].toString());
      TokenManager().setIdPortal(res.first["idPortal"].toString());
      log.fine(
          'TokenManager after getting values from database : ${TokenManager().toString()}');
    } else {
      log.fine("Empty database");
    }
  }

  Future<List<Map<String, Object?>>> getProfilesList() async {
    final db = await getDB();
    log.fine('Get profiles from database');
    final results = await db.query('tokens', distinct: true);
    return results.toList();
  }
}
