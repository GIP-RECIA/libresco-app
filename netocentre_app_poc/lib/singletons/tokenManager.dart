import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/repositories/tokenRepository.dart';

class TokenManager {

  final log = Logger('TokenManager');
  static final TokenManager _instance = TokenManager._internal();
  String _TGT = "";
  String _JSESSIONID = "";
  String _idPortal = "";

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  String get TGT => _TGT;

  void setTGT(String token, {bool flush = false}) {
    _TGT = token;

    if(flush){
      TokenRepository().flushTokens();
    }
  }

  String get JSESSIONID => _JSESSIONID;

  void setJSESSIONID(String token, {bool flush = false}) {
    _JSESSIONID = token;

    if(flush){
      TokenRepository().flushTokens();
    }
  }


  String get idPortal => _idPortal;

  void setIdPortal(String value, {bool flush = false}) {
    _idPortal = value;

    if(flush){
      TokenRepository().flushTokens();
    }
  }

  void reset({bool flush = false}) {
    _TGT = "";
    _JSESSIONID = "";
    _idPortal = "";
    if(flush){
      TokenRepository().flushTokens();
    }
  }

  @override
  String toString() {
    return 'TokenManager{_TGT: $_TGT, _JSESSIONID: $_JSESSIONID, _idPortal: $_idPortal}';
  }
}