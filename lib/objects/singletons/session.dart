// Copyright (C) 2023 GIP-RECIA, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:libresco/repositories/session_repository.dart';

import '../../utils/sanitizer.dart';

class Session {
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
        '_CASSessionCookie: ${sanitize(_CASSessionCookie, visibleCharacters: 3)}, '
        '_PortalSessionCookie: ${sanitize(_PortalSessionCookie, visibleCharacters: 3)}, '
        '_IDPortalCookie: ${sanitize(_IDPortalCookie, visibleCharacters: 3)}, '
        '_DNMASessionCookie: ${sanitize(_DNMASessionCookie, visibleCharacters: 3)}, '
        '_IDDNMACookie: ${sanitize(_IDDNMACookie, visibleCharacters: 3)}, '
        '}';
  }
}
