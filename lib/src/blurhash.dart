import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import 'blurhash_ffi_bindings_generated.dart';
import 'image_bundle.dart';

const String _libName = 'blurhash_ffi';

/// Create a neat class to handle all the glue code and expose a nice API.
class BlurhashFFI {
  // singleton class
  static final BlurhashFFI _instance = BlurhashFFI._();

  static final BlurhashFfiBindings _bindings =
      BlurhashFfiBindings(_openDylib());

  factory BlurhashFFI() => _instance;

  BlurhashFFI._();

  /// The dynamic library in which the symbols for [BlurhashFfiBindings] can be found.
  ///
  /// This is specified with [DynamicLibrary] for each platform.
  static DynamicLibrary _openDylib() {
    if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.process();
    }
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('lib$_libName.so');
    }
    if (Platform.isWindows) {
      return DynamicLibrary.open('$_libName.dll');
    }
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }

  /// Checking that current [blurhash] is valid.
  static bool isValidBlurHash(String blurhash) =>
      _instance._isValidBlurHash(blurhash);

  /// Encodes an image into a BlurHash string.
  ///
  /// The [data] parameter __should contain RGBA8 pixel data__ in bytes (each pixel
  /// represented as 4 consecutive bytes: red, green, blue, alpha).
  ///
  /// The [width] and [height] must specify the image dimensions in pixels.
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
  ///   componentX: 5,
  ///   componentY: 4,
  /// );
  /// ```
  static String encode(
    Uint8List data, {
    required int width,
    required int height,
    int componentX = 4,
    int componentY = 3,
  }) {
    return _instance._encodeBlurHash(
      ImageBundle(
        componentX: componentX,
        componentY: componentY,
        rgbBytes: data,
        width: width,
        height: height,
        rowStride: width * 4,
      ),
    );
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
    return _instance._decodeBlurHash(blurhash, width, height, punch);
  }

  bool _isValidBlurHash(String blurhash) {
    final bhptr = blurhash.toNativeUtf8();
    final result =
        _bindings.is_valid_blurhash(bhptr.cast<Uint8>(), blurhash.length);
    malloc.free(bhptr);
    return result;
  }

  Uint8List _decodeBlurHash(
    String hash,
    int width,
    int height,
    int punch,
  ) {
    final ptr = hash.toNativeUtf8().cast<Uint8>();
    return _bindings
        .blurhash_decode(
          ptr,
          hash.length,
          width,
          height,
          punch.toDouble(),
        )
        .asTypedList(width * height * 4);
  }

  String _encodeBlurHash(ImageBundle bundle) {
    final arena = Arena();
    final pointer = arena<Uint8>(bundle.rgbBytes.length);
    for (int i = 0; i < bundle.rgbBytes.length; i++) {
      pointer[i] = bundle.rgbBytes[i];
    }

    final rawValue = _bindings
        .blurhash_encode(
          bundle.componentX,
          bundle.componentY,
          bundle.width,
          bundle.height,
          pointer,
          bundle.rgbBytes.length,
        )
        .cast<Utf8>()
        .toDartString();
    arena.free(pointer);

    return rawValue;
  }
}
