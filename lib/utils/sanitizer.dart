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

import 'dart:io';

String sanitize(
  String? value, {
  int visibleCharacters = 0,
}) {
  if (value == null || value.isEmpty) {
    return '';
  }
  if (visibleCharacters <= 0 || value.length <= visibleCharacters) {
    return '*' * value.length;
  }
  return '${value.substring(0, visibleCharacters)}'
      '${'*' * (value.length - visibleCharacters)}';
}

String sanitizeList(
  List<Object?> values, {
  int visibleCharacters = 0,
}) {
  return '[${values.map((value) {
    return sanitize(
      value?.toString(),
      visibleCharacters: visibleCharacters,
    );
  }).join(', ')}]';
}

String sanitizeHeaders(
  HttpHeaders headers, {
  int visibleCharacters = 0,
}) {
  final result = <String, String>{};
  headers.forEach((name, values) {
    final sanitizedValues = <String>[];
    for (final value in values) {
      final sanitizedValue = sanitize(
        value,
        visibleCharacters: visibleCharacters,
      );
      sanitizedValues.add(sanitizedValue);
    }
    result[name] = sanitizedValues.toString();
  });
  return result.toString();
}

String sanitizeLogs(String value) {
  return value.replaceAllMapped(
    RegExp(r'ST-[^\s\]\)]+'),
    (match) => 'ST-******',
  );
}
