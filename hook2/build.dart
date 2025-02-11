import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_rust/native_toolchain_rust.dart';

Future<void> main(List<String> args) async {
  final logger = Logger('blurhash_ffi_native_asset');
  logger.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  try {
    await build(
      args,
      (BuildConfig buildConfig, BuildOutput output) async {
        final builder = RustBuilder(
          package: 'blurhash_ffi',
          cratePath: 'rust',
          buildConfig: buildConfig,
          logger: logger,
        );
        await builder.run(output: output);
      },
    );
  } on Object catch (e, st) {
    logger.warning('Failed to build native assets: \n$e');
    logger.warning('Stack trace: \n$st');
    exit(1);
  }
}
