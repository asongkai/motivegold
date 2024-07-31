import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:printing/printing.dart';

import 'make_pdf.dart';

class PreviewSellUsedGoldReportPage extends StatelessWidget {
  final List<OrderModel?> orders;
  final int type;
  final DateTime date;
  const PreviewSellUsedGoldReportPage({Key? key, required this.orders, required this.type, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('พิมพ์เอกสาร'),
      ),
      body: PdfPreview(
        build: (context) => makeSellUsedGoldReportPdf(orders, type, date),
      ),
    );
  }
}