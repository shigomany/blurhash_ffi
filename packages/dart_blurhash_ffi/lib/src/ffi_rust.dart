@ffi.DefaultAsset('package:dart_blurhash_ffi/blurhash_ffi')
library;

import 'dart:ffi' as ffi;

@ffi.Native(symbol: 'WrappedEncodeResult')
final class WrappedEncodeResult extends ffi.Struct {
  @ffi.Bool()
  external bool get success;

  external ffi.Pointer<ffi.Char> get data;

  external ffi.Pointer<ffi.Char> get error;
}

@ffi.Native(symbol: 'WrappedDecodeResult')
final class WrappedDecodeResult extends ffi.Struct {
  @ffi.Bool()
  external bool get success;

  external ffi.Pointer<ffi.Uint8> get data;

  external ffi.Pointer<ffi.Char> get error;
}

@ffi.Native<
    WrappedEncodeResult Function(
      ffi.Int32,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Int32,
    )>(symbol: 'blurhash_encode')
external WrappedEncodeResult blurhashEncode(
  int componentsX,
  int componentsY,
  ffi.Pointer<ffi.Uint8> rgbaImage,
  int rgbaImageLen,
);

@ffi.Native<
    WrappedDecodeResult Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Int32,
      ffi.Int32,
      ffi.Int32,
      ffi.Float,
    )>(symbol: 'blurhash_decode')
external WrappedDecodeResult blurhashDecode(
  ffi.Pointer<ffi.Uint8> blurhash,
  int blurhashLen,
  int width,
  int height,
  double punch,
);

@ffi.Native<
    ffi.Bool Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Int32,
    )>(symbol: 'is_valid_blurhash')
external bool isValidBlurhash(
  ffi.Pointer<ffi.Uint8> blurhash,
  int blurhashLen,
);

@ffi.Native<
    ffi.Bool Function(
      ffi.Pointer<ffi.Char>,
    )>(symbol: 'free_string')
external bool freeString(
  ffi.Pointer<ffi.Char> str,
);

@ffi.Native<
    ffi.Bool Function(
      ffi.Pointer<ffi.Uint8>,
    )>(symbol: 'free_bytes')
external bool freeBytes(
  ffi.Pointer<ffi.Uint8> bytes,
);
