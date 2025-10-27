import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class BaseUrl {

  final log = Logger('BaseUrl');
  static final BaseUrl _instance = BaseUrl._internal();

  String? _casBaseURL;
  String? _serviceURL;
  String? _uPortalBaseURL;

  factory BaseUrl() {
    return _instance;
  }

  BaseUrl._internal();

  // All the config is loaded from one place : the app does not need to be updated is there is a configuration update
  Future<void> loadConfig() async {
    log.fine("Requesting config");
    final response = await http.get(Uri.parse('https://lycees.test.recia.dev/commun/app_mobile_conf.json'),);
    if (response.statusCode == 200) {
      log.fine("Got an 200 answer for config. Decoding json...");
      final data = jsonDecode(response.body);
      _casBaseURL = data['casBaseURL'];
      _serviceURL = data['serviceURL'];
      _uPortalBaseURL = data['uPortalBaseURL'];
      log.info("Config was successfully loaded with values _casBaseURL=$_casBaseURL, _serviceURL=$_serviceURL and _uPortalBaseURL=$_uPortalBaseURL");
    } else {
      throw Exception('Error while loading config, error code is (${response.statusCode})');
    }
  }

  String get casBaseURL {
    if (_casBaseURL == null) {
      throw Exception("_casBaseURL is not defined. Is the configuration loaded ?");
    }
    return _casBaseURL!;
  }

  String get serviceURL {
    if (_serviceURL == null) {
      throw Exception("_serviceURL is not defined. Is the configuration loaded ?");
    }
    return _serviceURL!;
  }

  String get uPortalBaseURL {
    if (_uPortalBaseURL == null) {
      throw Exception("_uPortalBaseURL is not defined. Is the configuration loaded ?");
    }
    return _uPortalBaseURL!;
  }
}