import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

typedef LogMessageCallback = void Function(LogRecord record);

final Logger packageLogger = Logger('blurhash_ffi');

/// Configures the logging system with custom settings and handlers.
///
/// This function sets up the logger with specific configurations and handlers for log messages.
/// It allows customization of how log messages are processed and displayed.
///
/// Parameters:
/// - [logger]: Optional custom logger instance. If not provided, uses the default logger.
/// - [onLog]: Optional callback function to handle log records. If not provided,
///   uses a default handler that prints colored log messages to the console.
///
/// The default log handler implements color-coding for different log levels:
/// * Green for INFO level
/// * Yellow for WARNING level
/// * Red for SEVERE level
/// * Magenta for SHOUT level
/// * Cyan for CONFIG level
///
/// Example:
///
/// ```dart
/// configureLogger(
///   logger: customLogger,
///   onLog: (record) => print(record.message),
/// );
/// ```
void configureLogger({
  Logger? logger,
  LogMessageCallback? onLog,
}) {
  final ownLogger = logger ?? packageLogger;
  // Set the log level (You can adjust this as needed)
  ownLogger.level = Level.ALL;
  if (onLog != null) {
    ownLogger.onRecord.listen(onLog);
  } else {
    ownLogger.onRecord.listen((record) {
      // Define ANSI escape code sequences for different log levels and colors
      final Map<Level, String> colorMap = {
        Level.INFO: '\x1B[32m', // Green for INFO
        Level.WARNING: '\x1B[33m', // Yellow for WARNING
        Level.SEVERE: '\x1B[31m', // Red for SEVERE
        Level.SHOUT: '\x1B[35m', // Magenta for SHOUT (if used)
        Level.CONFIG: '\x1B[36m', // Cyan for CONFIG (if used)
        // Add more colors for other log levels if needed
      };

      // Reset color at the end of the log message
      const String colorReset = '\x1B[0m';

      // Get the color code for the log level
      final String colorCode = colorMap[record.level] ?? '';

      // You can customize the log message format here, including color
      debugPrint(
          '$colorCode${record.level.name}: ${record.time}: ${record.message}$colorReset');
    });
  }
}
