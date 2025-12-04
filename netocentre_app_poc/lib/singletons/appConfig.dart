import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  final log = Logger('AppConfig');
  static final AppConfig _instance = AppConfig._internal();

  String? _userAgent;
  String? _casBaseURL;
  String? _serviceURL;
  String? _uPortalBaseURL;

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  // All the config is loaded from one place : the app does not need to be updated is there is a configuration update
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
      _uPortalBaseURL = data['uPortalBaseURL'];

      log.info('Config was successfully loaded : ${toString()}');
    } else {
      throw Exception(
          'Error while loading config, error code is (${response.statusCode})');
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

  String get serviceURL => getAttribute('_serviceURL', _serviceURL);

  String get uPortalBaseURL => getAttribute('_uPortalBaseURL', _uPortalBaseURL);

  @override
  String toString() {
    return 'AppConfig{ '
        '_userAgent: $_userAgent, '
        '_casBaseURL: $_casBaseURL, '
        '_serviceURL: $_serviceURL, ''
        '_uPortalBaseURL: $_uPortalBaseURL'
        ' }';
  }
}
