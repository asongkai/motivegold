import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:motivegold/model/stockmovement.dart';
import 'make_pdf.dart';

class PreviewStockMovementReportPage extends StatelessWidget {
  final List<StockMovementModel> list;
  final int type;
  const PreviewStockMovementReportPage({Key? key, required this.list, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('พิมพ์เอกสาร'),
      ),
      body: PdfPreview(
        build: (context) => makeStockMovementReportPdf(list, type),
      ),
    );
  }
}