import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/session.dart';
import 'package:libresco/objects/singletons/user_info.dart';
import 'package:libresco/repositories/database_provider.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class SessionRepository {
  final log = Logger('SessionRepository');

  SessionRepository._privateConstructor();

  static final SessionRepository _instance = SessionRepository._privateConstructor();

  static SessionRepository get instance => _instance;

  final tableName = DatabaseProvider.tableName;

  Future<void> insert() async {
    final db = await DatabaseProvider.instance.db;
    int id = await db.insert(
      tableName,
      Session().mapForDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    Account().setId(id);
    log.fine('Save in database : ${Session().toString()}');
  }

  Future<void> update() async {
    final db = await DatabaseProvider.instance.db;
    await db.update(
      tableName,
      Session().mapForDatabase(),
      where: 'id = ?',
      whereArgs: [Account().id],
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
      where: 'id = ?',
      whereArgs: [id],
    );
    if (response.isNotEmpty) {
      Session().loadFromDatabase(response.first);
      log.fine('Get from database : ${Session().toString()}');
    } else {
      log.info('Get from database - no results for $id');
    }
  }

  Future<void> deleteAll({int? id}) async {
    id ??= Account().id;
    final db = await DatabaseProvider.instance.db;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    Account().clear();
    Session().clear();
    UserInfo().clear();
    log.fine('Row $id successfully deleted');
  }

  Future<List<Map<String, Object?>>> getProfilesList() async {
    log.finer('Getting profiles from database');
    final db = await DatabaseProvider.instance.db;
    final results = await db.query(tableName, distinct: true);
    return results.toList();
  }

  Future<void> deleteExistingProfile(String uid, int id) async {
    final db = await DatabaseProvider.instance.db;
    await db.delete(
      tableName,
      where: 'id != ? AND uid = ?',
      whereArgs: [id, uid],
    );
    log.fine('Duplicated profile successfully deleted');
  }

  Future<bool> doesAccountAlreadyExists(String uid) async {
    final db = await DatabaseProvider.instance.db;
    List<Map<String, Object?>> response = await db.query(
      tableName,
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (response.length >= 2) {
      return true;
    }
    return false;
  }
}
