import 'dart:async';

import 'package:blurhash_ffi/src/blurhash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'dart:ui' as ui;

import 'exceptions.dart';
import 'image_bundle.dart';
import 'utils/ui_image_factory.dart';

class BlurhashFfiImage extends ImageProvider<BlurhashFfiImage> {
  /// Creates an object that decodes a [blurHash] as an image.
  const BlurhashFfiImage(
    this.blurHash, {
    this.decodingWidth = 32,
    this.decodingHeight = 32,
    this.scale = 1.0,
    this.wrapWithIsolate = true,
  }) : inputImage = null;

  /// Creates an object that encodes the given [inputImage] as a blurHash.
  const BlurhashFfiImage.fromImageProvider(
    this.inputImage, {
    this.decodingWidth = 32,
    this.decodingHeight = 32,
    this.scale = 1.0,
    this.wrapWithIsolate = true,
  }) : blurHash = null;

  /// The image to encode into a blurHash.
  final ImageProvider? inputImage;

  /// The bytes to decode into an image.
  final String? blurHash;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// Decoding definition
  final int decodingWidth;

  /// Decoding definition
  final int decodingHeight;

  /// Wrap every call ([BlurhashFFI.encode] and [BlurhashFFI.decode]) in isolate (Used [compute]).
  final bool wrapWithIsolate;

  @override
  Future<BlurhashFfiImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<BlurhashFfiImage>(this);

  @override
  ImageStreamCompleter loadImage(BlurhashFfiImage key, decode) =>
      OneFrameImageStreamCompleter(_loadAsync(key));

  Future<String> _encodedImageProvider(ImageProvider provider) async {
    final imageBundle = await _getImageBundleFromImageProvider(
      provider,
      componentX: 4,
      componentY: 3,
    );

    if (wrapWithIsolate) {
      return compute(
        (bundle) => BlurhashFFI.encode(
          bundle.rgbBytes,
          width: bundle.width,
          height: bundle.height,
          componentX: bundle.componentX,
          componentY: bundle.componentY,
        ),
        imageBundle,
      );
    }

    return BlurhashFFI.encode(
      imageBundle.rgbBytes,
      width: imageBundle.width,
      height: imageBundle.height,
      componentX: imageBundle.componentX,
      componentY: imageBundle.componentY,
    );
  }

  void _validateBlurhash(String hash) {
    if (!BlurhashFFI.isValidBlurHash(hash)) {
      throw const FormatException('Invalid blurhash');
    }
  }

  Future<ImageInfo> _loadAsync(BlurhashFfiImage key) async {
    assert(key == this);

    final blurHash = this.blurHash ?? await _encodedImageProvider(inputImage!);

    // Check blurhash only the one that came from the constructor.
    if (this.blurHash != null) {
      _validateBlurhash(blurHash);
    }

    final bytes = await _decodeBlurHash(blurHash);

    final imageFactory = UiImageFactory.fromBytes(
      data: bytes,
      width: decodingWidth,
      height: decodingHeight,
    );

    final convertedImage = await imageFactory.convert();

    return ImageInfo(
      image: convertedImage,
      scale: key.scale,
    );
  }

  Future<Uint8List> _decodeBlurHash(String blurhash) async {
    if (wrapWithIsolate) {
      return compute(
        (bundle) {
          final (blurhash, width, height) = bundle;

          return BlurhashFFI.decode(
            blurhash,
            width: decodingWidth,
            height: decodingHeight,
          );
        },
        (blurhash, decodingWidth, decodingWidth),
      );
    }

    return BlurhashFFI.decode(
      blurhash,
      width: decodingWidth,
      height: decodingHeight,
    );
  }

  Future<ImageBundle> _getImageBundleFromImageProvider(
    ImageProvider imageProvider, {
    required int componentX,
    required int componentY,
  }) async {
    final completer = Completer<ImageBundle>();
    final listener = ImageStreamListener(
      (imageInfo, _) async {
        final ByteData? bytes = await imageInfo.image
            .toByteData(format: ui.ImageByteFormat.rawRgba);
        if (bytes == null) {
          completer.completeError(
            const BlurhashFFIException(
              message: 'Could not decode Image from Image provider',
            ),
          );
          return;
        }
        final Uint8List list = bytes.buffer.asUint8List();

        if (!completer.isCompleted) {
          completer.complete(
            ImageBundle(
              height: imageInfo.image.height,
              width: imageInfo.image.width,
              rowStride: imageInfo.image.width * 4,
              rgbBytes: list,
              componentX: componentX,
              componentY: componentY,
            ),
          );
        }
      },
      onError: (exception, stackTrace) {
        completer.completeError(exception, stackTrace);
      },
    );

    final imageStream = imageProvider.resolve(ImageConfiguration.empty);
    imageStream.addListener(listener);
    completer.future.whenComplete(() {
      imageStream.removeListener(listener);
    });
    return completer.future;
  }

  @override
  bool operator ==(Object other) => other.runtimeType != runtimeType
      ? false
      : other is BlurhashFfiImage &&
          other.blurHash == blurHash &&
          other.scale == scale;

  @override
  int get hashCode => Object.hash(blurHash, inputImage, scale);

  @override
  String toString() =>
      '$runtimeType(inputImage: $inputImage, blurhash: $blurHash, scale: $scale)';
}
