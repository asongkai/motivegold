import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeSellVatReportPdf(List<OrderModel?> orders, int type,
    String date, DateTime fromDate, DateTime toDate) async {
  List<OrderModel> list = [];

  int days = Global.daysBetween(fromDate, toDate);

  for (int j = 0; j <= days; j++) {
    var indexDay = fromDate.add(Duration(days: j));
    for (int i = 0; i < orders.length; i++) {
      if (orders[i]!.createdDate == indexDay) {
        list.add(orders[i]!);
      } else {
        var checkExisting =
            list.where((e) => e.createdDate == indexDay).toList();
        if (checkExisting.isEmpty) {
          list.add(OrderModel(
              orderId: 'หยุดทำการ/ไม่มียอดขาย',
              orderDate: indexDay,
              customer: orders[i]!.customer));
        }
      }
    }
  }

  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);
  List<Widget> widgets = [];
  // widgets.add(Center(
  //     child: Column(children: [
  //       Text('${Global.company?.name} (${Global.branch!.name})',
  //           style:
  //           TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  //       Text(
  //           '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}',
  //           style:
  //           TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  //       Text(
  //           'เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber} โทร ${Global.company?.phone}',
  //           style:
  //           TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  //     ])));
  widgets.add(height());
  widgets.add(Center(
    child: Text(
      'รายงานภาษีมูลค่าเพิม : รายงานภาษีขายทองคํารูปพรรณใหม่',
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: 20,
          fontWeight: FontWeight.bold),
    ),
  ));
  widgets.add(Center(
    child: Text(
      'ระหว่างวันที่: $date',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 18),
    ),
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text("ชื่อผู้ประกอบการ: "),
            ),
            Expanded(
                flex: 6,
                child: Text('${Global.company!.name} (${Global.branch!.name})'))
          ],
        ),
      ),
      Expanded(
        child: Text(' ', textAlign: TextAlign.right),
      )
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text("ทีอยู่: "),
            ),
            Expanded(
                flex: 6,
                child: Text(
                    '${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}'))
          ],
        ),
      ),
      Expanded(
        child: Text(' ', textAlign: TextAlign.right),
      )
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text("เลขประจําตัวผู้เสียภาษี: "),
            ),
            Expanded(flex: 6, child: Text(Global.company?.taxNumber ?? ''))
          ],
        ),
      ),
      Expanded(
        child: Text(
            'วันทีพิมพ์ ${Global.formatDate(DateTime.now().toString())} ',
            textAlign: TextAlign.right),
      )
    ],
  ));
  widgets.add(height());
  widgets.add(Table(
    border: TableBorder.all(color: PdfColors.grey500),
    children: [
      TableRow(
        verticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          paddedText('ลําดับ', align: TextAlign.center),
          if (type == 2) paddedText('วันที', align: TextAlign.center),
          if (type == 1)
            paddedText('เลขที่\nใบกํากับภาษี', align: TextAlign.center),
          if (type == 1) paddedText('วันที', align: TextAlign.center),
          if (type == 1) paddedText('เวลา', align: TextAlign.center),
          if (type == 1) paddedText('ชือผู้ซือ', align: TextAlign.center),
          if (type == 1)
            paddedText('เลขประจําตัว\nผู้เสียภาษี', align: TextAlign.center),
          if (type == 2)
            paddedText('เลขที่\nใบกํากับภาษี', align: TextAlign.center),
          if (type == 2) paddedText('รายการสินค้า', align: TextAlign.center),
          paddedText('นําหนักรวม\n(กรัม)', align: TextAlign.right),
          paddedText('ยอดขายรวมภาษี\nมูลค่าเพิม\nจำนวนเงิน (บาท)',
              align: TextAlign.right),
          paddedText('มูลค่ายกเว้นภาษี\nมูลค่าเพิม\nจำนวนเงิน (บาท)',
              align: TextAlign.right),
          paddedText('ผลต่างรวมภาษี\nมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
              align: TextAlign.right),
          paddedText('ฐานภาษี\nมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
              align: TextAlign.right),
          paddedText('ภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
              align: TextAlign.right),
          paddedText('ยอดขายไม่รวมภาษี\nมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
              align: TextAlign.right),
        ],
      ),
      if (type == 1)
        for (int i = 0; i < orders.length; i++)
          TableRow(
            verticalAlignment: TableCellVerticalAlignment.middle,
            decoration: const BoxDecoration(),
            children: [
              paddedText('${i + 1}'),
              paddedText(orders[i]!.orderId),
              paddedText(Global.dateOnly(orders[i]!.orderDate.toString())),
              paddedText(Global.timeOnlyF(orders[i]!.orderDate.toString())),
              paddedText(
                  '${orders[i]!.customer?.firstName} ${orders[i]!.customer?.lastName} '),
              paddedText(orders[i]!.customer?.taxNumber != null
                  ? orders[i]!.customer?.taxNumber ?? ''
                  : ''),
              paddedText(Global.format(getWeight(orders[i]!)),
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
      if (type == 2)
        for (int i = 0; i < list.length; i++)
          TableRow(
            verticalAlignment: TableCellVerticalAlignment.middle,
            decoration: const BoxDecoration(),
            children: [
              paddedText('${i + 1}'),
              paddedText(Global.dateOnly(list[i].orderDate.toString())),
              paddedText(list[i].orderId),
              paddedText('ทองคำรูปพรรณ 96.5%'),
              paddedText(
                  list[i].weight == null ? '' : Global.format(list[i].weight!),
                  align: TextAlign.right),
              paddedText(
                  list[i].priceIncludeTax == null
                      ? ''
                      : Global.format(list[i].priceIncludeTax ?? 0),
                  align: TextAlign.right),
              paddedText(
                  list[i].purchasePrice == null
                      ? ''
                      : Global.format(list[i].purchasePrice ?? 0),
                  align: TextAlign.right),
              paddedText(
                  list[i].priceDiff == null
                      ? ''
                      : Global.format(list[i].priceDiff ?? 0),
                  align: TextAlign.right),
              paddedText(
                  list[i].taxBase == null
                      ? ''
                      : Global.format(list[i].taxBase ?? 0),
                  align: TextAlign.right),
              paddedText(
                  list[i].taxAmount == null
                      ? ''
                      : Global.format(list[i].taxAmount ?? 0),
                  align: TextAlign.right),
              paddedText(
                  list[i].priceExcludeTax == null
                      ? ''
                      : Global.format(list[i].priceExcludeTax ?? 0),
                  align: TextAlign.right)
            ],
          ),
      TableRow(verticalAlignment: TableCellVerticalAlignment.middle, children: [
        paddedText(''),
        paddedText(''),
        if (type == 1) paddedText(''),
        if (type == 1) paddedText(''),
        if (type == 1) paddedText(''),
        if (type == 2) paddedText(''),
        paddedText('รวมท้ังหมด',
            align: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        paddedText(
            type == 1
                ? Global.format(getWeightTotal(orders))
                : Global.format(getWeightTotalB(orders)),
            align: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        paddedText(Global.format(priceIncludeTaxTotal(orders)),
            align: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        paddedText(Global.format(purchasePriceTotal(orders)),
            align: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        paddedText(Global.format(priceDiffTotal(orders)),
            align: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        paddedText(Global.format(taxBaseTotal(orders)),
            align: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        paddedText(Global.format(taxAmountTotal(orders)),
            align: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        paddedText(Global.format(priceExcludeTaxTotal(orders)),
            align: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ])
    ],
  ));

  widgets.add(height());

  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(''),
    ],
  ));

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
        // pageFormat: PdfPageFormat.a4,
        pageFormat: const PdfPageFormat(1000, 1000),
        // orientation: PageOrientation.landscape,
        build: (context) => widgets,
        footer: (context) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('หมายเหตุ : นําหนักจะเป็นนําหนักในหน่วยของทอง 96.5%'),
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
