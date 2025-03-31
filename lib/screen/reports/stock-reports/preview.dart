import 'package:flutter/material.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

import 'make_pdf.dart';

class PreviewStockReportPage extends StatelessWidget {
  final List<QtyLocationModel> list;
  final int type;
  const PreviewStockReportPage({Key? key, required this.list, required this.type}) : super(key: key);

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
        build: (context) => makeStockReportPdf(list, type),
      ),
    );
  }
}