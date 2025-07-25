import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
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
          verticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            paddedTextSmall('ลําดับ',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            if (type == 2) paddedTextSmall('วันที',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            if (type == 1)
              paddedTextSmall('เลขที่\nใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
            if (type == 1) paddedTextSmall('วันที',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            // if (type == 1) paddedTextSmall('เวลา',
            //     style: TextStyle(
            //         fontSize: 9,
            //         fontWeight: FontWeight.bold,
            //         color: PdfColors.white
            //     ),
            //     align: TextAlign.center
            // ),
            if (type == 1) paddedTextSmall('ชือผู้ซือ',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            if (type == 1)
              paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
            if (type == 2)
              paddedTextSmall('เลขที่\nใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
            if (type == 2) paddedTextSmall('รายการสินค้า',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            paddedTextSmall('นําหนักรวม\n(กรัม)',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.right
            ),
            paddedTextSmall('ยอดขายรวมภาษี\nมูลค่าเพิม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.right
            ),
            paddedTextSmall('มูลค่ายกเว้นภาษี\nมูลค่าเพิม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.right
            ),
            paddedTextSmall('ผลต่างรวมภาษี\nมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.right
            ),
            paddedTextSmall('ฐานภาษี\nมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.right
            ),
            paddedTextSmall('ภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.right
            ),
            paddedTextSmall('ยอดขายไม่รวมภาษี\nมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.right
            ),
          ],
        ),
        // Data rows with color coding for type 1
        if (type == 1)
          for (int i = 0; i < orders.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: const BoxDecoration(),
              children: [
                paddedTextSmall('${i + 1}', style: TextStyle(fontSize: 8)),
                paddedTextSmall(orders[i]!.orderId, style: TextStyle(fontSize: 8)),
                paddedTextSmall(Global.dateOnly(orders[i]!.orderDate.toString()), style: TextStyle(fontSize: 8)),
                // paddedTextSmall(Global.timeOnly(orders[i]!.orderDate.toString()), style: TextStyle(fontSize: 8)),
                paddedTextSmall('${getCustomerName(orders[i]!.customer!)} ', style: TextStyle(fontSize: 8)),
                paddedTextSmall(orders[i]!.customer?.taxNumber != null
                    ? orders[i]!.customer?.taxNumber ?? ''
                    : '', style: TextStyle(fontSize: 8)),
                paddedTextSmall(Global.format(getWeight(orders[i]!)),
                    style: TextStyle(fontSize: 8, color: PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.priceIncludeTax ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.green600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.purchasePrice ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.orange600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.priceDiff ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.purple600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.taxBase ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.teal600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.taxAmount ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.red600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.priceExcludeTax ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.indigo600),
                    align: TextAlign.right)
              ],
            ),
        // Data rows with color coding for type 2
        if (type == 2)
          for (int i = 0; i < list.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: const BoxDecoration(),
              children: [
                paddedTextSmall('${i + 1}', style: TextStyle(fontSize: 8)),
                paddedTextSmall(Global.dateOnly(list[i].orderDate.toString()), style: TextStyle(fontSize: 8)),
                paddedTextSmall(list[i].orderId, style: TextStyle(fontSize: 8)),
                paddedTextSmall('ทองคำรูปพรรณ 96.5%',
                    style: TextStyle(fontSize: 8, color: PdfColors.orange600, fontWeight: FontWeight.bold)),
                paddedTextSmall(
                    list[i].weight == null ? '' : Global.format(list[i].weight!),
                    style: TextStyle(fontSize: 8, color: PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].priceIncludeTax == null
                        ? ''
                        : Global.format(list[i].priceIncludeTax ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.green600),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].purchasePrice == null
                        ? ''
                        : Global.format(list[i].purchasePrice ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.orange600),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].priceDiff == null
                        ? ''
                        : Global.format(list[i].priceDiff ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.purple600),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].taxBase == null
                        ? ''
                        : Global.format(list[i].taxBase ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.teal600),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].taxAmount == null
                        ? ''
                        : Global.format(list[i].taxAmount ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.red600),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].priceExcludeTax == null
                        ? ''
                        : Global.format(list[i].priceExcludeTax ?? 0),
                    style: TextStyle(fontSize: 8, color: PdfColors.indigo600),
                    align: TextAlign.right)
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
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              if (type == 1) paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              // if (type == 1) paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              if (type == 1) paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              if (type == 2) paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800
                  ),
                  align: TextAlign.right),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeightTotal(orders))
                      : Global.format(getWeightTotalB(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(purchasePriceTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.orange700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceDiffTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.purple700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxBaseTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.teal700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxAmountTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceExcludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.indigo700
                  ),
                  align: TextAlign.right),
            ]
        ),
      ],
    ),
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
                Text('หมายเหตุ : นําหนักจะเป็นนําหนักในหน่วยของทอง 96.5%'),
                Text('${context.pageNumber} / ${context.pagesCount}')
              ]);
        }),
  );
  return pdf.save();
}

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