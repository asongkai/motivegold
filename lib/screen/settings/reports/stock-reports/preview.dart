import 'package:flutter/material.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:printing/printing.dart';

import 'make_pdf.dart';

class PreviewStockReportPage extends StatelessWidget {
  final List<QtyLocationModel> list;
  final int type;
  const PreviewStockReportPage({Key? key, required this.list, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('พิมพ์เอกสาร'),
      ),
      body: PdfPreview(
        build: (context) => makeStockReportPdf(list, type),
      ),
    );
  }
}