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
            'AccessToken VARCHAR(255), '
            'RefreshToken VARCHAR(255), '
            'TGT VARCHAR(255), '
            'JSESSIONID VARCHAR(255), '
            'idPortal VARCHAR(255),'
            'AccessTokenExpiresDate INT, '
            'RefreshTokenExpiresDate INT'
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
          'AccessToken': TokenManager().accessToken,
          'RefreshToken': TokenManager().refreshToken,
          'TGT': TokenManager().TGT,
          'JSESSIONID': TokenManager().JSESSIONID,
          'idPortal': TokenManager().idPortal,
          'AccessTokenExpiresDate': TokenManager().accessTokenExpiresDate.millisecondsSinceEpoch,
          'RefreshTokenExpiresDate': TokenManager().refreshTokenExpiresDate.millisecondsSinceEpoch
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    //print("row added");
  }

  /// Update DB tokens
  Future<void> updateTokens() async {
    final db = await getDB();

    await db.update(
      'tokens',
      {
        'AccessToken': TokenManager().accessToken,
        'RefreshToken': TokenManager().refreshToken,
        'TGT': TokenManager().TGT,
        'JSESSIONID': TokenManager().JSESSIONID,
        'idPortal': TokenManager().idPortal,
        'AccessTokenExpiresDate': TokenManager().accessTokenExpiresDate.millisecondsSinceEpoch,
        'RefreshTokenExpiresDate': TokenManager().refreshTokenExpiresDate.millisecondsSinceEpoch
      },
      where: 'TGT = ?',
      whereArgs: [TokenManager().TGT],
    );
    //print("row updated");
  }

  /// Synchronize tokens from TokenManager singleton with tokens who are in the database
  Future<void> flushTokens() async {
    final db = await getDB();

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
    final db = await getDB();
    await db.execute("DELETE FROM tokens");
  }

  Future<void> getLastValidRefreshToken() async{
    final db = await getDB();
    int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tokens'));
    if(count! > 0){
    List<Map<String, Object?>> res = await db.query('tokens', limit: 1, orderBy: 'RefreshTokenExpiresDate');
      TokenManager().setAccessToken(res.first["AccessToken"].toString());
      TokenManager().setRefreshToken(res.first["RefreshToken"].toString());
      TokenManager().setTGT(res.first["TGT"].toString());
      TokenManager().setJSESSIONID(res.first["JSESSIONID"].toString());
      TokenManager().setIdPortal(res.first["idPortal"].toString());
      TokenManager().setAccessTokenExpiresDate(DateTime.fromMillisecondsSinceEpoch(res.first["AccessTokenExpiresDate"] as int));
      TokenManager().setRefreshTokenExpiresDate(DateTime.fromMillisecondsSinceEpoch(res.first["RefreshTokenExpiresDate"] as int));
      print("when i got the last valid refresh token from repo :${TokenManager().toString()}");
    }
    else {
      print("Empty database");
    }
  }
}