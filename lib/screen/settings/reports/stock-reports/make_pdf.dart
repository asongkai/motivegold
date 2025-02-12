import 'dart:typed_data';

import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';

Future<Uint8List> makeStockReportPdf(List<QtyLocationModel> list,int type) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  List<Widget> widgets = [];

  widgets.add(Center(
      child: Column(children: [
        Text('${Global.company?.name}'),
        Text('(${Global.branch!.name})'),
        //   Text('(สํานักงานใหญ่)'),
        //   Text('${Global.company?.name}'),
        Text(
            '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
        //   Text('${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
        Text('เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber}'),
        Text('TAX : INVOICE [ABB]/RECEIPT VAT INCLUDED)'),
        Text('POS Reg. No : '),
      ])));
  widgets.add(height());
  widgets.add(divider());
  widgets.add(Center(
    child: Text(
      'รายงานสต็อก',
      style: const TextStyle(
          decoration: TextDecoration.none, fontSize: 20),
    ),
  ));
  widgets.add(height());
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("ชื่อผู้ประกอบการ ${Global.branch!.name}"),
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("ชื่อสถานประกอบการ ${Global.company!.name}"),
      Text('ลําดับเลขที่สาขา ${Global.branch!.branchId}'),
    ],
  ));
  widgets.add(height());
  widgets.add(Table(
    border: TableBorder.all(color: PdfColors.grey500),
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    columnWidths: {
      0: const FlexColumnWidth(2),
      1: const FlexColumnWidth(3),
      2: const FlexColumnWidth(2),
      3: const FlexColumnWidth(2),
      4: const FlexColumnWidth(3)
    },
    children: [
      TableRow(children: [
        paddedTextBigXL('สินค้า'),
        paddedTextBigXL('คลังสินค้า'),
        paddedTextBigXL('น้ำหนักรวม', align: TextAlign.right),
        paddedTextBigXL('ราคาต่อ\nหน่วย', align: TextAlign.right),
        paddedTextBigXL('ราคารวม', align: TextAlign.right),
      ]),
      ...list.map((e) => TableRow(
        decoration: const BoxDecoration(),
        children: [
          paddedTextBigXL(
              e.product == null ? "" : e.product!.name),
          paddedTextBigXL(e.binLocation == null
              ? ""
              : e.binLocation!.name),
          paddedTextBigXL(Global.format(e.weight ?? 0),
              style: const TextStyle(fontSize: 12),
              align: TextAlign.right),
          paddedTextBigXL(
              Global.format(e.unitCost ?? 0),
              style: const TextStyle(fontSize: 12),
              align: TextAlign.right),
          paddedTextBigXL(
              Global.format(e.price ?? 0),
              style: const TextStyle(fontSize: 12),
              align: TextAlign.right),
        ],
      )),
      // TableRow(children: [
      //   paddedTextBigXL('', style: const TextStyle(fontSize: 14)),
      //   paddedTextBigXL(''),
      //   paddedTextBigXL(''),
      //   paddedTextBigXL('รวมท้ังหมด'),
      //   paddedTextBigXL(Global.format(getWeightTotal(ods))),
      //   paddedTextBigXL(''),
      //   paddedTextBigXL(Global.format(priceIncludeTaxTotal(ods))),
      //   paddedTextBigXL(Global.format(purchasePriceTotal(ods))),
      //   paddedTextBigXL(Global.format(priceDiffTotal(ods))),
      //   paddedTextBigXL(Global.format(taxBaseTotal(ods))),
      //   paddedTextBigXL(Global.format(taxAmountTotal(ods))),
      //   paddedTextBigXL(Global.format(priceExcludeTaxTotal(ods))),
      // ])
    ],
  ));
  widgets.add(height());
  widgets.add(divider());
  widgets.add(height());
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      paddedText('ผู้ตรวจสอบ/Authorize',
          style: TextStyle(fontWeight: FontWeight.bold)),
      paddedText('ผู้อนุมัติ/Approve',
          style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Divider(
          height: 1,
          borderStyle: BorderStyle.dashed,
        ),
      ),
      SizedBox(width: 80),
      Expanded(
        child: Divider(
          height: 1,
          borderStyle: BorderStyle.dashed,
        ),
      ),
    ],
  ));
  widgets.add(height());
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('('),
      Expanded(
        child: Divider(
          height: 1,
          borderStyle: BorderStyle.dashed,
        ),
      ),
      Text(')'),
      SizedBox(width: 80),
      Text('('),
      Expanded(
        child: Divider(
          height: 1,
          borderStyle: BorderStyle.dashed,
        ),
      ),
      Text(')'),
    ],
  ));
  widgets.add(height());
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('วันที่ : ${DateTime.now()}'),
      Spacer(),
      Text('วันที่ : ${DateTime.now()}')
    ],
  ));
  widgets.add(height());
  widgets.add(divider());
  widgets.add(height());
  widgets.add(Center(child: Text(
    "ตราประทับ",
    style: const TextStyle(fontSize: 20),
  )));
  widgets.add(height(h: 100));
  widgets.add(divider());

  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(30),
      pageFormat: PdfPageFormat.a4,
      build: (context) => widgets,
    ),
  );
  return pdf.save();
}

Widget paddedText(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 12)}) =>
    Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );

Widget paddedTextBigXL(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 14)}) =>
    Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );