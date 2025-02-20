// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'blurhash.dart';

/// {@template src.codec.BlurhashFfiCodec}
/// Codec for encoding/decoding blurhash string.
/// {@endtemplate}
class BlurhashFfiCodec extends Codec<Uint8List, String> {
  /// {@macro src.codec.BlurhashFfiCodec}
  const BlurhashFfiCodec();

  @override
  Converter<String, Uint8List> get decoder => BlurhashFfiDecoder();

  @override
  Converter<Uint8List, String> get encoder => BlurhashFfiEncoder();
}

/// {@template blurhash_ffi_decoder}
/// Converter for decoding a blurhash string into pixels data.
///
/// Converts blurhash string to [Uint8List] containing decoded pixel data in RGBA8 format. Allows
/// configuring output width/height and punch factor through constructor parameters.
/// {@endtemplate}
class BlurhashFfiDecoder extends Converter<String, Uint8List> {
  /// {@macro blurhash_ffi_decoder}
  const BlurhashFfiDecoder({
    this.width = 32,
    this.height = 32,
    this.punch = 1,
  });

  /// The width of the decoded image
  final int width;

  /// The height of the decoded image
  final int height;

  /// The punch value adjusts contrast - default 1.0
  final int punch;

  @override
  Uint8List convert(String input) {
    return BlurhashFFI.decode(
      input,
      width: width,
      height: height,
      punch: punch,
    );
  }
}

/// {@template blurhash_ffi_encoder}
/// Converter for encoding pixel data into a blurhash string.
///
/// Takes [Uint8List] of pixel data and encodes it to blurhash string format.
/// Component values control the level of detail in encoding.
/// {@endtemplate}
class BlurhashFfiEncoder extends Converter<Uint8List, String> {
  /// {@macro blurhash_ffi_encoder}
  const BlurhashFfiEncoder({
    this.componentX = 4,
    this.componentY = 4,
  });

  /// Number of components on the X axis
  final int componentX;

  /// Number of components on the Y axis
  final int componentY;

  @override
  String convert(Uint8List input) {
    return BlurhashFFI.encode(
      input,
      componentX: componentX,
      componentY: componentY,
    );
  }
}
