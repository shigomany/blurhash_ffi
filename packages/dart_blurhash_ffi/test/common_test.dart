import 'dart:io';
import 'dart:typed_data';

import 'package:dart_blurhash_ffi/dart_blurhash_ffi.dart';
import 'package:test/test.dart';

void main() {
  late final Uint8List clearedImageBytes;
  late final Uint8List blurhashImageBytes;
  setUpAll(() {
    clearedImageBytes = File('assets/test1.webp').readAsBytesSync();
    blurhashImageBytes = File('assets/encoded_test1.bin').readAsBytesSync();
  });

  group('Common. ', () {
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
        width: 32,
        height: 32,
      );

      // Store
      // File('assets/encoded_test1.bin').writeAsBytesSync(decoded);

      expect(decoded, blurhashImageBytes);
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
