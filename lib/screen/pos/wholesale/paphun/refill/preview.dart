import 'package:flutter/material.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/refill/bill/make_bill.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';


class PreviewRefillGoldPage extends StatelessWidget {
  final Invoice invoice;
  const PreviewRefillGoldPage({super.key, required this.invoice});

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
        build: (context) => makeRefillBill(invoice),
      ),
    );
  }
}