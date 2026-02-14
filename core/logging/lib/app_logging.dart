library app_logging;

import 'package:flutter/foundation.dart';

/// Release-safe logging. In release, only [w] and [e] emit (to avoid PII/verbosity).
/// Configure [enableDebug] at app startup to toggle debug logs in profile/debug.
class AppLog {
  AppLog(this.tag, {bool? enableDebug}) : _enableDebug = enableDebug ?? kDebugMode;

  final String tag;
  final bool _enableDebug;

  void d(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enableDebug) {
      _emit('D', message, error, stackTrace);
    }
  }

  void w(String message, [Object? error, StackTrace? stackTrace]) {
    _emit('W', message, error, stackTrace);
  }

  void e(String message, [Object? error, StackTrace? stackTrace]) {
    _emit('E', message, error, stackTrace);
  }

  void _emit(String level, String message, [Object? error, StackTrace? stackTrace]) {
    // In release, prefer structured/crash reporting over debugPrint.
    // debugPrint is stripped in release for Flutter; use accordingly.
    if (kDebugMode) {
      final buf = StringBuffer('[$tag][$level] $message');
      if (error != null) buf.write(' | $error');
      if (stackTrace != null) buf.write('\n$stackTrace');
      debugPrint(buf.toString());
    }
    // TODO: In production, send w/e to Crashlytics or logging backend
  }
}
