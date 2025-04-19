# blurhash_ffi

A [Blurhash](https://blurha.sh) compact Image placeholder encoder and decoder FFI implementation for Flutter in Rust via experemental feature [Native Assets](https://github.com/flutter/flutter/issues/129757).

Matches the official [Blurhash](https://github.com/woltapp/blurhash) implementation in performance and quality.

![blurhash_ffi](https://firebasestorage.googleapis.com/v0/b/folksable-d4dc8.appspot.com/o/blurhash_ffi.png?alt=media&token=e6c7e81b-1798-403b-b055-68a1f767d21f)

# Supports

| Platform | Status | Description                                                                                                                                                                                                                                                                                                                                       |
| -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Android  | ✅      | -                                                                                                                                                                                                                                                                                                                                                 |
| iOS      | ✅      | -                                                                                                                                                                                                                                                                                                                                                 |
| macOS    | ⚠️      | Worked if merge this [PR](https://github.com/irondash/native_toolchain_rust/pull/26)                                                                                                                                                                                                                                                              |
| Linux    | ⚠️      | Not tested                                                                                                                                                                                                                                                                                                                                        |
| Windows  | ⚠️      | Worked but exist problem: long path length error via compilation ([meta issue](https://github.com/rust-lang/cargo/issues/9770) and [issue](https://github.com/rust-lang/cargo/issues/13141) which describe this )                                                                                                                                 |
| Web      | ❌      | Rust can compiled to WebAssembly, but no supported yet. This library compiled on standalone wasm module (not in Empscripten, AssemblyScript) that Dart can't be use non-JS enviroments. Also, Dart should use FFI bindings for call wasm module. Stopped issues: [comment](https://github.com/dart-lang/sdk/issues/37355#issuecomment-2135064545) |

# Installation

Add dependency to your `pubspec.yaml` file following the command below:


For dart projects:

```sh
dart pub add dart_blurhash_ffi
```

For flutter projects:

```sh
dart pub add flutter_blurhash_ffi
```

## Usage

To use this plugin, add `blurhash_ffi` as a dependency in your pubspec.yaml file

**Flutter usage**

```dart
import 'package:flutter_blurhash_ffi/flutter_blurhash_ffi.dart';

/// Encoding and Decoding all in One Step
///
/// `ImageProvider` in    -> Send your Image to be encoded.
/// `ImageProvider` out   -> Get your blurry image version.
class BlurhashMyImage extends StatelessWidget {
  final String imageUrl;
  const BlurhashMyImage({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Image(
      image: BlurhashFfiImage.fromImageProvider(
        NetworkImage(imageUrl),  // you can use any image provider of your choice.
        decodingHeight: 1920,
        decodingWidth: 1080,
      ),
      alignment: Alignment.center,
      fit: BoxFit.cover
    );
  }
}


class BlurhashMyImage2 extends StatelessWidget {
  final String blurhash;
  const BlurhashMyImage2({required this.blurhash, super.key});

  @override
  Widget build(BuildContext context) {
    return Image(
      image: BlurhashFfiImage(blurhash),
      width: 200,
      height: 200,
      alignment: Alignment.center,
      fit: BoxFit.cover
    );
  }
}

```

> [!WARNING]
> Not recommend use it (without _blurhash string param_), because in this case, encoding and decoding will be performed. This effect can be obtained almost through [ImageFiltered](https://api.flutter.dev/flutter/widgets/ImageFiltered-class.html).

**Encoding**

Encoding now uses sync interface (without `Future`).

<?code-excerpt "readme_excerpts.dart (Example)"?>

```dart
import 'package:dart_blurhash_ffi/dart_blurhash_ffi.dart';

final Uint8List blurhashImageBytes = File('assets/image.webp').readAsBytesSync();

/// Signature
/// static String encode(
///   Uint8List data, {
///   int componentX = 4,
///   int componentY = 3,
/// })
/// may throw `BlurhashFFIException` if encoding fails.
final String blurHash = BlurhashFFI.encode(blurhashImageBytes);

// Or via codec

final String blurHashSame = BlurhashFfiCodec().encoder.convert(blurhashImageBytes);

```

**Decoding**

Decoding now uses sync interface (without `Future`).

```dart
import 'package:dart_blurhash_ffi/dart_blurhash_ffi.dart';

final String blurhash = 'LGFO~6Yk^6#M@-5c,1Ex@@or[j6o';

/// Signature
///
/// static Uint8List decode(
///   String blurhash, {
///   int width = 32,
///   int height = 32,
///   int punch = 1,
/// })
/// may throw `BlurhashFFIException` if decoding fails.
final decoded = BlurhashFFI.decode(blurhash);

// or via codec

final String decodedSame = BlurhashFfiCodec().decoder.convert(blurhash);

```

Check the [example](./packages/flutter_blurhash_ffi/example/) for more details

**contributions in the form of PR's and Issues are a welcome**
