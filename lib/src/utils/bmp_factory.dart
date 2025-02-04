import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

class BmpFactory {
  final Uint8List pixels;
  final int width;
  final int height;
  final int channels;

  const BmpFactory.fromBuffer({
    required this.pixels,
    required this.width,
    required this.height,
    required this.channels,
  });

  Future<ui.Image> createImage() async {
    final size = (width * height * channels) + 122;
    final bmp = Uint8List(size);
    final ByteData header = bmp.buffer.asByteData();

    header.setUint8(0x0, 0x42);
    header.setUint8(0x1, 0x4d);
    header.setInt32(0x2, size, Endian.little);
    header.setInt32(0xa, 122, Endian.little);
    header.setUint32(0xe, 108, Endian.little);
    header.setUint32(0x12, width, Endian.little);
    header.setUint32(0x16, -height, Endian.little);
    header.setUint16(0x1a, 1, Endian.little);
    header.setUint32(0x1c, 32, Endian.little);
    header.setUint32(0x1e, channels, Endian.little);
    header.setUint32(0x22, width * height * channels, Endian.little);
    header.setUint32(0x36, 0x000000ff, Endian.little);
    header.setUint32(0x3a, 0x0000ff00, Endian.little);
    header.setUint32(0x3e, 0x00ff0000, Endian.little);
    header.setUint32(0x42, 0xff000000, Endian.little);

    bmp.setRange(122, size, pixels);

    final codec = await ui.instantiateImageCodec(bmp);
    final frame = await codec.getNextFrame();

    return frame.image;
  }
}
