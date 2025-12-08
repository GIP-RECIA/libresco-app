import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/repositories/databaseProvider.dart';
import 'package:netocentre_app_poc/singletons/account.dart';
import 'package:netocentre_app_poc/singletons/userInfo.dart';

class UserInfoRepository {
  final log = Logger('UserInfoRepository');

  UserInfoRepository._privateConstructor();

  static final UserInfoRepository _instance =
      UserInfoRepository._privateConstructor();

  static UserInfoRepository get instance => _instance;

  final tableName = DatabaseProvider.tableName;

  Future<void> flushUserInfo() async {
    final db = await DatabaseProvider.instance.db;

    await db.update(
      tableName,
      {
        'uid': UserInfo().uid,
        'name': UserInfo().name,
        'picture': UserInfo().picture
      },
      where: 'id = ${Account().id}',
    );
    log.fine('Update in database for ${UserInfo().toString()}');
  }
}
