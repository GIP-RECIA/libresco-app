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

  String getBaseUrl() {
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
