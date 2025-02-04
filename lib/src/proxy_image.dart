import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// A [ImageProvider] that uses a preloaded [ui.Image] as its image.
class ProxyImage extends ImageProvider<ProxyImage> {
  final ui.Image image;
  final double scale;

  const ProxyImage(this.image, {this.scale = 1.0});

  @override
  Future<ProxyImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<ProxyImage>(this);

  @override
  ImageStreamCompleter loadImage(ProxyImage key, decode) =>
      OneFrameImageStreamCompleter(_loadAsync(key));

  Future<ImageInfo> _loadAsync(ProxyImage key) async {
    assert(key == this);
    return ImageInfo(image: image, scale: key.scale);
  }

  @override
  int get hashCode => image.hashCode ^ scale.hashCode;

  @override
  String toString() =>
      '$runtimeType(${describeIdentity(image)}, scale: $scale)';

  @override
  bool operator ==(covariant ProxyImage other) {
    if (identical(this, other)) return true;

    return other.image == image && other.scale == scale;
  }
}
