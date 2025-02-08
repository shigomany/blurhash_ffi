// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: unused_element

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:blurhash_ffi/src/proxy_image.dart';

import 'src/blurhash_ffi_bindings_generated.dart';
import 'src/exceptions.dart';
import 'src/image_bundle.dart';
import 'src/utils/bmp_factory.dart';

const String _libName = 'blurhash_ffi';

/// Create a neat class to handle all the glue code and expose a nice API.
class BlurhashFFI {
  // singleton class
  static final BlurhashFFI _instance = BlurhashFFI._();

  factory BlurhashFFI() => _instance;

  BlurhashFFI._();

  static bool isValidBlurHash(String blurHash) =>
      _instance._isValidBlurHash(blurHash);

  static Future<String> encode(
    ImageProvider imageProvider, {
    int componentX = 4,
    int componentY = 3,
  }) async {
    final info = await _instance._getImageInfoFromImageProvider(
      imageProvider,
      componentX: componentX,
      componentY: componentY,
    );
    return await _instance._encodeBlurHash(info);
  }

  static Future<ui.Image> decode(
    String blurhash, {
    int width = 32,
    int height = 32,
    int punch = 1,
  }) async {
    return await _instance._blurHashDecodeImage(blurhash, width, height, punch);
  }

  bool _isValidBlurHash(String blurHash) {
    // Pointer<Utf8> bhptr = blurHash.toNativeUtf8();
    // bool result = _bindings.isValidBlurhash(bhptr.cast<Char>());
    // malloc.free(bhptr);
    return true;
  }

  /// The dynamic library in which the symbols for [BlurhashFfiBindings] can be found.
  DynamicLibrary _openDylib() {
    if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.process();
    }
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('lib$_libName.so');
    }
    if (Platform.isWindows) {
      return DynamicLibrary.open('$_libName.dll');
    }
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }

  late final DynamicLibrary _openedLibrary = _openDylib();

  BlurhashFfiBindings get _bindings {
    return BlurhashFfiBindings(_openedLibrary);
  }

  // // encode requests
  // int _nextEncodeRequestId = 0;
  // final Map<int, Completer<String>> _encodeRequests =
  //     <int, Completer<String>>{};

  // // decode requests
  // int _nextDecodeRequestId = 0;
  // final Map<int, Completer<Uint8List>> _decodeRequests =
  //     <int, Completer<Uint8List>>{};

  // // decode to array requests
  // int _nextDecodeToArrayRequestId = 0;
  // final Map<int, Completer<int>> _decodeToArrayRequests =
  //     <int, Completer<int>>{};

  Future<ImageBundle> _getImageInfoFromImageProvider(
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
      onError: (dynamic exception, StackTrace? stackTrace) {
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

  Future<ui.Image> _blurHashDecodeImage(
    String hash,
    int width,
    int height,
    int punch,
  ) async {
    _validateBlurhash(hash);

    final completer = Completer<ui.Image>();
    final pixels = await _decodeBlurHash(hash, width, height, punch);
    if (kIsWeb) {
      final bmpFactory = BmpFactory.fromBuffer(
        pixels: pixels,
        width: width,
        height: height,
        channels: 4,
      );
      // https://github.com/flutter/flutter/issues/45190
      completer.complete(bmpFactory.createImage());
    } else {
      ui.decodeImageFromPixels(
        pixels,
        width,
        height,
        ui.PixelFormat.rgba8888,
        completer.complete,
      );
    }

    return completer.future;
  }

  void _validateBlurhash(String hash) {
    if (!_isValidBlurHash(hash)) {
      throw const FormatException('Invalid blurhash');
    }
  }

  // Future<BlurHashImageInfo> _getBlurHashImageInfoFromAsset(String assetName) {
  //   return _getImageInfoFromImageProvider(AssetImage(assetName));
  // }

  // Future<BlurHashImageInfo> _getBlurHashInfoFromUiImage(ui.Image image) {
  //   return _getImageInfoFromImageProvider(ProxyImage(image));
  // }

  Future<Uint8List> _decodeBlurHash(
    String hash,
    int width,
    int height,
    int punch,
  ) async {
    return compute<String, Uint8List>(
      (blurhash) => _bindings
          .blurhash_decode(
            blurhash.toNativeUtf8().cast(),
            blurhash.length,
            width,
            height,
            punch.toDouble(),
          )
          .asTypedList(width * height * 4),
      hash,
      debugLabel: 'blurhash_ffi#native',
    );
  }

  Future<String> _encodeBlurHash(ImageBundle bundle) async {
    final blurhash = bundle;
    final arena = Arena();
    final pointer = arena<Uint8>(blurhash.rgbBytes.length);
    for (int i = 0; i < blurhash.rgbBytes.length; i++) {
      pointer[i] = blurhash.rgbBytes[i];
    }
    final rawValue = _bindings
        .blurhash_encode(
          blurhash.componentX,
          blurhash.componentY,
          blurhash.width,
          blurhash.height,
          pointer,
          blurhash.rgbBytes.length,
        )
        .cast<Utf8>()
        .toDartString();
    arena.free(pointer);

    return rawValue;
    // return compute<ImageBundle, String>(
    //   (blurhash) {
    //     final arena = Arena();
    //     final pointer = arena<Uint8>(blurhash.rgbBytes.length);
    //     for (int i = 0; i < blurhash.rgbBytes.length; i++) {
    //       pointer[i] = blurhash.rgbBytes[i];
    //     }

    //     final rawValue = _bindings
    //         .encode(
    //           blurhash.componentX,
    //           blurhash.componentY,
    //           blurhash.width,
    //           blurhash.height,
    //           pointer,
    //           blurhash.rgbBytes.length,
    //         )
    //         .cast<Utf8>()
    //         .toDartString();
    //     arena.free(pointer);

    //     return rawValue;
    //   },
    //   bundle,
    //   debugLabel: 'blurhash_ffi#native',
    // );
  }

  // Future<int> _decodeToArray(
  //   String blurHash,
  //   int width,
  //   int height,
  //   int punch,
  //   int channels,
  //   Pointer<Uint8> pixelArray,
  // ) async {
  //   final SendPort helperIsolateSendPort = await _helperIsolateSendPort;

  //   final int requestId = _nextDecodeToArrayRequestId++;
  //   final _DecodeToArrayRequest request = _DecodeToArrayRequest(
  //       requestId, blurHash, width, height, punch, channels, pixelArray);
  //   final Completer<int> completer = Completer<int>();
  //   _decodeToArrayRequests[requestId] = completer;
  //   helperIsolateSendPort.send(request);
  //   return completer.future;
  // }

  // late final Future<SendPort> _helperIsolateSendPort =
  //     _helperIsolateSendPortFunc();

  /// The SendPort belonging to the helper isolate.
  // Future<SendPort> _helperIsolateSendPortFunc() async {
  //   // The helper isolate is going to send us back a SendPort, which we want to
  //   // wait for.
  //   final Completer<SendPort> completer = Completer<SendPort>();

  //   // Receive port on the main isolate to receive messages from the helper.
  //   // We receive two types of messages:
  //   // 1. A port to send messages on.
  //   // 2. Responses to requests we sent.
  //   void onData(dynamic data) {
  //     if (data is SendPort) {
  //       // The helper isolate sent us the port on which we can sent it requests.
  //       completer.complete(data);
  //       return;
  //     }
  //     if (data is _EncodeResponse) {
  //       // The helper isolate sent us a response to a request we sent.
  //       final Completer<String> completer = _encodeRequests[data.id]!;
  //       _encodeRequests.remove(data.id);
  //       completer.complete(data.result);
  //       return;
  //     } else if (data is _DecodeResponse) {
  //       // The helper isolate sent us a response to a request we sent.
  //       final Completer<Uint8List> completer = _decodeRequests[data.id]!;
  //       _decodeRequests.remove(data.id);
  //       completer.complete(data.result);
  //       return;
  //     } else if (data is _DecodeToArrayResponse) {
  //       // The helper isolate sent us a response to a request we sent.
  //       final Completer<int> completer = _decodeToArrayRequests[data.id]!;
  //       _decodeToArrayRequests.remove(data.id);
  //       completer.complete(data.result);
  //       return;
  //     }
  //     throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
  //   }

  //   final ReceivePort receivePort = ReceivePort()..listen(onData);
  //   final ReceivePort errorPort = ReceivePort()
  //     ..listen((message) {
  //       final isolateDebugName =
  //           'blurhash_ffi#native#${_helperIsolates.length}';
  //       if (message is BlurhashFFIException) {
  //         switch (message.level) {
  //           case Level.SEVERE:
  //             _log.severe('Error $isolateDebugName: ${message.message}',
  //                 message.error, message.stackTrace);
  //             break;
  //           case Level.INFO:
  //             _log.info('Error $isolateDebugName: ${message.message}',
  //                 message.error, message.stackTrace);
  //             break;
  //           case Level.WARNING:
  //             _log.warning('Error $isolateDebugName: ${message.message}',
  //                 message.error, message.stackTrace);
  //             break;
  //           default:
  //             _log.shout(
  //                 'Error ${message.level} $isolateDebugName: ${message.message}',
  //                 message.error,
  //                 message.stackTrace);
  //         }
  //       } else {
  //         _log.shout('Error $isolateDebugName: $message');
  //       }
  //     });
  //   // Start the helper isolate.
  //   final isolate = await Isolate.spawn<SendPort>(
  //     isolateEntryPoint,
  //     receivePort.sendPort,
  //     errorsAreFatal: false,
  //     onError: errorPort.sendPort,
  //     debugName: 'blurhash_ffi#native#${_helperIsolates.length}}',
  //   );

  //   _helperIsolates.add(isolate);

  //   // Wait until the helper isolate has sent us back the SendPort on which we
  //   // can start sending requests.
  //   return completer.future;
  // }

  // void isolateEntryPoint(SendPort sendPort) async {
  //   void onSend(dynamic data) {
  //     try {
  //       // On the helper isolate listen to requests and respond to them.
  //       if (data is _EncodeRequest) {
  //         final Pointer<Char> result = _bindings.blurHashForPixels(
  //           data.componentX,
  //           data.componentY,
  //           data.width,
  //           data.height,
  //           data.pixelsPointer,
  //           data.rowStride,
  //         );
  //         final String resultString = result.cast<Utf8>().toDartString();
  //         final _EncodeResponse response =
  //             _EncodeResponse(data.id, resultString);
  //         sendPort.send(response);
  //         return;
  //       } else if (data is _DecodeRequest) {
  //         final Pointer<Uint8> result = _bindings.decode(data.blurHashPointer,
  //             data.width, data.height, data.punch, data.channels);
  //         final Uint8List resultImage = result.asTypedList(
  //           data.width * data.height * data.channels,
  //           // preffer way but works only from dart 3.1.0, and requre to change generated bindings
  //           // finalizer: _bindings.freePixelArrayPtr.cast(),
  //         );
  //         final _DecodeResponse response = _DecodeResponse(
  //           data.id,
  //           // copy image data to prevent 'use after free' error
  //           Uint8List.fromList(resultImage),
  //         );
  //         // free c side memory
  //         _bindings.freePixelArray(result);
  //         sendPort.send(response);
  //         return;
  //       } else if (data is _DecodeToArrayRequest) {
  //         final int result = _bindings.decodeToArray(
  //             data.blurHashPointer,
  //             data.width,
  //             data.height,
  //             data.punch,
  //             data.channels,
  //             data.pixelArray);
  //         data.free();
  //         final _DecodeToArrayResponse response =
  //             _DecodeToArrayResponse(data.id, result);
  //         sendPort.send(response);
  //         return;
  //       }
  //       throw BlurhashFFIException(
  //           'EXCEPTION: Unsupported message type: ${data.runtimeType}',
  //           null,
  //           null);
  //     } catch (e) {
  //       final stackTrace = StackTrace.current;
  //       throw BlurhashFFIException(
  //           'ERROR: ${Isolate.current.debugName}', stackTrace, e);
  //     }
  //   }

  //   final ReceivePort helperReceivePort = ReceivePort()..listen(onSend);

  //   // Send the port to the main isolate on which we can receive requests.
  //   sendPort.send(helperReceivePort.sendPort);
  // }
}

// class _DecodeToArrayRequest {
//   final int id;
//   final String blurHash;
//   final int width;
//   final int height;
//   final int punch;
//   final int channels;
//   final Pointer<Uint8> pixelArray;
//   Pointer<Utf8>? _bhptr;

//   _DecodeToArrayRequest(this.id, this.blurHash, this.width, this.height,
//       this.punch, this.channels, this.pixelArray);

//   Pointer<Char> get blurHashPointer {
//     if (_bhptr != null) {
//       _bhptr = blurHash.toNativeUtf8();
//       return _bhptr!.cast<Char>();
//     }
//     return _bhptr!.cast<Char>();
//   }

//   @override
//   void free() {
//     if (_bhptr != null) {
//       malloc.free(_bhptr!);
//       _bhptr = null;
//     }
//   }
// }

// class _DecodeRequest with Freeable {
//   final int id;
//   final String blurHash;
//   final int width;
//   final int height;
//   final int punch;
//   final int channels;
//   Pointer<Utf8>? _bhptr;

//   _DecodeRequest(
//     this.id,
//     this.blurHash,
//     this.width,
//     this.height,
//     this.punch,
//     this.channels,
//   );

//   Pointer<Char> get blurHashPointer {
//     if (_bhptr == null) {
//       _bhptr = blurHash.toNativeUtf8();
//       return _bhptr!.cast<Char>();
//     }
//     return _bhptr!.cast<Char>();
//   }

//   @override
//   void free() {
//     if (_bhptr != null) {
//       malloc.free(_bhptr!);
//       _bhptr = null;
//     }
//   }
// }

// class _EncodeRequest with Freeable {
//   final int id;
//   final Uint8List pixels;
//   final int width;
//   final int height;
//   final int componentX;
//   final int componentY;
//   final int rowStride;
//   Pointer<Uint8>? pixelsPtr;

//   _EncodeRequest(this.id, this.pixels, this.width, this.height, this.componentX,
//       this.componentY, this.rowStride);

//   Pointer<Uint8> get pixelsPointer {
//     if (pixelsPtr == null) {
//       pixelsPtr = calloc.allocate<Uint8>(pixels.lengthInBytes);
//       pixelsPtr!.asTypedList(pixels.lengthInBytes).setAll(0, pixels);
//     }
//     return pixelsPtr!;
//   }

//   @override
//   void free() {
//     if (pixelsPtr != null) {
//       calloc.free(pixelsPtr!);
//       pixelsPtr = null;
//     }
//   }
// }

// class _EncodeResponse {
//   final int id;
//   final String result;

//   const _EncodeResponse(this.id, this.result);
// }

// class _DecodeResponse {
//   final int id;
//   final Uint8List result;

//   const _DecodeResponse(this.id, this.result);
// }

// class _DecodeToArrayResponse {
//   final int id;
//   final int result;

//   const _DecodeToArrayResponse(this.id, this.result);
// }
