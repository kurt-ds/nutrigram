import 'dart:developer' as developer;

class Logger {
  // ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _cyan = '\x1B[36m';
  static const String _magenta = '\x1B[35m';

  static void info(String message, {String? tag}) {
    developer.log(
      '$_blue$message$_reset',
      name: tag ?? 'INFO',
      time: DateTime.now(),
      error: null,
      stackTrace: null,
      level: 800,
    );
  }

  static void debug(String message, {String? tag}) {
    developer.log(
      '$_cyan$message$_reset',
      name: tag ?? 'DEBUG',
      time: DateTime.now(),
      error: null,
      stackTrace: null,
      level: 500,
    );
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      '$_yellow$message$_reset',
      name: tag ?? 'WARNING',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      '$_red$message$_reset',
      name: tag ?? 'ERROR',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static void camera(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      '$_magenta$message$_reset',
      name: tag ?? 'CAMERA',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 700,
    );
  }

  static void image(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      '$_green$message$_reset',
      name: tag ?? 'IMAGE',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 600,
    );
  }
} 