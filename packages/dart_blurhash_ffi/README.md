# blurhash_ffi

A [Blurhash](https://blurha.sh) compact Image placeholder encoder and decoder FFI implementation for Flutter in Rust.

Supports Android, iOS, Linux, macOS and Windows.

Matches the official [Blurhash](https://github.com/woltapp/blurhash) implementation in performance and quality.

![blurhash_ffi](https://firebasestorage.googleapis.com/v0/b/folksable-d4dc8.appspot.com/o/blurhash_ffi.png?alt=media&token=e6c7e81b-1798-403b-b055-68a1f767d21f)

# Supports

| Platform | Status | Description                                             |
| -------- | ------ | ------------------------------------------------------- |
| Android  | ✅     | Likned as dymamic library.                              |
| iOS      | ✅     | Likned as static library.                               |
| macOS    | ✅     | Likned as static library.                               |
| Linux    | ✅     | Likned as dymamic library.                              |
| Windows  | ✅     | Likned as dymamic library.                              |
| Web      | ❌     | Rust can compiled to WebAssembly, but no supported yet. This library compiled on standalone wasm module (not in Empscripten, AssemblyScript) that Dart can't be use non-JS enviroments. Also, Dart should use FFI bindings for call wasm module. Stopped issues: [comment](https://github.com/dart-lang/sdk/issues/37355#issuecomment-2135064545) |

# Installation

Add dependency to your `pubspec.yaml` file following the command below:

```sh
dart pub add blurhash_ffi
```

# Usage



# Develop

1. Run pub get:

```sh
dart pub get
```

2. Generate FFI bindings:

```sh
dart run ffigen --config ffigen.yaml
```

# Testing

```sh
dart test
```