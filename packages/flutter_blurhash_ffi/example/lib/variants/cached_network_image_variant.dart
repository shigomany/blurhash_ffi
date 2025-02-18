import 'package:blurhash_ffi_example/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash_ffi/flutter_blurhash_ffi.dart';

class CachedNetworkImageVariant extends StatelessWidget {
  const CachedNetworkImageVariant({
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
          child: CachedNetworkImage(
            imageUrl: selected.url,
            width: 250,
            height: 150,
            fit: BoxFit.fill,
            fadeInDuration: const Duration(milliseconds: 500),
            progressIndicatorBuilder:
                (context, url, downloadProgress) => Image(
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
        ElevatedButton(onPressed: onChanged, child: const Text('Change Asset')),
      ],
    );
  }
}
