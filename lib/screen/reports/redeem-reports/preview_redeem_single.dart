import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/screen/reports/redeem-reports/print/make_redeem_report_pdf.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

class PreviewRedeemSingleReportPage extends StatelessWidget {
  final List<RedeemModel?> orders;
  final List<RedeemModel?> daily;
  final int type;
  final String date;
  const PreviewRedeemSingleReportPage({super.key, required this.orders, required this.type, required this.date, required this.daily});

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
        build: (context) => makeRedeemReportPdf(orders, type, date, daily),
      ),
    );
  }
}