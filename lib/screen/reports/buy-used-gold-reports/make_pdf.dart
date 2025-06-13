import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeBuyUsedGoldReportPdf(
    List<OrderModel?> orders, int type, String date) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);
  List<Widget> widgets = [];
  widgets.add(Center(
    child: Text(
      'รายงานซื้อทองรูปพรรณเก่า 96.5%',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
    ),
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
          "ชื่อผู้ประกอบการ: ${Global.company!.name} (${Global.branch?.name}) เลขประจําตัวผู้เสียภาษี: ${Global.company?.taxNumber}"),
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
          "ที่อยู่: ${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}"),
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("ระหว่างวันที่: $date"),
      Text('วันที่พิมพ์: ${Global.formatDate(DateTime.now().toString())}'),
    ],
  ));
  widgets.add(height());
  widgets.add(Table(
    border: TableBorder.all(color: PdfColors.grey500),
    children: [
      TableRow(children: [
        paddedText('วัน/เดือน/ปี', align: TextAlign.center),
        paddedText('เลขท่ีใบสําคัญรับเงิน', align: TextAlign.center),
        paddedText('ผู้ขาย', align: TextAlign.center),
        paddedText('เลขประจําตัวผู้เสียภาษี', align: TextAlign.center),
        paddedText('รายการสินค้า', align: TextAlign.center),
        paddedText('น้ําหนัก (กรัม)', align: TextAlign.center),
        paddedText('จํานวนเงิน (บาท)', align: TextAlign.center),
      ]),
      ...orders.map((e) => TableRow(
        decoration: const BoxDecoration(),
        children: [
          paddedText(
              Global.dateOnly(e!.orderDate.toString()), align: TextAlign.center),
          paddedText(e.orderId, align: TextAlign.center),
          paddedText(type == 1 ? '${e.customer!.firstName!} ${e.customer!.lastName!}' : 'รวมรายการทองเก่า\nประจําวัน', align: TextAlign.center),
          paddedText(
              e.customer?.taxNumber != ''
                  ? e.customer?.taxNumber ?? ''
                  : e.customer?.idCard ?? '',
              align: TextAlign.center),
          paddedText('ทองเก่า', align: TextAlign.center),
          paddedText('${type == 1 ? Global.format(getWeight(e)) : Global.format(e.weight!)}', align: TextAlign.right),
          paddedText(Global.format(e.priceIncludeTax ?? 0), align: TextAlign.right)
        ],
      )),
      TableRow(children: [
        paddedText('', style: const TextStyle(fontSize: 14)),
        paddedText(''),
        paddedText(''),
        paddedText(''),
        paddedText('รวมท้ังหมด', align: TextAlign.right),
        paddedText('${type == 1 ? Global.format(getWeightTotal(orders)) : Global.format(getWeightTotalB(orders))}', align: TextAlign.right),
        paddedText(Global.format(priceIncludeTaxTotal(orders)), align: TextAlign.right),
      ])
    ],
  ));

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
        // pageFormat: const PdfPageFormat(1000, 1000),
        pageFormat: PdfPageFormat(
          PdfPageFormat.a4.height, // height becomes width
          PdfPageFormat.a4.width,  // width becomes height
        ),
        orientation: PageOrientation.landscape,
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