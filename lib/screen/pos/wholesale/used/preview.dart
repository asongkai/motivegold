import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:motivegold/model/order.dart';
import 'make_pdf.dart';


class PreviewSellUsedGoldPage extends StatelessWidget {
  final OrderModel sell;
  const PreviewSellUsedGoldPage({Key? key, required this.sell}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('พิมพ์เอกสาร'),
      ),
      body: PdfPreview(
        build: (context) => makeSellUsedGoldPdf(sell),
      ),
    );
  }
}