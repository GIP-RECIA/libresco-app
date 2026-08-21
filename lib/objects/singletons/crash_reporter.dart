import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';

class CrashReporter {
  static final CrashReporter _instance = CrashReporter._internal();

  factory CrashReporter() {
    return _instance;
  }

  CrashReporter._internal();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  Future<void> init() async {
    FlutterError.onError = (details) {
      _crashlytics.recordError(
        details.exception,
        details.stack,
        fatal: true,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(
        error,
        stack,
        fatal: true,
      );
      return true;
    };
  }

  Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
    String? reason,
  }) async {
    await _crashlytics.recordError(
      error,
      stack,
      fatal: fatal,
      reason: reason,
    );
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
