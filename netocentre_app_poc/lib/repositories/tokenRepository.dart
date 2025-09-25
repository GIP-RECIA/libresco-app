import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';

class TokenRepository {

  TokenRepository();

  /// DB connection
  Future<Database> getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'token_manager.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tokens('
            'id INTEGER, '
            'TGT VARCHAR(255), '
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
          'id': 1,
          'TGT': TokenManager().TGT,
          'JSESSIONID': TokenManager().JSESSIONID,
          'idPortal': TokenManager().idPortal
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    print("SAVE IN DATABASE");
  }

  /// Update DB tokens
  Future<void> updateTokens() async {
    final db = await getDB();

    await db.update(
      'tokens',
      {
        'id': 1,
        'TGT': TokenManager().TGT,
        'JSESSIONID': TokenManager().JSESSIONID,
        'idPortal': TokenManager().idPortal
      },
      where: 'id=1',
    );
    print("UPDATE IN DATABASE");
  }

  /// Synchronize tokens from TokenManager singleton with tokens who are in the database
  Future<void> flushTokens() async {
    final db = await getDB();

    print("FLUSH IN DATABASE");
    print(TokenManager());

    int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tokens'));
    if(count! > 0){
      updateTokens();
    }
    else{
      insertTokens();
    }
  }

  Future<void> deleteAllRows() async {
    print("DELETE FROM DATABASE");
    final db = await getDB();
    await db.execute("DELETE FROM tokens");
  }

  Future<void> getLastValidRefreshToken() async{
    final db = await getDB();
    print("GET FROM DATABASE");
    int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tokens'));
    if(count! > 0){
    List<Map<String, Object?>> res = await db.query('tokens', limit: 1);
      TokenManager().setTGT(res.first["TGT"].toString());
      TokenManager().setJSESSIONID(res.first["JSESSIONID"].toString());
      TokenManager().setIdPortal(res.first["idPortal"].toString());
    }
    else {
      print("Empty database");
    }
  }
}