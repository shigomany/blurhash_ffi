import 'dart:io';
import 'dart:typed_data';

import 'package:dart_blurhash_ffi/dart_blurhash_ffi.dart';
import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
  late final Uint8List clearedImageBytes;
  late final Uint8List blurhashImageBytes;
  setUpAll(() {
    clearedImageBytes = File('assets/test1.webp').readAsBytesSync();
    blurhashImageBytes = File('assets/encoded_test1.png').readAsBytesSync();
  });

  group('Encode', () {
    test('Valid encoding', () {
      final encoded = BlurhashFFI.encode(clearedImageBytes);
      expect('LGFO~6Yk^6#M@-5c,1Ex@@or[j6o', encoded);
    });

    test('Invalid encoding', () {
      encodeCall() => BlurhashFFI.encode(Uint8List.fromList([1, 2, 3, 4]));

      expect(encodeCall, throwsA(isA<BlurhashFfiException>()));
    });

    test('Valid decoding', () {
      final decoded = BlurhashFFI.decode(
        'LGFO~6Yk^6#M@-5c,1Ex@@or[j6o',
        width: 256,
        height: 256,
      );

      final decodedImage = Image.fromBytes(
        width: 256,
        height: 256,
        bytes: decoded.buffer,
        numChannels: 4,
        format: Format.uint8,
      );
      final pngEncoder = PngEncoder();
      final pngBytes = pngEncoder.encode(decodedImage);

      expect(pngBytes, blurhashImageBytes);
    });

    test('Invalid decoding', () {
      decodeCall() => BlurhashFFI.decode(
            'invalid_blurhash',
            width: 64,
            height: 64,
          );

      expect(decodeCall, throwsA(isA<BlurhashFfiException>()));
    });

    test('Validity check', () {
      final isValid = BlurhashFFI.isValidBlurHash(
        'LGFO~6Yk^6#M@-5c,1Ex@@or[j6o',
      );

      expect(isValid, isTrue);
    });

    test('Check invalid Blurhash', () {
      final isValid = BlurhashFFI.isValidBlurHash(
        'invalud_blurhash',
      );

      expect(isValid, isFalse);
    });
  });
}
