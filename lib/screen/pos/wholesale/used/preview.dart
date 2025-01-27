import 'package:flutter/material.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/screen/pos/wholesale/used/bill/make_bill.dart';
import 'package:printing/printing.dart';

class PreviewSellUsedGoldPage extends StatelessWidget {
  final Invoice invoice;
  const PreviewSellUsedGoldPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('พิมพ์เอกสาร'),
      ),
      body: PdfPreview(
        build: (context) => makeSellUsedBill(invoice),
      ),
    );
  }
}