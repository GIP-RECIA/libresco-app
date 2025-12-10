import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/repositories/database_provider.dart';
import 'package:netocentre_app_poc/singletons/account.dart';
import 'package:netocentre_app_poc/singletons/session.dart';
import 'package:sqflite/sqflite.dart';

class SessionRepository {
  final log = Logger('SessionRepository');

  SessionRepository._privateConstructor();

  static final SessionRepository _instance =
      SessionRepository._privateConstructor();

  static SessionRepository get instance => _instance;

  final tableName = DatabaseProvider.tableName;

  Future<void> insertTokens() async {
    final db = await DatabaseProvider.instance.db;

    int id = await db.insert(
      tableName,
      {
        'CASSessionCookie': Session().CASSessionCookie,
        'PortalSessionCookie': Session().PortalSessionCookie,
        'IDPortalCookie': Session().IDPortalCookie
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    Account().setId(id.toString());
    log.fine('Save in database for ${Session().toString()}');
  }

  Future<void> updateTokens() async {
    final db = await DatabaseProvider.instance.db;

    await db.update(
      tableName,
      {
        'CASSessionCookie': Session().CASSessionCookie,
        'PortalSessionCookie': Session().PortalSessionCookie,
        'IDPortalCookie': Session().IDPortalCookie
      },
      where: 'id = ${Account().id}',
    );
    log.fine('Update in database for ${Session().toString()}');
  }

  Future<void> flushTokens() async {
    log.fine('Flush in database for ${Session().toString()}');

    if (Account().id != '') {
      updateTokens();
    } else {
      insertTokens();
    }
  }

  Future<void> deleteCookiesForCurrentProfile() async {
    log.fine('Delete in database');
    final db = await DatabaseProvider.instance.db;
    await db.execute('DELETE FROM $tableName where id = ${Account().id}');
  }

  Future<void> getCookiesInDB() async {
    final db = await DatabaseProvider.instance.db;
    log.fine('Get from database');
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
    if (count! > 0) {
      List<Map<String, Object?>> res =
          await db.query(tableName, where: 'id = ${Account().id}');
      Session().setCASSessionCookie(res.first['CASSessionCookie'].toString());
      Session()
          .setPortalSessionCookie(res.first['PortalSessionCookie'].toString());
      Session().setIDportalCookie(res.first['IDPortalCookie'].toString());
      log.fine(
        'Session after getting values from database : ${Session().toString()}',
      );
    } else {
      log.fine('Empty database');
    }
  }

  Future<List<Map<String, Object?>>> getProfilesList() async {
    final db = await DatabaseProvider.instance.db;
    log.fine('Get profiles from database');
    final results = await db.query(tableName, distinct: true);
    return results.toList();
  }
}
