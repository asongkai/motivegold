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
    return PdfColors.green600;  // Stock IN = green
  } else if (lowerType.contains('out') || lowerType.contains('sale')) {
    return PdfColors.red600;    // Stock OUT = red
  } else {
    return PdfColors.grey600;
  }
}

Future<Uint8List> makeStockMovementReportPdf(
    List<StockMovementModel> list, int type) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  Widget buildHeader() {
    return Column(children: [
      Center(
        child: Column(children: [
          Text('${Global.company?.name}'),
          Text('(${Global.branch!.name})'),
          Text(
              '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
          Text('เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber}'),
          Text('TAX : INVOICE [ABB]/RECEIPT VAT INCLUDED)'),
          Text('POS Reg. No : '),
        ])),
      SizedBox(height: 10),
      Divider(
        height: 1,
        borderStyle: BorderStyle.dashed,
      ),
      Center(
        child: Text(
          'รายงานความเคลื่อนไหวสต๊อกสินค้า',
          style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
        ),
      ),
      Container(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ชื่อผู้ประกอบการ ${Global.branch!.name}"),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ชื่อสถานประกอบการ ${Global.company?.name}"),
          Text('ลําดับเลขที่สาขา ${Global.branch?.branchId}'),
        ],
      ),
      Container(height: 10),
      // Table column headers with white background
      Table(
        border: TableBorder(
          top: BorderSide(color: PdfColors.grey400, width: 0.5),
          bottom: BorderSide(color: PdfColors.grey400, width: 0.5),
          left: BorderSide(color: PdfColors.grey400, width: 0.5),
          right: BorderSide(color: PdfColors.grey400, width: 0.5),
          horizontalInside: BorderSide.none,
          verticalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
        columnWidths: const {
          0: FixedColumnWidth(70),
          1: FixedColumnWidth(70),
          2: FixedColumnWidth(90),
          3: FixedColumnWidth(70),
          4: FixedColumnWidth(80),
          5: FixedColumnWidth(70),
          6: FixedColumnWidth(70),
          7: FixedColumnWidth(70),
          8: FixedColumnWidth(70),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: PdfColors.white,
            ),
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              paddedTextSmall('เลขที่ใบ\nกํากับภาษ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('วัน/เดือน/ปี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('สินค้า',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('คลังสินค้า',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ประเภท\nการเคลื่อนไหว',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ประเภท\nเอกสาร',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('น้ำหนักรวม',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคา\nต่อหน่วย',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคารวม',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black
                  ),
                  align: TextAlign.right
              ),
            ]
          ),
        ],
      ),
    ]);
  }

  List<Widget> dataRows = [];

  // Mobile-inspired clean table design with smaller fonts
  dataRows.add(Container(
    decoration: BoxDecoration(
      border: Border.all(color: PdfColors.grey400, width: 0.5),
    ),
    child: Table(
      border: TableBorder(
        top: BorderSide.none,
        bottom: BorderSide.none,
        left: BorderSide.none,
        right: BorderSide.none,
        horizontalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
        verticalInside: BorderSide.none,
      ),
      columnWidths: const {
        0: FixedColumnWidth(70),
        1: FixedColumnWidth(70),
        2: FixedColumnWidth(90),
        3: FixedColumnWidth(70),
        4: FixedColumnWidth(80),
        5: FixedColumnWidth(70),
        6: FixedColumnWidth(70),
        7: FixedColumnWidth(70),
        8: FixedColumnWidth(70),
      },
      children: [
        // Clean data rows with color coding for movement type and numbers
        ...list.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final movementColor = getMovementTypeColor(e.type);

          return TableRow(
            decoration: BoxDecoration(color: i % 2 == 0 ? PdfColors.white : PdfColors.grey100),
            children: [
              paddedTextSmall(e.orderId!, style: TextStyle(fontSize: 11)),
              paddedTextSmall(Global.dateOnly(e.createdDate.toString()), style: TextStyle(fontSize: 11)),
              paddedTextSmall(e.product == null ? "" : e.product!.name, style: TextStyle(fontSize: 11)),
              paddedTextSmall(e.binLocation == null ? "" : e.binLocation!.name, style: TextStyle(fontSize: 11)),
              paddedTextSmall('${e.type!} ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: movementColor
                  )
              ),
              paddedTextSmall('${e.docType!} ', style: TextStyle(fontSize: 11)),
              paddedTextSmall('${e.product?.type == 'BAR' ? Global.format4(e.weight ?? 0) : Global.format(e.weight ?? 0)}',
                  style: TextStyle(fontSize: 11, color: movementColor),
                  align: TextAlign.right),
              paddedTextSmall(
                  ' ${Global.format6(e.unitCost ?? 0)}',
                  style: TextStyle(fontSize: 11),
                  align: TextAlign.right),
              paddedTextSmall(
                  ' ${Global.format6(e.price ?? 0)}',
                  style: TextStyle(fontSize: 11, color: movementColor),
                  align: TextAlign.right),
            ],
          );
        }),
        // Clean summary row
        TableRow(
          decoration: BoxDecoration(
            color: PdfColors.white,
            border: Border(
              top: BorderSide(color: PdfColors.grey400, width: 0.5),
            ),
          ),
          children: [
            paddedTextSmall('',
                style: const TextStyle(fontSize: 11)
            ),
            paddedTextSmall('',
                style: const TextStyle(fontSize: 11)
            ),
            paddedTextSmall('',
                style: const TextStyle(fontSize: 11)
            ),
            paddedTextSmall('',
                style: const TextStyle(fontSize: 11)
            ),
            paddedTextSmall('',
                style: const TextStyle(fontSize: 11)
            ),
            paddedTextSmall('รวมทั้งหมด',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.black
                ),
                align: TextAlign.center
            ),
            paddedTextSmall(
                Global.format4(list.fold(0.0, (sum, item) => sum + (item.weight ?? 0))),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.black
                ),
                align: TextAlign.right
            ),
            paddedTextSmall(
                Global.format6(list.fold(0.0, (sum, item) => sum + (item.unitCost ?? 0))),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.black
                ),
                align: TextAlign.right
            ),
            paddedTextSmall(
                Global.format6(list.fold(0.0, (sum, item) => sum + (item.price ?? 0))),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.black
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
      header: (context) => buildHeader(),
      build: (context) => dataRows,
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
      final TextStyle style = const TextStyle(fontSize: 11)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );