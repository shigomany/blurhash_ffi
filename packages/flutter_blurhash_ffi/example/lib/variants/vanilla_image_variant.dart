import 'package:blurhash_ffi_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash_ffi/flutter_blurhash_ffi.dart';

class VanillaImageVariant extends StatelessWidget {
  const VanillaImageVariant({
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
          child: Image(
            image: NetworkImage(selected.url),
            fit: BoxFit.fill,
            width: 250,
            height: 150,
            frameBuilder: (context, child, frame, wasLoaded) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 1500),
                transitionBuilder:
                    (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                child:
                    frame != null
                        ? SizedBox(
                          key: const ValueKey('vanilla-loaded-key'),
                          child: child,
                        )
                        : Image(
                          key: const ValueKey('vanilla-loading-key'),
                          image: BlurhashFfiImage(selected.blurhash),
                          fit: BoxFit.fill,
                          width: 250,
                          height: 150,
                        ),
              );
            },
          ),
        ),
        ElevatedButton(onPressed: onChanged, child: const Text('Change Asset')),
      ],
    );
  }
}
