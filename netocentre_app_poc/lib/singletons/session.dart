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
      SessionRepository.instance.flushTokens();
    }
  }

  String get PortalSessionCookie => _PortalSessionCookie;

  void setPortalSessionCookie(String token, {bool flush = false}) {
    _PortalSessionCookie = token;

    if (flush) {
      SessionRepository.instance.flushTokens();
    }
  }

  String get IDPortalCookie => _IDPortalCookie;

  void setIDportalCookie(String value, {bool flush = false}) {
    _IDPortalCookie = value;

    if (flush) {
      SessionRepository.instance.flushTokens();
    }
  }

  void reset({bool flush = false}) {
    _CASSessionCookie = '';
    _PortalSessionCookie = '';
    _IDPortalCookie = '';
    if (flush) {
      SessionRepository.instance.flushTokens();
    }
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
