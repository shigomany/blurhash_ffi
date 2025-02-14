@ffi.DefaultAsset('package:blurhash_ffi/blurhash_ffi')
library rust;

import 'dart:ffi' as ffi;
import 'dart:typed_data';

@ffi.Native<
    ffi.Pointer<ffi.Char> Function(
      ffi.Int32,
      ffi.Int32,
      ffi.Int32,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Int32,
    )>(symbol: 'blurhash_encode')
external ffi.Pointer<ffi.Char> blurhashEncode(
  int componentsX,
  int componentsY,
  int width,
  int height,
  Uint8List rgbaImage,
  int rgbaImageLen,
);

@ffi.Native<
    ffi.Pointer<ffi.Uint8> Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Int32,
      ffi.Int32,
      ffi.Int32,
      ffi.Float,
    )>(symbol: 'blurhash_decode')
external Uint8List blurhashDecode(
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
