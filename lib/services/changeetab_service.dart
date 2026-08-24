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

import 'package:http/http.dart' as http;
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:logging/logging.dart';

class ChangeEtabService {
  final log = Logger('ChangeEtabService');

  ChangeEtabService._privateConstructor();

  static final ChangeEtabService _instance = ChangeEtabService._privateConstructor();

  static ChangeEtabService get instance => _instance;

  Future<bool> changeEtab(String token, String siren) async {
    final url = "https://${Account().domain}${AppConfig().paramEtabContextPath}/changeetab/api/$siren";
    log.fine("Changing etab with url $url");
    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode != 200) {
      return false;
    }
    return true;
  }
}
