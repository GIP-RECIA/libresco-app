import 'package:logging/logging.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/user_info.dart';
import 'package:libresco/repositories/database_provider.dart';

class UserInfoRepository {
  final log = Logger('UserInfoRepository');

  UserInfoRepository._privateConstructor();

  static final UserInfoRepository _instance =
      UserInfoRepository._privateConstructor();

  static UserInfoRepository get instance => _instance;

  final tableName = DatabaseProvider.tableName;

  Future<void> update() async {
    final db = await DatabaseProvider.instance.db;
    await db.update(
      tableName,
      UserInfo().mapForDatabase(),
      where: 'id = ${Account().id}',
    );
    Account().setDomain(UserInfo().domain);
    log.fine('Update in database : ${UserInfo().toString()}');
  }
}
