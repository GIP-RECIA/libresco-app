import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/repositories/tokenRepository.dart';

class TokenManager {
  final log = Logger('TokenManager');

  static final TokenManager _instance = TokenManager._internal();

  String _id = '';
  String _TGC = '';
  String _JSESSIONID = '';
  String _idPortal = '';

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  String get id => _id;

  void setId(String id) {
    _id = id;
  }

  String get TGC => _TGC;

  void setTGC(String token, {bool flush = false}) {
    _TGC = token;

    if (flush) {
      TokenRepository.instance.flushTokens();
    }
  }

  String get JSESSIONID => _JSESSIONID;

  void setJSESSIONID(String token, {bool flush = false}) {
    _JSESSIONID = token;

    if (flush) {
      TokenRepository.instance.flushTokens();
    }
  }

  String get idPortal => _idPortal;

  void setIdPortal(String value, {bool flush = false}) {
    _idPortal = value;

    if (flush) {
      TokenRepository.instance.flushTokens();
    }
  }

  void reset({bool flush = false}) {
    _TGC = '';
    _JSESSIONID = '';
    _idPortal = '';
    if (flush) {
      TokenRepository.instance.flushTokens();
    }
  }

  @override
  String toString() {
    return 'TokenManager{'
        '_id: $_id, '
        '_TGC: $_TGC, '
        '_JSESSIONID: $_JSESSIONID, '
        '_idPortal: $_idPortal, '
        '}';
  }
}
