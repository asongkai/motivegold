import 'package:flutter/material.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/screen/pos/storefront/theng/bill/make_buy_bill.dart';
import 'package:motivegold/screen/pos/wholesale/theng/refill/bill/make_bill.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

class PreviewBuyThengPdfPage extends StatelessWidget {
  final Invoice invoice;
  final bool goHome;
  final bool shop;

  const PreviewBuyThengPdfPage(
      {super.key,
      required this.invoice,
      this.goHome = false,
      this.shop = false});

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
        build: (context) => shop == true
            ? makeBuyThengBill(invoice)
            : makeRefillThengBill(invoice),
      ),
    );
  }
}
