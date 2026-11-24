import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class VisorPdfFve extends StatelessWidget {
  const VisorPdfFve({
    super.key,
    required this.bytes,
    required this.nombreArchivo,
  });

  final Uint8List bytes;
  final String nombreArchivo;

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (formato) async => bytes,
      initialPageFormat: PdfPageFormat.a4,
      canChangePageFormat: false,
      canChangeOrientation: false,
      allowPrinting: false,
      allowSharing: false,
      canDebug: false,
      maxPageWidth: 800,
      pdfFileName: nombreArchivo,
    );
  }
}
