import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Preview in Flutter Web without depending on PDF.js or remote CDN assets.
/// The authenticated response is already available as bytes in memory.
class VisorPdfFve extends StatefulWidget {
  const VisorPdfFve({
    super.key,
    required this.bytes,
    required this.nombreArchivo,
  });

  final Uint8List bytes;
  final String nombreArchivo;

  @override
  State<VisorPdfFve> createState() => _VisorPdfFveState();
}

class _VisorPdfFveState extends State<VisorPdfFve> {
  late String _url;

  String _crearUrl(Uint8List bytes) {
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    return web.URL.createObjectURL(blob);
  }

  @override
  void initState() {
    super.initState();
    _url = _crearUrl(widget.bytes);
  }

  @override
  void didUpdateWidget(covariant VisorPdfFve oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.bytes, widget.bytes)) {
      final anterior = _url;
      _url = _crearUrl(widget.bytes);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        web.URL.revokeObjectURL(anterior);
      });
    }
  }

  @override
  void dispose() {
    web.URL.revokeObjectURL(_url);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actual = _url;
    return Column(
      children: [
        Expanded(
          child: HtmlElementView.fromTagName(
            key: ValueKey(actual),
            tagName: 'iframe',
            onElementCreated: (elemento) {
              final marco = elemento as web.HTMLIFrameElement;
              marco
                ..src = actual
                ..title = 'Vista previa del PDF'
                ..style.border = '0';
              marco.style
                ..width = '100%'
                ..height = '100%'
                ..backgroundColor = '#FFFFFF';
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => web.window.open(actual, '_blank', 'noopener,noreferrer'),
            icon: const Icon(Icons.open_in_new, size: 17),
            label: const Text('Abrir vista previa en otra pesta\u00f1a'),
          ),
        ),
      ],
    );
  }
}
