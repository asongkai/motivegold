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

Future<Uint8List> makeStockCardReportPdf(
    List<StockMovementModel> list,
    int type,
    WarehouseModel? warehouse,
    ProductModel? product,
    String? date,
    StockMovementModel? movement) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);
  // final imageLogo = MemoryImage(
  //     (await rootBundle.load('assets/images/app_icon2.png'))
  //         .buffer
  //         .asUint8List());
  // var data =
  //     await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf");
  // var font = Font.ttf(data);

  weightLineTotal = movement?.weightBalance ?? 0;
  unitCostLineTotal = movement?.unitCostBalance ?? 0;
  priceLineTotal = movement?.priceBalance ?? 0;

  List<Widget> widgets = [];

  // widgets.add(Center(
  //     child: Column(children: [
  //       Text('${Global.company?.name}'),
  //       Text('(${Global.branch?.name})'),
  //       //   Text('(สํานักงานใหญ่)'),
  //       //   Text('${Global.company?.name}'),
  //       Text(
  //           '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
  //       //   Text('${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
  //       Text('เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber}'),
  //     ])));

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

  widgets.add(Table(
    border: TableBorder.all(color: PdfColors.grey500),
    children: [
      TableRow(children: [
        paddedTextBig('เลขที่ใบ\nกํากับภาษ'),
        paddedTextBig('วัน/เดือน/ปี'),
        paddedTextBig('ประเภท\nการเคลื่อนไหว'),
        paddedTextBig('น้ำหนักรวม\n(IN)'),
        paddedTextBig('น้ำหนักรวม\n(OUT)'),
        paddedTextBig('น้ำหนักรวม\n(Balance)'),
        paddedTextBig('ราคาต่อหน่วย\n(IN)'),
        paddedTextBig('ราคาต่อหน่วย\n(OUT)'),
        paddedTextBig('ราคาต่อหน่วย\n(Balance)'),
        paddedTextBig('ราคารวม\n(IN)'),
        paddedTextBig('ราคารวม\n(OUT)'),
        paddedTextBig('ราคารวม\n(Balance)'),
      ]),
      TableRow(children: [
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig('จุดเริ่มต้นยอดคงเหลือ'),
        paddedTextBig('${Global.format(movement?.weightBalance ?? 0)}',
            align: TextAlign.right),
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig('${Global.format6(movement?.unitCostBalance ?? 0)}',
            align: TextAlign.right),
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig('${Global.format6(movement?.priceBalance ?? 0)}',
            align: TextAlign.right),
      ]),
      for (int i = 0; i < list.length; i++)
        lineItem(list[i], movement),
      TableRow(children: [
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig('ยอดคงเหลือสิ้นสุด'),
        paddedTextBig('${Global.format(weightLineTotal ?? 0)}',
            align: TextAlign.right),
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig('${Global.format6(unitCostLineTotal ?? 0)}',
            align: TextAlign.right),
        paddedTextBig(''),
        paddedTextBig(''),
        paddedTextBig('${Global.format6(priceLineTotal ?? 0)}',
            align: TextAlign.right),
      ]),
      // TableRow(
      //   decoration: const BoxDecoration(),
      //   children: [
      //     paddedTextBig(list[i].orderId!),
      //     paddedTextBig(Global.dateOnly(list[i].createdDate.toString())),
      //     paddedTextBig(list[i].type!),
      //     if (list[i].weight! > 0)
      //       paddedTextBig(' ${Global.format(list[i].weight ?? 0)}',
      //           style: const TextStyle(fontSize: 16),
      //           align: TextAlign.right),
      //     if (list[i].weight! < 0) paddedTextBig(''),
      //     if (list[i].weight! < 0)
      //       paddedTextBig(' ${Global.format(list[i].weight ?? 0)}',
      //           style: const TextStyle(fontSize: 16),
      //           align: TextAlign.right),
      //     if (list[i].weight! > 0) paddedTextBig(''),
      //     paddedTextBig(
      //         '${Global.format(weightLineTotal)}'),
      //     paddedTextBig(' ${Global.format(list[i].weight ?? 0)}',
      //         style: const TextStyle(fontSize: 16), align: TextAlign.right),
      //     paddedTextBig(' ${Global.format6(list[i].unitCost ?? 0)}',
      //         style: const TextStyle(fontSize: 16), align: TextAlign.right),
      //     paddedTextBig(' ${Global.format6(list[i].price ?? 0)}',
      //         style: const TextStyle(fontSize: 16), align: TextAlign.right),
      //   ],
      // ),
      // ...list.map((e) => TableRow(
      //       decoration: const BoxDecoration(),
      //       children: [
      //         paddedTextBig(e.orderId!),
      //         paddedTextBig(Global.dateOnly(e.createdDate.toString())),
      //         paddedTextBig(e.type!),
      //         if (e.weight! > 0)
      //           paddedTextBig(' ${Global.format(e.weight ?? 0)}',
      //               style: const TextStyle(fontSize: 16),
      //               align: TextAlign.right),
      //         if (e.weight! < 0) paddedTextBig(''),
      //         if (e.weight! < 0)
      //           paddedTextBig(' ${Global.format(e.weight ?? 0)}',
      //               style: const TextStyle(fontSize: 16),
      //               align: TextAlign.right),
      //         if (e.weight! > 0) paddedTextBig(''),
      //         paddedTextBig(''),
      //         paddedTextBig(' ${Global.format(e.weight ?? 0)}',
      //             style: const TextStyle(fontSize: 16), align: TextAlign.right),
      //         paddedTextBig(' ${Global.format6(e.unitCost ?? 0)}',
      //             style: const TextStyle(fontSize: 16), align: TextAlign.right),
      //         paddedTextBig(' ${Global.format6(e.price ?? 0)}',
      //             style: const TextStyle(fontSize: 16), align: TextAlign.right),
      //       ],
      //     )),
      // TableRow(children: [
      //   paddedTextBig('', style: const TextStyle(fontSize: 14)),
      //   paddedTextBig(''),
      //   paddedTextBig(''),
      //   paddedTextBig('รวมท้ังหมด'),
      //   paddedTextBig(Global.format(getWeightTotal(ods))),
      //   paddedTextBig(''),
      //   paddedTextBig(Global.format(priceIncludeTaxTotal(ods))),
      //   paddedTextBig(Global.format(purchasePriceTotal(ods))),
      //   paddedTextBig(Global.format(priceDiffTotal(ods))),
      //   paddedTextBig(Global.format(taxBaseTotal(ods))),
      //   paddedTextBig(Global.format(taxAmountTotal(ods))),
      //   paddedTextBig(Global.format(priceExcludeTaxTotal(ods))),
      // ])
    ],
  ));

  pdf.addPage(
    MultiPage(
      // maxPages: 100,
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



lineItem(StockMovementModel list, StockMovementModel? movement) {

  weightLineTotal += list.weight ?? 0;
  unitCostLineTotal += list.unitCost ?? 0;
  priceLineTotal += list.price ?? 0;

  return TableRow(
    decoration: const BoxDecoration(),
    children: [
      paddedTextBig(list.orderId!),
      paddedTextBig(Global.dateOnly(list.createdDate.toString())),
      paddedTextBig(list.type!),
      if (list.weight! > 0)
        paddedTextBig(' ${Global.format(list.weight ?? 0)}',
            style: const TextStyle(fontSize: 16),
            align: TextAlign.right),
      if (list.weight! < 0) paddedTextBig(''),
      if (list.weight! < 0)
        paddedTextBig(' ${Global.format(list.weight ?? 0)}',
            style: const TextStyle(fontSize: 16),
            align: TextAlign.right),
      if (list.weight! > 0) paddedTextBig(''),
      paddedTextBig(
          '${Global.format(weightLineTotal)}'),
      if (list.unitCost! > 0)
      paddedTextBig(' ${Global.format6(list.unitCost ?? 0)}',
          style: const TextStyle(fontSize: 16), align: TextAlign.right),
      if (list.unitCost! < 0) paddedTextBig(''),
      if (list.unitCost! < 0)
        paddedTextBig(' ${Global.format6(list.unitCost ?? 0)}',
            style: const TextStyle(fontSize: 16), align: TextAlign.right),
      if (list.unitCost! > 0) paddedTextBig(''),
      paddedTextBig(' ${Global.format6(unitCostLineTotal)}',
          style: const TextStyle(fontSize: 16), align: TextAlign.right),
      if (list.price! > 0)
      paddedTextBig(' ${Global.format6(list.price ?? 0)}',
          style: const TextStyle(fontSize: 16), align: TextAlign.right),
      if (list.price! < 0) paddedTextBig(''),
      if (list.price! < 0)
        paddedTextBig(' ${Global.format6(list.price ?? 0)}',
            style: const TextStyle(fontSize: 16), align: TextAlign.right),
      if (list.price! > 0) paddedTextBig(''),
      paddedTextBig(' ${Global.format6(priceLineTotal)}',
          style: const TextStyle(fontSize: 16), align: TextAlign.right),
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

Widget paddedTextBig(final String text,
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
