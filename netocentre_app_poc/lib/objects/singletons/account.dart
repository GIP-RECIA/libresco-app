import 'package:logging/logging.dart';

import 'app_config.dart';

class Account {
  final log = Logger('Account');

  static final Account _instance = Account._internal();

  int? _id;
  String? _domain;

  factory Account() {
    return _instance;
  }

  Account._internal();

  int? get id => _id;

  String get domain {
    if (_domain == '' || _domain == null) {
      return AppConfig().uPortalHost;
    }
    return _domain!;
  }

  void setDomain(String value) {
    _domain = value;
  }

  String getBaseUrl(){
    if (_domain == '' || _domain == null) {
      return AppConfig().uPortalBaseURL;
    }
    return 'https://$_domain';
  }

  void setId(int id) {
    _id = id;
  }

  void clear() {
    _id = null;
  }

  @override
  String toString() {
    return 'Account{'
        '_id: $_id, '
        '}';
  }
}
