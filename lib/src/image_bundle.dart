import 'dart:typed_data';

class ImageBundle {
  /// The height of the image in pixels.
  final int height;

  /// The width of the image in pixels.
  final int width;

  /// The number of bytes in a single row of the image.
  final int rowStride;

  /// The RGB bytes of the image.
  final Uint8List rgbBytes;

  /// The number of components on X axis.
  ///
  /// Typically ranges between 1 and 9. A higher value means higher level of detail.
  final int componentX;

  /// The number of components on Y axis.
  ///
  /// Typically ranges between 1 and 9. A higher value means higher level of detail.
  final int componentY;

  const ImageBundle({
    required this.height,
    required this.width,
    required this.rowStride,
    required this.rgbBytes,
    required this.componentX,
    required this.componentY,
  });

  int get numChannels => rowStride ~/ width;

  @override
  String toString() {
    return 'ImageBundle(height: $height, width: $width, rowStride: $rowStride, rgbBytes: $rgbBytes, componentX: $componentX, componentY: $componentY)';
  }

  ImageBundle copyWith({
    int? height,
    int? width,
    int? rowStride,
    Uint8List? rgbBytes,
    int? componentX,
    int? componentY,
  }) {
    return ImageBundle(
      height: height ?? this.height,
      width: width ?? this.width,
      rowStride: rowStride ?? this.rowStride,
      rgbBytes: rgbBytes ?? this.rgbBytes,
      componentX: componentX ?? this.componentX,
      componentY: componentY ?? this.componentY,
    );
  }

  @override
  bool operator ==(covariant ImageBundle other) {
    if (identical(this, other)) return true;

    return other.height == height &&
        other.width == width &&
        other.rowStride == rowStride &&
        other.rgbBytes == rgbBytes &&
        other.componentX == componentX &&
        other.componentY == componentY;
  }

  @override
  int get hashCode {
    return height.hashCode ^
        width.hashCode ^
        rowStride.hashCode ^
        rgbBytes.hashCode ^
        componentX.hashCode ^
        componentY.hashCode;
  }
}
