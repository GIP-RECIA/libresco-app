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

import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider instance = DatabaseProvider._();

  static final String tableName = 'user_data';

  Database? _database;

  Future<Database> get db async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final storage = FlutterSecureStorage();
    String? key = await storage.read(key: 'libresco_db_key');
    if (key == null) {
      key = generateRandomKey();
      await storage.write(key: 'libresco_db_key', value: key);
    }

    final path = join(await getDatabasesPath(), 'libresco.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            CASSessionCookie VARCHAR(255),
            PortalSessionCookie VARCHAR(255),
            IDPortalCookie VARCHAR(255),
            uid VARCHAR(255),
            name VARCHAR(255),
            picture VARCHAR(255),
            currentEtabName VARCHAR(255),
            domain VARCHAR(255)
          );
        ''');
      },
      onDowngrade: onDatabaseDowngradeDelete,
      password: key,
    );
  }

  String generateRandomKey({int length = 32}) {
    final secureRandom = Random.secure();
    final values = List<int>.generate(length, (_) => secureRandom.nextInt(256));
    return base64UrlEncode(values);
  }
}
