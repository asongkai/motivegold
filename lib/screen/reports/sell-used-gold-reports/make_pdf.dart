import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeSellUsedGoldReportPdf(
    List<OrderModel?> orders, int type, String date) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  List<Widget> widgets = [];

  widgets.add(Center(
    child: Text(
      'รายงานขายทองรูปพรรณเก่า 96.5%',
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

  // Apply modern design pattern
  widgets.add(Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: PdfColors.grey300, width: 1),
    ),
    child: Table(
      border: TableBorder(
        top: BorderSide.none,
        bottom: BorderSide.none,
        left: BorderSide.none,
        right: BorderSide.none,
        horizontalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
        verticalInside: BorderSide.none,
      ),
      children: [
        // Clean header row with rounded top corners
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.blue600,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            children: [
              paddedTextSmall('วัน/เดือน/ปี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('เลขท่ีใบสําคัญ\nรับเงิน',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ชื่อผู้ซื้อ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('รายการสินค้า',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('น้ําหนัก\n(กรัม)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('จํานวนเงิน\n(บาท)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
            ]
        ),
        // Data rows with color coding
        ...orders.map((e) => TableRow(
          decoration: const BoxDecoration(),
          children: [
            paddedTextSmall(Global.dateOnly(e!.orderDate.toString()),
                style: TextStyle(fontSize: 10),
                align: TextAlign.center),
            paddedTextSmall(e.orderId,
                style: TextStyle(fontSize: 10),
                align: TextAlign.center),
            paddedTextSmall(
                type == 1
                    ? '${getCustomerName(e.customer!)}'
                    : 'รวมรายการทองเก่า\nประจําวัน',
                style: TextStyle(fontSize: 10),
                align: TextAlign.center),
            paddedTextSmall(e.customer?.taxNumber != ''
                ? e.customer?.taxNumber ?? ''
                : e.customer?.idCard ?? '',
                style: TextStyle(fontSize: 10),
                align: TextAlign.center),
            paddedTextSmall('ทองเก่า',
                style: TextStyle(fontSize: 10, color: PdfColors.orange600, fontWeight: FontWeight.bold),
                align: TextAlign.center),
            paddedTextSmall(
                '${type == 1 ? Global.format(getWeight(e)) : Global.format(e.weight!)}',
                style: TextStyle(fontSize: 10, color: PdfColors.blue600),
                align: TextAlign.right),
            paddedTextSmall(Global.format(e.priceIncludeTax ?? 0),
                style: TextStyle(fontSize: 10, color: PdfColors.green600),
                align: TextAlign.right)
          ],
        )),
        // Summary row with clean styling
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.blue50,
              border: Border(
                top: BorderSide(color: PdfColors.blue200, width: 1),
              ),
            ),
            children: [
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800
                  ),
                  align: TextAlign.right),
              paddedTextSmall(
                  '${type == 1 ? Global.format(getWeightTotal(orders)) : Global.format(getWeightTotalB(orders))}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700
                  ),
                  align: TextAlign.right),
            ]
        ),
      ],
    ),
  ));

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
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

Widget paddedTextSmall(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 11)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );