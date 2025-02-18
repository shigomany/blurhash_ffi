import 'package:blurhash_ffi_example/variants/cached_network_image_variant.dart';
import 'package:blurhash_ffi_example/variants/octo_image_variant.dart';
import 'package:dart_blurhash_ffi/dart_blurhash_ffi.dart';
import 'package:flutter/material.dart';

import 'utils/url_images_list.dart';
import 'variants/vanilla_image_variant.dart';
import 'package:http/http.dart' as http;

typedef ItemImageBlurhashType = ({String url, String blurhash});

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _items = <ItemImageBlurhashType>[];
  late Future<void> _loadImages;
  late ItemImageBlurhashType _selected;

  @override
  void initState() {
    super.initState();
    _loadImages = _loadingAllImages().whenComplete(() {
      _selected = _items.first;
    });
  }

  /// Load all images and generate blurhashes for them.
  Future<void> _loadingAllImages() async {
    for (final url in urlImagesList) {
      final response = await http.get(Uri.parse(url));
      // final decodedImage = image.decodeImage(response.bodyBytes);
      // if (decodedImage == null) {
      //   throw const FormatException('Error with decoding image');
      // }

      // final rgbaImage = decodedImage.convert(numChannels: 4);

      final blurhash = BlurhashFFI.encode(response.bodyBytes);
      _items.add((url: url, blurhash: blurhash));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Blurhash FFI Example'),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(text: 'Vanilla'),
                Tab(text: 'OctoImage'),
                Tab(text: 'CachedNetworkImage'),
              ],
            ),
          ),
          body: FutureBuilder<void>(
            future: _loadImages,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Preloading blurhashes for images'),
                      SizedBox(height: 8),
                      CircularProgressIndicator.adaptive(),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error with loading images'),
                      const SizedBox(height: 8),
                      const Icon(Icons.error, color: Colors.red),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _loadImages = _loadingAllImages();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return TabBarView(
                children: [
                  Center(
                    child: VanillaImageVariant(
                      selected: _selected,
                      items: _items,
                      onChanged: _handleNewImage,
                    ),
                  ),
                  Center(
                    child: OctoImageVariant(
                      selected: _selected,
                      items: _items,
                      onChanged: _handleNewImage,
                    ),
                  ),
                  Center(
                    child: CachedNetworkImageVariant(
                      selected: _selected,
                      items: _items,
                      onChanged: _handleNewImage,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleNewImage() {
    final index = _items.indexOf(_selected);
    final nextIndex = (index + 1) % _items.length;

    setState(() {
      _selected = _items[nextIndex];
    });
  }
}
