import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/model/stockmovement.dart';
import 'package:motivegold/utils/global.dart';

// Helper function to get movement type color for PDF
PdfColor getMovementTypeColor(String? type) {
  if (type == null) return PdfColors.grey600;

  String lowerType = type.toLowerCase();
  if (lowerType.contains('in')) {
    return PdfColors.green600;
  } else if (lowerType.contains('out') || lowerType.contains('sale')) {
    return PdfColors.red600;
  } else {
    return PdfColors.grey600;
  }
}

Future<Uint8List> makeStockMovementReportPdf(
    List<StockMovementModel> list, int type) async {
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
  widgets.add(SizedBox(height: 10));
  widgets.add(Divider(
    height: 1,
    borderStyle: BorderStyle.dashed,
  ));
  widgets.add(Center(
    child: Text(
      'รายงานความเคลื่อนไหวสต๊อกสินค้า',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
    ),
  ));
  widgets.add(Container(height: 10));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("ชื่อผู้ประกอบการ ${Global.branch!.name}"),
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("ชื่อสถานประกอบการ ${Global.company?.name}"),
      Text('ลําดับเลขที่สาขา ${Global.branch?.branchId}'),
    ],
  ));
  widgets.add(Container(height: 10));

  // Mobile-inspired clean table design with smaller fonts
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
        // Clean header row with rounded top corners and smaller fonts
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.blue600,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            children: [
              paddedTextSmall('เลขที่ใบ\nกํากับภาษ',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('วัน/เดือน/ปี',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('สินค้า',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('คลังสินค้า',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('ประเภท\nการเคลื่อนไหว',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('ประเภท\nเอกสาร',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('น้ำหนักรวม',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคา\nต่อหน่วย',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคารวม',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
            ]
        ),
        // Clean data rows with color coding for movement type and numbers
        ...list.map((e) {
          final movementColor = getMovementTypeColor(e.type);

          return TableRow(
            decoration: const BoxDecoration(),
            children: [
              paddedTextSmall(e.orderId!),
              paddedTextSmall(Global.dateOnly(e.createdDate.toString())),
              paddedTextSmall(e.product == null ? "" : e.product!.name),
              paddedTextSmall(e.binLocation == null ? "" : e.binLocation!.name),
              paddedTextSmall('${e.type!} ',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: movementColor
                  )
              ),
              paddedTextSmall('${e.docType!} '),
              paddedTextSmall(' ${Global.format(e.weight ?? 0)}',
                  style: TextStyle(fontSize: 10, color: movementColor),
                  align: TextAlign.right),
              paddedTextSmall(
                  ' ${Global.format6(e.unitCost ?? 0)}',
                  style: TextStyle(fontSize: 10),
                  align: TextAlign.right),
              paddedTextSmall(
                  ' ${Global.format6(e.price ?? 0)}',
                  style: TextStyle(fontSize: 10, color: movementColor),
                  align: TextAlign.right),
            ],
          );
        }),
        // Clean summary row
        TableRow(
          decoration: BoxDecoration(
            color: PdfColors.blue50,
            border: Border(
              top: BorderSide(color: PdfColors.blue200, width: 1),
            ),
          ),
          children: [
            paddedTextSmall('',
                style: const TextStyle(fontSize: 9)
            ),
            paddedTextSmall('',
                style: const TextStyle(fontSize: 9)
            ),
            paddedTextSmall('',
                style: const TextStyle(fontSize: 9)
            ),
            paddedTextSmall('',
                style: const TextStyle(fontSize: 9)
            ),
            paddedTextSmall('',
                style: const TextStyle(fontSize: 9)
            ),
            paddedTextSmall('รวมทั้งหมด',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.blue800
                ),
                align: TextAlign.center
            ),
            paddedTextSmall(
                Global.format(list.fold(0.0, (sum, item) => sum + (item.weight ?? 0))),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.blue700
                ),
                align: TextAlign.right
            ),
            paddedTextSmall(
                Global.format6(list.fold(0.0, (sum, item) => sum + (item.unitCost ?? 0))),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.orange700
                ),
                align: TextAlign.right
            ),
            paddedTextSmall(
                Global.format6(list.fold(0.0, (sum, item) => sum + (item.price ?? 0))),
                style: TextStyle(
                    fontSize: 11,
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
      margin: const EdgeInsets.all(20),
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

Widget paddedTextSmall(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 9)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );