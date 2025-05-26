import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeBuyUsedGoldGovReportPdf(
    List<OrderModel?> orders, int type, String date) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);
  List<Widget> widgets = [];
  widgets.add(
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
  );
  widgets.add(height());
  widgets.add(
    Table(
      border: TableBorder.all(color: PdfColors.grey500),
      children: [
        TableRow(children: [
          paddedText('ลำดับ', align: TextAlign.center),
          paddedText('เลขที่ลำดับ\nตรงกับสิ่งของ', align: TextAlign.center),
          paddedText('ประเภท', align: TextAlign.center),
          paddedText('ลักษณะ', align: TextAlign.center),
          paddedText('ตำหนิ\nรูปพรรณ', align: TextAlign.center),
          paddedText('ขนาด', align: TextAlign.center),
          paddedText('น้ำหนักหรือ\nจำนวน', align: TextAlign.right),
          paddedText('หน่วย', align: TextAlign.center),
          paddedText('รับซื้อของจาก', align: TextAlign.center),
          paddedText('วัน/เดือน/ปี\nที่รับซื้อ', align: TextAlign.center),
          paddedText('ราคารับซื้อ\n(บาท)', align: TextAlign.right),
          paddedText('จำหน่ายให้แก่ใคร', align: TextAlign.center),
          paddedText('ราคาจำหน่าย\n(บาท)', align: TextAlign.right),
          paddedText('วัน/เดือน/ปี\nที่จำหน่าย', align: TextAlign.center),
          paddedText('หมายเหตุ', align: TextAlign.center),
        ]),
        for (int i = 0; i < orders.length; i++)
          TableRow(
            decoration: const BoxDecoration(),
            children: [
              paddedText('${i + 1}'),
              paddedText(orders[i]!.orderId, align: TextAlign.center),
              paddedText('ทองรูปพรรณ 96.5%', align: TextAlign.center),
              paddedText(' '),
              paddedText(' '),
              paddedText(' '),
              paddedText(
                  '${type == 1 ? Global.format(getWeight(orders[i])) : Global.format(orders[i]!.weight ?? 0)}',
                  align: TextAlign.right),
              paddedText('กรัม'),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                paddedText(
                    '${orders[i]!.customer?.firstName} ${orders[i]!.customer?.lastName} \n${orders[i]!.customer?.address} \nTel: ${orders[i]!.customer?.phoneNumber} \nID: ${orders[i]!.customer?.idCard}',
                    align: TextAlign.left),
              ]),
              paddedText(Global.dateOnly(orders[i]!.orderDate.toString()),
                  align: TextAlign.center),
              paddedText(Global.format(orders[i]!.priceIncludeTax ?? 0),
                  align: TextAlign.right),
              paddedText('', align: TextAlign.center),
              paddedText('', align: TextAlign.center),
              paddedText('', align: TextAlign.center),
              paddedText('', align: TextAlign.center),
            ],
          ),
      ],
    ),
  );

  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(20),
      // pageFormat: const PdfPageFormat(1000, 1000),
      pageFormat: PdfPageFormat.a4,
      orientation: PageOrientation.landscape,
      build: (context) => widgets,
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
