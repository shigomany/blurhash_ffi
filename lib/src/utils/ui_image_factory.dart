import 'dart:async';

import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

class UiImageFactory {
  const UiImageFactory.fromBytes({
    required this.data,
    required this.width,
    required this.height,
  });

  final Uint8List data;
  final int width;
  final int height;

  Future<ui.Image> convert() {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      data,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    return completer.future;
  }
}
