import 'dart:async';

import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

class UiImageFactory {
  const UiImageFactory.fromBytes({
    required this.data,
    required this.width,
    required this.height,
    this.targetWidth,
    this.targetHeight,
    this.format = ui.PixelFormat.rgba8888,
  });

  final Uint8List data;
  final int width;
  final int height;
  final int? targetWidth;
  final int? targetHeight;
  final ui.PixelFormat format;

  Future<ui.Image> convert() {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      data,
      width,
      height,
      format,
      completer.complete,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );

    return completer.future;
  }
}
