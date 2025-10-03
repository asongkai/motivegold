import 'dart:typed_data';

import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/model/stockmovement.dart';
import 'package:motivegold/utils/global.dart';

double weightLineTotal = 0;
double unitCostLineTotal = 0;
double priceLineTotal = 0;

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

Future<Uint8List> makeStockCardReportPdf(
    List<StockMovementModel> list,
    int type,
    WarehouseModel? warehouse,
    ProductModel? product,
    String? date,
    StockMovementModel? movement) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  weightLineTotal = movement?.weightBalance ?? 0;
  unitCostLineTotal = movement?.unitCostBalance ?? 0;
  priceLineTotal = movement?.priceBalance ?? 0;

  List<Widget> widgets = [];

  // Keep the original header format
  widgets.add(Center(
    child: Text(
      'รายงานความเคลื่อนไหวสต๊อกสินค้า',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
    ),
  ));
  widgets.add(Divider(
    height: 1,
    borderStyle: BorderStyle.dashed,
  ));
  widgets.add(SizedBox(height: 10));
  widgets.add(SizedBox(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('สินค้า: ${product?.name}'),
            Text('คลังสินค้า: ${warehouse?.name}'),
            Text('ระหว่างวันที่: $date'),
          ])));

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

  // Apply the modern design pattern from makeStockMovementReportPdf
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
              paddedTextSmall('เลขที่ใบ\nกํากับภาษ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('วัน/เดือน/ปี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('ประเภท\nการเคลื่อนไหว',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('น้ำหนักรวม\n(IN)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('น้ำหนักรวม\n(OUT)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('น้ำหนักรวม\n(Balance)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคาต่อหน่วย\n(IN)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคาต่อหน่วย\n(OUT)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคาต่อหน่วย\n(Balance)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคารวม\n(IN)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคารวม\n(OUT)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ราคารวม\n(Balance)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
            ]
        ),
        // Starting balance row with clean styling
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.blue50,
            ),
            children: [
              paddedTextSmall(''),
              paddedTextSmall(''),
              paddedTextSmall('จุดเริ่มต้นยอดคงเหลือ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800
                  )
              ),
              paddedTextSmall(''),
              paddedTextSmall(''),
              paddedTextSmall('${Global.format(movement?.weightBalance ?? 0)}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(''),
              paddedTextSmall(''),
              paddedTextSmall('${Global.format6(movement?.unitCostBalance ?? 0)}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.orange700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(''),
              paddedTextSmall(''),
              paddedTextSmall('${Global.format6(movement?.priceBalance ?? 0)}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700
                  ),
                  align: TextAlign.right),
            ]
        ),
        // Data rows with color coding
        for (int i = 0; i < list.length; i++)
          lineItem(list[i], movement, product),
        // Ending balance row with clean styling
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.blue50,
              border: Border(
                top: BorderSide(color: PdfColors.blue200, width: 1),
              ),
            ),
            children: [
              paddedTextSmall(''),
              paddedTextSmall(''),
              paddedTextSmall('ยอดคงเหลือสิ้นสุด',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800
                  )
              ),
              paddedTextSmall(''),
              paddedTextSmall(''),
              paddedTextSmall('${product?.type == 'BAR' ? Global.format4(weightLineTotal ?? 0) : Global.format(weightLineTotal ?? 0)}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(''),
              paddedTextSmall(''),
              paddedTextSmall('${Global.format6(unitCostLineTotal ?? 0)}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.orange700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(''),
              paddedTextSmall(''),
              paddedTextSmall('${Global.format6(priceLineTotal ?? 0)}',
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
    ),
  );
  return pdf.save();
}

TableRow lineItem(StockMovementModel list, StockMovementModel? movement, ProductModel? product) {
  weightLineTotal += list.weight ?? 0;
  unitCostLineTotal += list.unitCost ?? 0;
  priceLineTotal += list.price ?? 0;

  final movementColor = getMovementTypeColor(list.type);

  return TableRow(
    decoration: const BoxDecoration(),
    children: [
      paddedTextSmall(list.orderId!, style: TextStyle(fontSize: 10)),
      paddedTextSmall(Global.dateOnly(list.createdDate.toString()), style: TextStyle(fontSize: 10)),
      paddedTextSmall(list.type!,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: movementColor
          )
      ),
      if (list.weight! > 0)
        paddedTextSmall(' ${product?.type == 'BAR' ? Global.format4(list.weight ?? 0) : Global.format(list.weight ?? 0)}',
            style: TextStyle(fontSize: 10, color: PdfColors.green600),
            align: TextAlign.right),
      if (list.weight! < 0) paddedTextSmall(''),
      if (list.weight! < 0)
        paddedTextSmall(' ${product?.type == 'BAR' ? Global.format4(list.weight ?? 0) : Global.format(list.weight ?? 0)}',
            style: TextStyle(fontSize: 10, color: PdfColors.red600),
            align: TextAlign.right),
      if (list.weight! > 0) paddedTextSmall(''),
      paddedTextSmall('${product?.type == 'BAR' ? Global.format4(weightLineTotal) : Global.format(weightLineTotal)}',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: PdfColors.blue700
          ),
          align: TextAlign.right),
      if (list.unitCost! > 0)
        paddedTextSmall(' ${Global.format6(list.unitCost ?? 0)}',
            style: TextStyle(fontSize: 10, color: PdfColors.green600),
            align: TextAlign.right),
      if (list.unitCost! < 0) paddedTextSmall(''),
      if (list.unitCost! < 0)
        paddedTextSmall(' ${Global.format6(list.unitCost ?? 0)}',
            style: TextStyle(fontSize: 10, color: PdfColors.red600),
            align: TextAlign.right),
      if (list.unitCost! > 0) paddedTextSmall(''),
      paddedTextSmall(' ${Global.format6(unitCostLineTotal)}',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: PdfColors.orange700
          ),
          align: TextAlign.right),
      if (list.price! > 0)
        paddedTextSmall(' ${Global.format6(list.price ?? 0)}',
            style: TextStyle(fontSize: 10, color: PdfColors.green600),
            align: TextAlign.right),
      if (list.price! < 0) paddedTextSmall(''),
      if (list.price! < 0)
        paddedTextSmall(' ${Global.format6(list.price ?? 0)}',
            style: TextStyle(fontSize: 10, color: PdfColors.red600),
            align: TextAlign.right),
      if (list.price! > 0) paddedTextSmall(''),
      paddedTextSmall(' ${Global.format6(priceLineTotal)}',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: PdfColors.green700
          ),
          align: TextAlign.right),
    ],
  );
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