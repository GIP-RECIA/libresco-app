import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/repositories/session_repository.dart';

class Session {
  final log = Logger('Session');

  static final Session _instance = Session._internal();

  String _CASSessionCookie = '';
  String _PortalSessionCookie = '';
  String _IDPortalCookie = '';

  factory Session() {
    return _instance;
  }

  Session._internal();

  String get CASSessionCookie => _CASSessionCookie;

  void setCASSessionCookie(String token, {bool flush = false}) {
    _CASSessionCookie = token;

    if (flush) {
      persist();
    }
  }

  String get PortalSessionCookie => _PortalSessionCookie;

  void setPortalSessionCookie(String token, {bool flush = false}) {
    _PortalSessionCookie = token;

    if (flush) {
      persist();
    }
  }

  String get IDPortalCookie => _IDPortalCookie;

  void setIDportalCookie(String value, {bool flush = false}) {
    _IDPortalCookie = value;

    if (flush) {
      persist();
    }
  }

  void reset({bool flush = false}) {
    clear();
    if (flush) {
      persist();
    }
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'CASSessionCookie': _CASSessionCookie,
      'PortalSessionCookie': _PortalSessionCookie,
      'IDPortalCookie': _IDPortalCookie,
    };
    return map;
  }

  void fromMap(Map<String, Object?> map) {
    _CASSessionCookie = (map['CASSessionCookie'] ?? '') as String;
    _PortalSessionCookie = (map['PortalSessionCookie'] ?? '') as String;
    _IDPortalCookie = (map['IDPortalCookie'] ?? '') as String;
  }

  void persist() {
    SessionRepository.instance.flush();
  }

  void clear() {
    _CASSessionCookie = '';
    _PortalSessionCookie = '';
    _IDPortalCookie = '';
  }

  @override
  String toString() {
    return 'Session{'
        '_CASSessionCookie: $_CASSessionCookie, '
        '_PortalSessionCookie: $_PortalSessionCookie, '
        '_IDPortalCookie: $_IDPortalCookie, '
        '}';
  }
}
