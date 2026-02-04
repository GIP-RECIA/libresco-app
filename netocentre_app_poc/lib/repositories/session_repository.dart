import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/account.dart';
import 'package:netocentre_app_poc/objects/singletons/session.dart';
import 'package:netocentre_app_poc/objects/singletons/user_info.dart';
import 'package:netocentre_app_poc/repositories/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class SessionRepository {
  final log = Logger('SessionRepository');

  SessionRepository._privateConstructor();

  static final SessionRepository _instance =
      SessionRepository._privateConstructor();

  static SessionRepository get instance => _instance;

  final tableName = DatabaseProvider.tableName;

  Future<void> insert() async {
    final db = await DatabaseProvider.instance.db;
    int id = await db.insert(
      tableName,
      Session().toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    Account().setId(id);
    log.fine('Save in database : ${Session().toString()}');
  }

  Future<void> update() async {
    final db = await DatabaseProvider.instance.db;
    await db.update(
      tableName,
      Session().toMap(),
      where: 'id = ${Account().id}',
    );
    log.fine('Update in database : ${Session().toString()}');
  }

  Future<void> flush() async {
    if (Account().id != null) {
      update();
    } else {
      insert();
    }
  }

  Future<void> load({int? id}) async {
    id ??= Account().id;
    final db = await DatabaseProvider.instance.db;
    List<Map<String, Object?>> response = await db.query(
      tableName,
      where: 'id = $id',
    );
    if (response.isNotEmpty) {
      Session().fromMap(response.first);
      log.fine(
        'Get from database : ${Session().toString()}',
      );
    } else {
      log.fine('No results for id $id');
    }
  }

  Future<void> deleteAll({int? id}) async {
    id ??= Account().id;
    final db = await DatabaseProvider.instance.db;
    await db.execute(
      'DELETE FROM $tableName where id = $id',
    );
    Account().clear();
    Session().clear();
    UserInfo().clear();
    log.fine('Row id \'$id\' successfully deleted');
  }

  Future<List<Map<String, Object?>>> getProfilesList() async {
    final db = await DatabaseProvider.instance.db;
    log.fine('Get profiles from database');
    final results = await db.query(tableName, distinct: true);
    return results.toList();
  }

  Future<void> deleteExistingProfile(String uid, int id) async {
    final db = await DatabaseProvider.instance.db;
    await db.execute('DELETE FROM $tableName where id != $id and uid="$uid"',);
    log.fine('Duplicated profile successfully deleted');
  }

  Future<bool> doesAccountAlreadyExists(String uid) async{
    final db = await DatabaseProvider.instance.db;
    List<Map<String, Object?>> response = await db.query(tableName, where: 'uid = "$uid"',);
    if (response.length >= 2) {
      return true;
    }
    return false;
  }

}
