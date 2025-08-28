import 'package:flutter/material.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/refill/bill/make_bill.dart';
import 'package:motivegold/screen/pos/wholesale/theng/refill/bill/make_bill.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';
import 'package:sizer/sizer.dart';


class PreviewRefillThengGoldPage extends StatefulWidget {
  final Invoice invoice;
  final bool goHome;
  const PreviewRefillThengGoldPage({super.key, required this.invoice, this.goHome = false});

  @override
  State<PreviewRefillThengGoldPage> createState() => _PreviewRefillThengGoldPageState();
}

class _PreviewRefillThengGoldPageState extends State<PreviewRefillThengGoldPage> {
  int option = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          goHome: widget.goHome,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: const Text("พิมพ์เอกสาร",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildPrintButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PdfPreview(
        build: (context) => makeRefillThengBill(widget.invoice, option: option),
      ),
    );
  }

  Widget _buildPrintButton() {
    return PopupMenuButton<int>(
      onSelected: (int value) async {
        setState(() {
          option = value;
        });
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.print, size: 16),
            title: Text('หน้าเดียว', style: TextStyle(fontSize: 14)),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.print, size: 16),
            title: Text('แยกหน้า', style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.print_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 6),
            Text('ตัวเลือกการพิมพ์', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_outlined, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}