import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/vat-reports/buy-new-gold/make_pdf.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

class PreviewBuyVatReportPage extends StatelessWidget {
  final List<OrderModel?> orders;
  final int type;
  final DateTime date;
  const PreviewBuyVatReportPage({super.key, required this.orders, required this.type, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("พิมพ์เอกสาร",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: PdfPreview(
        build: (context) => makeBuyVatReportPdf(orders, type, date),
      ),
    );
  }
}