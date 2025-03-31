import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeBuyUsedGoldReportPdf(
    List<OrderModel?> orders, int type, DateTime date) async {
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
        Text('${Global.company?.name} (${Global.branch!.name})',
            style:
            TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Text(
            '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}',
            style:
            TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Text(
            'เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber} โทร ${Global.company?.phone}',
            style:
            TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ])));
  widgets.add(height());
  widgets.add(Center(
    child: Text(
      'สมุดบัญชีซ้ือทอง / สมุดบัญชีจ่าย',
      style: const TextStyle(
          decoration: TextDecoration.none, fontSize: 20),
    ),
  ));
  widgets.add(height());
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("ชื่อผู้ประกอบการ ${Global.branch!.name}"),
      Text(
          'สําหรับเดือน ${Global.monthYear(date.toString())}'),
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
    children: [
      TableRow(children: [
        paddedText('วัน/เดือน/ปี', align: TextAlign.center),
        paddedText('เลขท่ีใบสําคัญรับเงิน', align: TextAlign.center),
        paddedText('ผู้ซื้อ', align: TextAlign.center),
        paddedText('เลขประจําตัวผู้เสียภาษี', align: TextAlign.center),
        paddedText('รายการสินค้า', align: TextAlign.center),
        paddedText('น้ําหนัก (กรัม) \n(น.น.สินค้า/น.น.96.5)', align: TextAlign.center),
        paddedText('จํานวนเงิน (บาท)', align: TextAlign.center),
      ]),
      ...orders.map((e) => TableRow(
        decoration: const BoxDecoration(),
        children: [
          paddedText(
              Global.dateOnly(e!.orderDate.toString()), align: TextAlign.center),
          paddedText(e.orderId, align: TextAlign.center),
          paddedText(type == 1 ? '${e.customer!.firstName!} ${e.customer!.lastName!}' : 'รวมรายการทองเก่า\nประจําวัน', align: TextAlign.center),
          paddedText(Global.company != null
              ? Global.company!.taxNumber ?? ''
              : '', align: TextAlign.center),
          paddedText('ทองเก่า', align: TextAlign.center),
          paddedText('${type == 1 ? Global.format(getWeight(e)) : Global.format(e.weight!)}/${type == 1 ? Global.format(getWeight(e)) : Global.format(e.weight!)}', align: TextAlign.right),
          paddedText(Global.format(e.priceIncludeTax ?? 0), align: TextAlign.right)
        ],
      )),
      TableRow(children: [
        paddedText('', style: const TextStyle(fontSize: 14)),
        paddedText(''),
        paddedText(''),
        paddedText(''),
        paddedText('รวมท้ังหมด', align: TextAlign.right),
        paddedText('${type == 1 ? Global.format(getWeightTotal(orders)) : Global.format(getWeightTotalB(orders))}/${type == 1 ? Global.format(getWeightTotal(orders)) : Global.format(getWeightTotalB(orders))}', align: TextAlign.right),
        paddedText(Global.format(priceIncludeTaxTotal(orders)), align: TextAlign.right),
      ])
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
      Text(
          'วันที่ : ${Global.formatDate(DateTime.now().toString())}'),
      Spacer(),
      Text(
          'วันที่ : ${Global.formatDate(DateTime.now().toString())}')
    ],
  ));
  widgets.add(height());
  widgets.add(divider());
  widgets.add(height());
  widgets.add(Center(child: Text(
    "ตราประทับ",
    style: const TextStyle(fontSize: 25),
  )));
  widgets.add(height(h: 100));
  widgets.add(divider());

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
        pageFormat: const PdfPageFormat(1000, 1000),
        build: (context) => widgets,
        footer: (context) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('* น้ําหนักจะเป็นน้ําหนักในหน่วยของทอง 96.5%'),
                Text('${context.pageNumber} / ${context.pagesCount}')
              ]);
        }),
  );
  return pdf.save();
}

Widget paddedText(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 12)}) =>
    Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );