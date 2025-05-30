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
    print('$_blue[INFO]${tag != null ? ' [$tag]' : ''} $message$_reset');
    developer.log(
      message,
      name: tag ?? 'INFO',
      time: DateTime.now(),
      error: null,
      stackTrace: null,
      level: 800,
    );
  }

  static void debug(String message, {String? tag}) {
    print('$_cyan[DEBUG]${tag != null ? ' [$tag]' : ''} $message$_reset');
    developer.log(
      message,
      name: tag ?? 'DEBUG',
      time: DateTime.now(),
      error: null,
      stackTrace: null,
      level: 500,
    );
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    print('$_yellow[WARNING]${tag != null ? ' [$tag]' : ''} $message$_reset');
    if (error != null) {
      print('$_yellow[ERROR] $error$_reset');
    }
    developer.log(
      message,
      name: tag ?? 'WARNING',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    print('$_red[ERROR]${tag != null ? ' [$tag]' : ''} $message$_reset');
    if (error != null) {
      print('$_red[ERROR] $error$_reset');
    }
    developer.log(
      message,
      name: tag ?? 'ERROR',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static void camera(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    print('$_magenta[CAMERA]${tag != null ? ' [$tag]' : ''} $message$_reset');
    if (error != null) {
      print('$_magenta[ERROR] $error$_reset');
    }
    developer.log(
      message,
      name: tag ?? 'CAMERA',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 700,
    );
  }

  static void image(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    print('$_green[IMAGE]${tag != null ? ' [$tag]' : ''} $message$_reset');
    if (error != null) {
      print('$_green[ERROR] $error$_reset');
    }
    developer.log(
      message,
      name: tag ?? 'IMAGE',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 600,
    );
  }
} 