import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

import 'make_pdf.dart';

class PreviewBuyUsedGoldGovReportPage extends StatelessWidget {
  final List<OrderModel?> orders;
  final int type;
  final String date;
  const PreviewBuyUsedGoldGovReportPage({super.key, required this.orders, required this.type, required this.date});

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
        build: (context) => makeBuyUsedGoldGovReportPdf(orders, type, date),
      ),
    );
  }
}