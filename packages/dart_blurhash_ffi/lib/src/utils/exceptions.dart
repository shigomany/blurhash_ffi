/// {@template src.utils.exceptions.BlurhashFfiException}
/// General exception for errors that occur during BlurHash methods.
/// {@endtemplate}
class BlurhashFfiException implements Exception {
  /// {@macro src.utils.exceptions.BlurhashFfiException}
  const BlurhashFfiException({
    required this.message,
  });

  /// Excpetion message.
  final String message;
}
