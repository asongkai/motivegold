import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/refill-wholesale-theng/make_pdf.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

class PreviewRefillWholesaleThengReportPage extends StatelessWidget {
  final List<OrderModel?> orders;
  final int type;
  final String date;
  final DateTime? fromDate;
  final DateTime? toDate;
  const PreviewRefillWholesaleThengReportPage({super.key, required this.orders, required this.type, required this.date, this.fromDate, this.toDate});

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
        build: (context) => makeRefillWholesaleThengReportPdf(orders, type, date, fromDate!, toDate!),
      ),
    );
  }
}
