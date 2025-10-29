import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeBuyUsedGoldGovReportPdf(
    List<OrderModel?> orders, int type, String date) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  Widget buildHeader() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('บัญชีสำหรับผู้ทำการค้าของเก่า (ประเภททองรูปพรรณและทองคำแท่ง)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(
                  'สถานประกอบอาชีพ : ${Global.company?.name} (${Global.branch!.name})',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(
                  'ที่อยู่ : ${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('ใบอนุญาตเลขที่ : ${Global.branch?.oldGoldLicenseNumber}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
      height(),
      Container(
        decoration: BoxDecoration(
          color: PdfColors.blue600,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(11),
            topRight: Radius.circular(11),
          ),
        ),
        padding: EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Text('ลำดับ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 30,
              child: Text('เลขที่ลำดับ\nตรงกับสิ่งของ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 30,
              child: Text('ประเภท',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 20,
              child: Text('ลักษณะ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 20,
              child: Text('ตำหนิ\nรูปพรรณ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 20,
              child: Text('ขนาด',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 20,
              child: Text('น้ำหนักหรือ\nจำนวน',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 20,
              child: Text('หน่วย',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 60,
              child: Text('รับซื้อของจาก',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 40,
              child: Text('วัน/เดือน/ปี\nที่รับซื้อ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 30,
              child: Text('ราคารับซื้อ\n(บาท)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 20,
              child: Text('จำหน่ายให้แก่ใคร',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 20,
              child: Text('ราคาจำหน่าย\n(บาท)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 20,
              child: Text('วัน/เดือน/ปี\nที่จำหน่าย',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
            Expanded(
              flex: 20,
              child: Text('หมายเหตุ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
            ),
          ],
        ),
      ),
    ]);
  }

  List<Widget> dataRows = [];

  // Apply modern design pattern
  dataRows.add(Container(
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
      columnWidths: {
        0: const FixedColumnWidth(10),
        1: const FixedColumnWidth(30),
        2: const FixedColumnWidth(30),
        3: const FixedColumnWidth(20),
        4: const FixedColumnWidth(20),
        5: const FixedColumnWidth(20),
        6: const FixedColumnWidth(20),
        7: const FixedColumnWidth(20),
        8: const FixedColumnWidth(60),
        9: const FixedColumnWidth(40),
        10: const FixedColumnWidth(30),
        11: const FixedColumnWidth(20),
        12: const FixedColumnWidth(20),
        13: const FixedColumnWidth(20),
        14: const FixedColumnWidth(20)
      },
      children: [
        // Data rows with color coding
        for (int i = 0; i < orders.length; i++)
          TableRow(
            decoration: const BoxDecoration(),
            children: [
              paddedTextSmall('${i + 1}', style: TextStyle(fontSize: 10)),
              paddedTextSmall(orders[i]!.orderId,
                  style: TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedTextSmall('ทองรูปพรรณ 96.5%',
                  style: TextStyle(fontSize: 10, color: PdfColors.red600, fontWeight: FontWeight.bold),
                  align: TextAlign.center),
              paddedTextSmall(' ', style: TextStyle(fontSize: 10)),
              paddedTextSmall(' ', style: TextStyle(fontSize: 10)),
              paddedTextSmall(' ', style: TextStyle(fontSize: 10)),
              paddedTextSmall(
                  '${type == 1 ? Global.format(getWeight(orders[i])) : Global.format(orders[i]!.weight ?? 0)}',
                  style: TextStyle(fontSize: 10, color: PdfColors.blue600),
                  align: TextAlign.right),
              paddedTextSmall('กรัม',
                  style: TextStyle(fontSize: 10),
                  align: TextAlign.center),
              Container(
                  padding: EdgeInsets.all(4),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text( 
                            '${getCustomerName(orders[i]!.customer!)}',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('${orders[i]!.customer?.address}',
                            style: TextStyle(fontSize: 10)),
                        Text('Tel: ${orders[i]!.customer?.phoneNumber}',
                            style: TextStyle(fontSize: 10, color: PdfColors.purple600)),
                        Text('ID: ${orders[i]!.customer?.idCard}',
                            style: TextStyle(fontSize: 10, color: PdfColors.teal600)),
                      ]
                  )
              ),
              paddedTextSmall(Global.dateOnly(orders[i]!.orderDate.toString()),
                  style: TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedTextSmall(Global.format(orders[i]!.priceIncludeTax ?? 0),
                  style: TextStyle(fontSize: 10, color: PdfColors.red600),
                  align: TextAlign.right),
              paddedTextSmall('',
                  style: TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedTextSmall('',
                  style: TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedTextSmall('',
                  style: TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedTextSmall('',
                  style: TextStyle(fontSize: 10),
                  align: TextAlign.center),
            ],
          ),
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
            paddedTextSmall('', style: const TextStyle(fontSize: 10)),
            paddedTextSmall('รวมท้ังหมด',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.blue800
                ),
                align: TextAlign.right),
            paddedTextSmall(
                type == 1
                    ? Global.format(orders.fold(0.0, (sum, order) => sum + getWeight(order)))
                    : Global.format(orders.fold(0.0, (sum, order) => sum + (order?.weight ?? 0))),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.blue700
                ),
                align: TextAlign.right),
            paddedTextSmall('กรัม',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.blue800
                ),
                align: TextAlign.center),
            paddedTextSmall('', style: const TextStyle(fontSize: 10)),
            paddedTextSmall('', style: const TextStyle(fontSize: 10)),
            paddedTextSmall(Global.format(orders.fold(0.0, (sum, order) => sum + (order?.priceIncludeTax ?? 0))),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.red700
                ),
                align: TextAlign.right),
            paddedTextSmall('', style: const TextStyle(fontSize: 10)),
            paddedTextSmall('', style: const TextStyle(fontSize: 10)),
            paddedTextSmall('', style: const TextStyle(fontSize: 10)),
            paddedTextSmall('', style: const TextStyle(fontSize: 10)),
          ],
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
      header: (context) => buildHeader(),
      build: (context) => dataRows,
      footer: (context) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(' '),
              Text('${context.pageNumber} / ${context.pagesCount}')
            ]);
      },
    ),
  );
  return pdf.save();
}

Widget paddedTextSmall(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 10)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );