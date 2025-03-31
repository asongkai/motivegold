import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeNewGoldReportPdf(
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
      'รายงานขายทองรูปพรรณใหม่ 96.5%',
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
        paddedText('ลำดับ'),
        paddedText('เลขที่ใบกํากับภาษี'),
        paddedText('วันที่'),
        paddedText('เวลา'),
        paddedText('ชื่อผู้ซื้อ'),
        paddedText('เลขประจําตัวผู้เสียภาษี'),
        paddedText('น้ําหนักรวม\n(กรัม)'),
        paddedText('ยอดขายรวม\nภาษีมูลค่าเพิ่ม'),
        paddedText('มูลค่ายกเว้น'),
        paddedText('ผลต่างรวม\nภาษีมูลค่าเพิ่ม'),
        paddedText('ฐานภาษีมูลค่าเพิ่ม'),
        paddedText('ภาษีมูลค่าเพิ่ม'),
        paddedText('ยอดขายที่ไม่รวม\nภาษีมูลค่าเพิ่ม'),
      ]),
      for (int i = 0; i < orders.length; i++)
        TableRow(
          decoration: const BoxDecoration(),
          children: [
            paddedText('${i + 1}'),
            paddedText(orders[i]!.orderId),
            paddedText(Global.dateOnly(orders[i]!.createdDate.toString())),
            paddedText(Global.timeOnlyF(orders[i]!.createdDate.toString())),
            paddedText(
                '${orders[i]!.customer?.firstName} ${orders[i]!.customer?.lastName}'),
            paddedText(orders[i]!.customer?.taxNumber != ''
                ? orders[i]!.customer?.taxNumber ?? ''
                : orders[i]!.customer?.idCard ?? ''),
            paddedText(
                type == 1
                    ? Global.format(getWeight(orders[i]!))
                    : Global.format(orders[i]!.weight!),
                align: TextAlign.right),
            paddedText(Global.format(orders[i]!.priceIncludeTax ?? 0),
                align: TextAlign.right),
            paddedText(Global.format(orders[i]!.purchasePrice ?? 0),
                align: TextAlign.right),
            paddedText(Global.format(orders[i]!.priceDiff ?? 0),
                align: TextAlign.right),
            paddedText(Global.format(orders[i]!.taxBase ?? 0),
                align: TextAlign.right),
            paddedText(Global.format(orders[i]!.taxAmount ?? 0),
                align: TextAlign.right),
            paddedText(Global.format(orders[i]!.priceExcludeTax ?? 0),
                align: TextAlign.right)
          ],
        ),
      TableRow(children: [
        paddedText('', style: const TextStyle(fontSize: 14)),
        paddedText(''),
        paddedText(''),
        paddedText(''),
        paddedText(''),
        paddedText('รวมท้ังหมด'),
        paddedText(
            type == 1
                ? Global.format(getWeightTotal(orders))
                : Global.format(getWeightTotalB(orders)),
            align: TextAlign.right),
        paddedText(Global.format(priceIncludeTaxTotal(orders)),
            align: TextAlign.right),
        paddedText(Global.format(purchasePriceTotal(orders)),
            align: TextAlign.right),
        paddedText(Global.format(priceDiffTotal(orders)),
            align: TextAlign.right),
        paddedText(Global.format(taxBaseTotal(orders)), align: TextAlign.right),
        paddedText(Global.format(taxAmountTotal(orders)),
            align: TextAlign.right),
        paddedText(Global.format(priceExcludeTaxTotal(orders)),
            align: TextAlign.right),
      ])
    ],
  ));

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
        final TextStyle style = const TextStyle(fontSize: 10)}) =>
    Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );
