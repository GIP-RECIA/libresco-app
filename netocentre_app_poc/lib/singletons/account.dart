import 'package:logging/logging.dart';

class Account {
  final log = Logger('Session');

  static final Account _instance = Account._internal();

  String _id = '';

  factory Account() {
    return _instance;
  }

  Account._internal();

  String get id => _id;

  void setId(String id) {
    _id = id;
  }

  @override
  String toString() {
    return 'Account{'
        '_id: $_id, '
        '}';
  }
}
