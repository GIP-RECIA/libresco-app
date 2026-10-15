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

import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrashReporter {

  final logger = Logger('CrashReporter');

  static const String _consentKey = 'crashlytics_consent';

  static final CrashReporter _instance = CrashReporter._internal();

  factory CrashReporter() {
    return _instance;
  }

  CrashReporter._internal();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  bool? _consent;
  bool? get consent => _consent;

  /// Load consent from preferences
  Future<bool?> loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    _consent = prefs.getBool(_consentKey);
    return _consent;
  }

  /// Set consent in preferences
  Future<void> setConsent(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, accepted);
    _consent = accepted;
  }

  Future<void> refreshConsent() async{
    // Pour être sûr, on désactive la collecte par défaut
    await _crashlytics.setCrashlyticsCollectionEnabled(false);
    // On charge le consenement enregistré
    await loadConsent();
    if (_consent == true) {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
    }
    logger.info('Crashlytics enabled: ''${FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled}',);
  }

  Future<void> init() async {
    FlutterError.onError = (details) {
      if (_consent == true) {
        _crashlytics.recordError(
          details.exception,
          details.stack,
          fatal: true,
        );
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (_consent == true) {
        _crashlytics.recordError(
          error,
          stack,
          fatal: true,
        );
      }
      return true;
    };
  }

  Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
    String? reason,
  }) async {
    if (_consent == true) {
      await _crashlytics.recordError(
        error,
        stack,
        fatal: fatal,
        reason: reason,
      );
    }
  }

  Future<void> log(String message) {
    return _crashlytics.log(message);
  }

  Future<void> setUserId(String id) async {
    await _crashlytics.setUserIdentifier(id);
  }

  Future<void> setContext(
    String key,
    Object value,
  ) async {
    await _crashlytics.setCustomKey(key, value);
  }
}
