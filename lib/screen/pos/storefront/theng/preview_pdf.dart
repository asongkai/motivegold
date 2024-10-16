import 'package:flutter/material.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:printing/printing.dart';

import 'make_pdf.dart';

class PdfThengPreviewPage extends StatelessWidget {
  final Invoice invoice;
  const PdfThengPreviewPage({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('พิมพ์เอกสาร'),
      ),
      body: PdfPreview(
        build: (context) => makeThengPdf(invoice),
      ),
    );
  }
}