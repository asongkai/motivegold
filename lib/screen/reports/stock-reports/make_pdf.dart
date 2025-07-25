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

  // Original header (unchanged)
  widgets.add(Center(
      child: Column(children: [
        Text('${Global.company?.name}'),
        Text('(${Global.branch!.name})'),
        Text(
            '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
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

  // Mobile-inspired clean table design
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
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const FlexColumnWidth(2),
        1: const FlexColumnWidth(3),
        2: const FlexColumnWidth(2),
        3: const FlexColumnWidth(2),
        4: const FlexColumnWidth(3)
      },
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
              paddedTextBigXL('สินค้า',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextBigXL('คลังสินค้า',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextBigXL('น้ำหนักรวม',
                  align: TextAlign.right,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextBigXL('ราคาต่อ\nหน่วย',
                  align: TextAlign.right,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextBigXL('ราคารวม',
                  align: TextAlign.right,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
            ]
        ),
        // Clean white data rows
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
                Global.format6(e.unitCost ?? 0),
                style: const TextStyle(fontSize: 12),
                align: TextAlign.right),
            paddedTextBigXL(
                Global.format6(e.price ?? 0),
                style: const TextStyle(fontSize: 12),
                align: TextAlign.right),
          ],
        )),
        // Clean summary row
        TableRow(
          decoration: BoxDecoration(
            color: PdfColors.blue50,
            border: Border(
              top: BorderSide(color: PdfColors.blue200, width: 1),
            ),
          ),
          children: [
            paddedTextBigXL('',
                style: const TextStyle(fontSize: 14)
            ),
            paddedTextBigXL('รวมทั้งหมด',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.blue800
                ),
                align: TextAlign.center
            ),
            paddedTextBigXL(
                Global.format(list.fold(0.0, (sum, item) => sum + (item.weight ?? 0))),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.blue700
                ),
                align: TextAlign.right
            ),
            paddedTextBigXL(
                Global.format6(list.fold(0.0, (sum, item) => sum + (item.unitCost ?? 0))),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.orange700
                ),
                align: TextAlign.right
            ),
            paddedTextBigXL(
                Global.format6(list.fold(0.0, (sum, item) => sum + (item.price ?? 0))),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.green700
                ),
                align: TextAlign.right
            ),
          ],
        ),
      ],
    ),
  ));

  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(30),
      pageFormat: PdfPageFormat(
        PdfPageFormat.a4.height, // height becomes width
        PdfPageFormat.a4.width,  // width becomes height
      ),
      orientation: PageOrientation.landscape,
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