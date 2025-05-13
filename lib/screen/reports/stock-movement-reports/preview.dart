import 'package:flutter/material.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

import 'package:motivegold/model/stockmovement.dart';
import 'make_pdf.dart';

class PreviewStockMovementReportPage extends StatelessWidget {
  final List<StockMovementModel> list;
  final int type;
  const PreviewStockMovementReportPage({super.key, required this.list, required this.type});

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
        build: (context) => makeStockMovementReportPdf(list, type),
      ),
    );
  }
}