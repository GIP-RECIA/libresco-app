import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/repositories/user_info_repository.dart';

class UserInfo {
  final log = Logger('UserInfo');

  static final UserInfo _instance = UserInfo._internal();

  String _uid = '';
  String _name = '';
  String _picture = '';

  factory UserInfo() {
    return _instance;
  }

  UserInfo._internal();

  String get uid => _uid;

  void setUid(String value) {
    _uid = value;
  }

  String get name => _name;

  void setName(String value) {
    _name = value;
  }

  String get picture => _picture;

  void setPicture(String value) {
    _picture = value;
  }

  void saveUserInfo() {
    UserInfoRepository.instance.flushUserInfo();
  }

  @override
  String toString() {
    return 'UserInfo{'
        '_uid: $_uid, '
        '_name: $_name, '
        '_picture: $_picture'
        '}';
  }
}
