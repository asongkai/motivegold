import 'package:flutter/material.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/screen/pos/redeem/bill/make_pdf.dart';
import 'package:motivegold/screen/pos/storefront/paphun/bill/make_bill.dart';
import 'package:motivegold/screen/pos/storefront/paphun/bill/make_used_bill.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

class PdfPreviewRedeemPage extends StatelessWidget {
  final InvoiceRedeem invoice;
  final bool goHome;

  const PdfPreviewRedeemPage({super.key, required this.invoice, this.goHome = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          goHome: goHome,
          title: Text("พิมพ์เอกสาร",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: PdfPreview(
        build: (context) => makeRedeemSingleBillPdf(invoice),
      ),
    );
  }
}
