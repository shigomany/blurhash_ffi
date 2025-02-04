import 'package:logging/logging.dart';

class BlurhashFFIException implements Exception {
  final String message;
  final Level? level;

  const BlurhashFFIException({
    required this.message,
    this.level = Level.SEVERE,
  });
}
