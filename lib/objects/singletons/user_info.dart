import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/repositories/user_info_repository.dart';

class UserInfo {
  final log = Logger('UserInfo');

  static final UserInfo _instance = UserInfo._internal();

  String _uid = '';
  String _name = '';
  String _picture = '';
  String _currentEtabName = '';
  String _domain = '';
  List<String> _sirens = [];
  String _currentSiren = '';

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

  String get currentEtabName => _currentEtabName;

  void setCurrentEtabName(String value) {
    _currentEtabName = value;
  }

  String get domain => _domain;

  void setDomain(String value) {
    _domain = value;
  }

  List<String> get sirens => _sirens;

  void setSirens(List<String> value) {
    _sirens = value;
  }

  String get currentSiren => _currentSiren;

  void setCurrentSiren(String value) {
    _currentSiren = value;
  }

  /// Map only the attributes stored in database
  Map<String, Object?> mapForDatabase() {
    var map = <String, Object?>{
      'uid': _uid,
      'name': _name,
      'picture': _picture,
      'currentEtabName': _currentEtabName,
      'domain': _domain,
    };
    return map;
  }

  void update() {
    UserInfoRepository.instance.update();
  }

  void clear() {
    _uid = '';
    _name = '';
    _picture = '';
    _currentEtabName = '';
    _domain = '';
    _sirens = [];
    _currentSiren = '';
  }

  @override
  String toString() {
    return 'UserInfo{'
        '_uid: $_uid, '
        '_name: $_name, '
        '_picture: $_picture'
        '_currentEtabName: $_currentEtabName'
        '_domain: $_domain'
        '_sirens: $_sirens'
        '_currentSiren: $_currentSiren'
        '}';
  }
}
