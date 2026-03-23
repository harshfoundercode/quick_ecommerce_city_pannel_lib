import 'dart:html';
import 'dart:js' as js;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class GoogleSearchBox extends StatefulWidget {
  final Function(double lat, double lng, String address) onSelected;

  const GoogleSearchBox({super.key, required this.onSelected});

  @override
  State<GoogleSearchBox> createState() => _GoogleSearchBoxState();
}

class _GoogleSearchBoxState extends State<GoogleSearchBox> {
  @override
  void initState() {
    super.initState();

    final input = InputElement()
      ..placeholder = "Search location..."
      ..style.width = "100%"
      ..style.height = "40px";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'search-box',
          (int viewId) => input,
    );

    input.onChange.listen((event) {
      final value = input.value ?? "";
      _initAutocomplete(input);
    });
  }

  void _initAutocomplete(InputElement input) {
    final autocomplete = js.context.callMethod(
      'google.maps.places.Autocomplete',
      [input],
    );

    js.context.callMethod('setTimeout', [
          () {
        js.context.callMethod('google.maps.event.addListener', [
          autocomplete,
          'place_changed',
              () {
            final place = autocomplete.callMethod('getPlace');

            final lat =
            place['geometry']['location'].callMethod('lat');
            final lng =
            place['geometry']['location'].callMethod('lng');

            final address = place['formatted_address'];

            widget.onSelected(lat, lng, address);
          }
        ]);
      },
      500
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: 'search-box');
  }
}