import 'package:logging/logging.dart';

class Account {
  final log = Logger('Account');

  static final Account _instance = Account._internal();

  int? _id;

  factory Account() {
    return _instance;
  }

  Account._internal();

  int? get id => _id;

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
