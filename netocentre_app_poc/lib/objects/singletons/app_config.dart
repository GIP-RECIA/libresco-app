import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  final log = Logger('AppConfig');
  static final AppConfig _instance = AppConfig._internal();

  String? _userAgent;
  String? _casBaseURL;
  String? _serviceURL;
  String _idpIdQueryParam = 'idpId';
  String _portalCookieName = 'JSESSIONID';
  String _portalIDCookieName = 'clusterIDPortail';
  String _casCookieName = 'TGC';
  String? _uPortalBaseURL;
  String? _staticsPath;
  String _paramEtabContextPath = "/paramuseretab";
  Map<String,String> _externalServices = {'PRONOTE' : 'pronote://'};
  Map<int,Color> categoryIdToColor = {365 : Color.fromRGBO(171, 71, 188, 1),
    364 : Color.fromRGBO(38, 198, 218, 1), 363 : Color.fromRGBO(255, 172, 47, 1),
    362 : Color.fromRGBO(236, 64, 122, 1), 361 : Color.fromRGBO(87, 71, 188, 1),
    360 : Color.fromRGBO(102, 187, 106, 1)};
  Map<int,String> categoryIdToName = {365 : "Services RG & Gestion",
    364 : "Services Citoyens & Territoriaux", 363 : "Apprentissage & Suivi",
    362 : "Administration & Support", 361 : "Communication & Collaboration",
    360 : "Documents & Ressources numériques"};
  bool _cache = true;

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  // All the config is loaded from one place :
  // the app does not need to be updated is there is a configuration update
  Future<void> loadConfig() async {
    log.fine('Generating user agent');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String version = packageInfo.version;
    String plateform = Platform.operatingSystem;
    _userAgent = '$appName/$version ($plateform)';
    log.fine('User agent ${_userAgent!} will be used for requests');

    log.fine('Requesting config');
    final response = await http.get(
      Uri.parse('https://lycees.test.recia.dev/commun/app-mobile/conf.json'),
    );
    if (response.statusCode == 200) {
      log.fine('Got an 200 answer for config. Decoding json...');
      final data = jsonDecode(response.body);
      _casBaseURL = data['casBaseURL'];
      _serviceURL = data['serviceURL'];
      _idpIdQueryParam = data['idpIdQueryParam'];
      _uPortalBaseURL = data['uPortalBaseURL'];
      _staticsPath = data['_staticsPath'];
      _cache = data['cache'];

      log.info('Config was successfully loaded : ${toString()}');
    } else {
      throw Exception(
        'Error while loading config, error code is (${response.statusCode})',
      );
    }
  }

  dynamic getAttribute(String name, dynamic value) {
    if (value == null) {
      throw Exception('$name is not defined. Is the configuration loaded ?');
    }
    return value;
  }

  String get userAgent => getAttribute('_userAgent', _userAgent);

  String get casBaseURL => getAttribute('_casBaseURL', _casBaseURL);

  String get casHost => casBaseURL.replaceFirst(RegExp(r'^https?://'), '');

  String get serviceURL => getAttribute('_serviceURL', _serviceURL);

  Map<String,String> get externalServices => getAttribute('_externalServices', _externalServices);

  String get idpIdQueryParam =>
      getAttribute('_idpIdQueryParam', _idpIdQueryParam);

  String get portalCookieName =>
      getAttribute('_portalCookieName', _portalCookieName);

  String get portalIDCookieName =>
      getAttribute('_portalIDCookieName', _portalIDCookieName);

  String get casCookieName => getAttribute('_casCookieName', _casCookieName);

  String get uPortalBaseURL => getAttribute('_uPortalBaseURL', _uPortalBaseURL);

  String get uPortalHost =>
      uPortalBaseURL.replaceFirst(RegExp(r'^https?://'), '');

  void setUportalBaseURL(String value) {
    _uPortalBaseURL = value;
  }

  String get paramEtabContextPath =>
      getAttribute('_paramEtabContextPath', _paramEtabContextPath);

  String get staticsPath => getAttribute('_staticsPath', _staticsPath);

  bool get cache => _cache;

  Color getColorFromCategoryId(int id){
    if(!categoryIdToName.containsKey(id)){
      return Colors.grey;
    }
    return categoryIdToColor[id]!;
  }

  String getNameFromCategoryId(int id){
    if(!categoryIdToName.containsKey(id)){
      return "";
    }
    return categoryIdToName[id]!;
  }

  @override
  String toString() {
    return 'AppConfig{'
        '_userAgent: $_userAgent, '
        '_casBaseURL: $_casBaseURL, '
        '_serviceURL: $_serviceURL, '
        '_externalServices: $_externalServices, '
        '_idpIdQueryParam: $_idpIdQueryParam, '
        '_portalCookieName: $_portalCookieName, '
        '_portalIDCookieName: $_portalIDCookieName, '
        '_casCookieName: $_casCookieName, '
        '_uPortalBaseURL: $_uPortalBaseURL, '
        '_staticsBaseURL: $_staticsPath, '
        '_cache: $_cache'
        '}';
  }
}
