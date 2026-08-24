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

import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/user_info.dart';
import 'package:libresco/repositories/database_provider.dart';
import 'package:logging/logging.dart';

class UserInfoRepository {
  final log = Logger('UserInfoRepository');

  UserInfoRepository._privateConstructor();

  static final UserInfoRepository _instance = UserInfoRepository._privateConstructor();

  static UserInfoRepository get instance => _instance;

  final tableName = DatabaseProvider.tableName;

  Future<void> update() async {
    final db = await DatabaseProvider.instance.db;
    await db.update(
      tableName,
      UserInfo().mapForDatabase(),
      where: 'id = ?',
      whereArgs: [Account().id],
    );
    Account().setDomain(UserInfo().domain);
    log.fine('Update in database : ${UserInfo().toString()}');
  }
}
