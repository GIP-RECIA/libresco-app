import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/repositories/session_repository.dart';

class Session {
  final log = Logger('Session');

  static final Session _instance = Session._internal();

  String _TGC = '';
  String _PortalSessionCookie = '';
  String _idPortal = '';

  factory Session() {
    return _instance;
  }

  Session._internal();

  String get TGC => _TGC;

  void setTGC(String token, {bool flush = false}) {
    _TGC = token;

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

  String get idPortal => _idPortal;

  void setIdPortal(String value, {bool flush = false}) {
    _idPortal = value;

    if (flush) {
      SessionRepository.instance.flushTokens();
    }
  }

  void reset({bool flush = false}) {
    _TGC = '';
    _PortalSessionCookie = '';
    _idPortal = '';
    if (flush) {
      SessionRepository.instance.flushTokens();
    }
  }

  @override
  String toString() {
    return 'Session{'
        '_TGC: $_TGC, '
        '_PortalSessionCookie: $_PortalSessionCookie, '
        '_idPortal: $_idPortal, '
        '}';
  }
}
