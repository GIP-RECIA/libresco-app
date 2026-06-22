import 'package:logging/logging.dart';
import 'package:libresco/repositories/session_repository.dart';

class Session {
  final log = Logger('Session');

  static final Session _instance = Session._internal();

  String _CASSessionCookie = '';
  String _PortalSessionCookie = '';
  String _IDPortalCookie = '';
  String _DNMASessionCookie = '';
  String _IDDNMACookie = '';

  factory Session() {
    return _instance;
  }

  Session._internal();

  String get CASSessionCookie => _CASSessionCookie;

  void setCASSessionCookie(String token) {
    _CASSessionCookie = token;
  }

  String get PortalSessionCookie => _PortalSessionCookie;

  void setPortalSessionCookie(String token) {
    _PortalSessionCookie = token;
  }

  String get IDPortalCookie => _IDPortalCookie;

  void setIDportalCookie(String value) {
    _IDPortalCookie = value;
  }

  String get DNMASessionCookie => _DNMASessionCookie;

  void setDNMASessionCookie(String value) {
    _DNMASessionCookie = value;
  }

  String get IDDNMACookie => _IDDNMACookie;

  void setIDDNMACookie(String value) {
    _IDDNMACookie = value;
  }

  Map<String, Object?> mapForDatabase() {
    var map = <String, Object?>{
      'CASSessionCookie': _CASSessionCookie,
      'PortalSessionCookie': _PortalSessionCookie,
      'IDPortalCookie': _IDPortalCookie,
    };
    return map;
  }

  void loadFromDatabase(Map<String, Object?> map) {
    _CASSessionCookie = (map['CASSessionCookie'] ?? '') as String;
    _PortalSessionCookie = (map['PortalSessionCookie'] ?? '') as String;
    _IDPortalCookie = (map['IDPortalCookie'] ?? '') as String;
  }

  void persist() {
    SessionRepository.instance.flush();
  }

  void clear({bool persist = false}) {
    _CASSessionCookie = '';
    _PortalSessionCookie = '';
    _IDPortalCookie = '';
    _DNMASessionCookie = '';
    _IDDNMACookie = '';
    if (persist) {
      this.persist();
    }
  }

  @override
  String toString() {
    return 'Session{'
        '_CASSessionCookie: $_CASSessionCookie, '
        '_PortalSessionCookie: $_PortalSessionCookie, '
        '_IDPortalCookie: $_IDPortalCookie, '
        '_DNMASessionCookie: $_DNMASessionCookie, '
        '_IDDNMACookie: $_IDDNMACookie, '
        '}';
  }
}
