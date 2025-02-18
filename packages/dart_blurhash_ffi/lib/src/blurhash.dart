import 'dart:ffi';
import 'dart:typed_data';
import 'package:dart_blurhash_ffi/src/ffi_rust.dart';
import 'package:ffi/ffi.dart';

import 'utils/exceptions.dart';

class BlurhashFFI {
  const BlurhashFFI._();

  /// Checking that current [blurhash] is valid.
  static bool isValidBlurHash(String blurhash) {
    final blurhashBytes = blurhash.toNativeUtf8().cast<Uint8>();

    return isValidBlurhash(blurhashBytes, blurhash.length);
  }

  /// Encodes an image into a BlurHash string.
  ///
  /// The [data] parameter __should contain RGBA8 pixel data__ in bytes (each pixel
  /// represented as 4 consecutive bytes: red, green, blue, alpha).
  ///
  /// [componentX] and [componentY] define the number of DCT components to use
  /// in X and Y dimensions respectively (typically between 1-9, default 4x3).
  /// Higher values create more detailed but longer hashes.
  ///
  /// The `rowStride` is automatically calculated as `width * 4` bytes, assuming
  /// 4 bytes per pixel (RGBA format).
  ///
  /// Example:
  /// ```dart
  /// final hash = BlurHash.encode(
  ///   imagePixels,
  ///   width: 128,
  ///   height: 128,
  /// );
  /// ```
  static String encode(
    Uint8List data, {
    int componentX = 4,
    int componentY = 3,
  }) {
    final arena = Arena();
    final pointer = arena.allocate<Uint8>(data.length);

    for (int i = 0; i < data.length; i++) {
      pointer[i] = data[i];
    }

    final wrappedResult = blurhashEncode(
      componentX,
      componentY,
      pointer,
      data.length,
    );

    arena.free(pointer);

    if (!wrappedResult.success) {
      final exceptionMessage = wrappedResult.error.cast<Utf8>().toDartString();
      freeString(wrappedResult.error);

      throw BlurhashFfiException(message: exceptionMessage);
    }

    final blurhashStr = wrappedResult.data.cast<Utf8>().toDartString();
    freeString(wrappedResult.data);

    return blurhashStr;
  }

  /// Decodes a BlurHash string into raw RGBA pixel data.
  ///
  /// The [blurhash] string is decoded into an image with specified [width] and [height]
  /// (default 32x32 pixels). The [punch] parameter controls the contrast intensity of
  /// the decoded image (1 = normal, higher values increase contrast).
  ///
  /// Returns a [Uint8List] containing row-major pixel data where each pixel is represented
  /// by 4 consecutive bytes in RGBA format.
  static Uint8List decode(
    String blurhash, {
    int width = 32,
    int height = 32,
    int punch = 1,
  }) {
    final ptr = blurhash.toNativeUtf8().cast<Uint8>();
    final wrappedResult = blurhashDecode(
      ptr,
      blurhash.length,
      width,
      height,
      punch.toDouble(),
    );

    if (!wrappedResult.success) {
      final exceptionMessage = wrappedResult.error.cast<Utf8>().toDartString();
      freeString(wrappedResult.error);

      throw BlurhashFfiException(message: exceptionMessage);
    }

    final rawBytes = wrappedResult.data.cast<Uint8>();
    // Decode result is always 4 bytes per pixel (RGBA)
    final bytes = rawBytes.asTypedList(width * height * 4);

    return bytes;
  }
}
