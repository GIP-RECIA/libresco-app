import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/repositories/SessionRepository.dart';

class Session {
  final log = Logger('Session');

  static final Session _instance = Session._internal();

  String _TGC = '';
  String _JSESSIONID = '';
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

  String get JSESSIONID => _JSESSIONID;

  void setJSESSIONID(String token, {bool flush = false}) {
    _JSESSIONID = token;

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
    _JSESSIONID = '';
    _idPortal = '';
    if (flush) {
      SessionRepository.instance.flushTokens();
    }
  }

  @override
  String toString() {
    return 'Session{'
        '_TGC: $_TGC, '
        '_JSESSIONID: $_JSESSIONID, '
        '_idPortal: $_idPortal, '
        '}';
  }
}
