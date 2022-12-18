import 'dart:developer' as dev;

class Logger {
  static const minLevel = 5;
  final String namespace;
  const Logger(this.namespace);

  static const String reset = "\x1b[0m";
  static const String bright = "\x1b[1m";
  static const String red = "\x1b[31m";
  static const String green = "\x1b[32m";
  static const String yellow = "\x1b[33m";
  static const String blue = "\x1b[34m";
  static const String bGblack = "\x1b[40m";

  void e(String message) => _log('ERROR', 1, message, red);
  void w(String message) => _log('WARNING', 2, message, yellow);
  void i(String message) => _log('INFO', 3, message, bGblack);
  void d(String message) => _log('DEBUG', 4, message, reset);
  void v(String message) => _log('VERBOSE', 5, message, reset);

  void _log(String prefix, int level, String message, String color) {
    dev.log(
      '$color$prefix:$message',
      level: level,
      name: namespace,
    );
  }
}
