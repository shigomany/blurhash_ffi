import 'dart:io';
import 'dart:typed_data';

import 'package:dart_blurhash_ffi/dart_blurhash_ffi.dart';
import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
  late final Uint8List fileBytes;
  late final Image image;

  setUp(() {
    fileBytes = File('assets/test1.jpg').readAsBytesSync();
    final decodedImage = decodeImage(fileBytes);

    if (decodedImage == null) {
      throw Exception('Failed to decode image');
    }

    image = decodedImage.convert(format: Format.uint8, numChannels: 4);
  });

  group('Encode', () {
    test('Common call', () {
      final bytes = image.buffer.asUint8List();
      final encoded = BlurhashFFI.encode(
        bytes,
        width: image.width,
        height: image.height,
      );

      expect('LGF5]+Yk^6#M@-5c,1J5@[or[Q6.', encoded);
    });
  });
}
