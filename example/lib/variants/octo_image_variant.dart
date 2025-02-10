import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:blurhash_ffi_example/main.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class OctoImageVariant extends StatelessWidget {
  const OctoImageVariant({
    super.key,
    required this.selected,
    required this.items,
    required this.onChanged,
  });

  final ItemImageBlurhashType selected;

  final List<ItemImageBlurhashType> items;

  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: OctoImage(
            image: NetworkImage(selected.url),
            width: 250,
            height: 150,
            fit: BoxFit.fill,
            fadeInDuration: const Duration(milliseconds: 500),
            progressIndicatorBuilder: (context, chunks) => Image(
              image: BlurhashFfiImage(
                selected.blurhash,
                decodingWidth: 25,
                decodingHeight: 15,
              ),
              width: 250,
              height: 150,
              fit: BoxFit.fill,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onChanged,
          child: const Text('Change Asset'),
        ),
      ],
    );
  }
}
