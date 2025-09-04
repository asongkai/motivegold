import 'dart:typed_data';

import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:sizer/sizer.dart';

Future<Uint8List> makeSellVatReportPdf(List<OrderModel?> orders, int type,
    String date, DateTime fromDate, DateTime toDate) async {
  List<OrderModel> list = [];
  List<OrderModel> list3 = [];

  int days = Global.daysBetween(fromDate, toDate);

  for (int j = 0; j <= days; j++) {
    var indexDay = fromDate.add(Duration(days: j));

    // Find all orders for this specific day
    var ordersForDay = orders.where((order) => order!.createdDate == indexDay).toList();

    if (ordersForDay.isNotEmpty) {
      // Add all orders for this day
      for (var order in ordersForDay) {
        list.add(order!);
        list3.add(order);
      }
    } else {
      // No orders for this day, add one "no sales" record
      list.add(OrderModel(
          orderId: 'ไม่มียอดขาย',
          orderDate: indexDay,
          customer: orders.isNotEmpty ? orders.first!.customer : null
      ));
    }
  }

  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  List<Widget> widgets = [];

  // widgets.add(height());
  // widgets.add(Align(
  //   alignment: Alignment.topRight,
  //     child: Container(
  //         decoration: BoxDecoration(
  //           color: PdfColor.fromHex('#F06292'), // Or whatever pink shade you prefer
  //           borderRadius: BorderRadius.circular(0), // Optional: rounded corners
  //         ),
  //         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //         child: getHeaderText(type)
  //     )
  // ));
  // widgets.add(height());
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
    child: type == 4 ? Text(
      'ปีภาษี : ${Global.formatDateYFT(fromDate.toString())} ระหว่างวันที่ : $date',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 18),
    ) : Text(
      'เดือนภาษี : ${Global.formatDateMFT(fromDate.toString())} ปี : ${Global.formatDateYFT(fromDate.toString())} ระหว่างวันที่ : $date',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 18),
    ),
  ));
  widgets.add(height());
  widgets.add(reportsHeader());
  widgets.add(height(h: 2));
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
        verticalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            if (type == 2 || type == 3 || type == 4) paddedTextSmall('วันที่',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            if (type == 1)
              paddedTextSmall('เลขที่\nใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
            if (type == 1) paddedTextSmall('วันที่',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            // if (type == 1) paddedTextSmall('เวลา',
            //     style: TextStyle(
            //         fontSize: 11,
            //         fontWeight: FontWeight.bold,
            //         color: PdfColors.white
            //     ),
            //     align: TextAlign.center
            // ),
            if (type == 1) paddedTextSmall('ชื่อผู้ซื้อ',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            if (type == 1)
              paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
            if (type == 2 || type == 3 || type == 4)
              paddedTextSmall('เลขที่\nใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
            if (type == 2 || type == 3 || type == 4) paddedTextSmall('รายการสินค้า',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            paddedTextSmall('น้ำหนักรวม\n(กรัม)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            paddedTextSmall('ยอดขายรวม\nภาษีมูลค่าเพิม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            paddedTextSmall('มูลค่าฐานภาษี\nยกเว้น\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            paddedTextSmall('ผลต่าง\nรวมภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            paddedTextSmall('ฐานภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            paddedTextSmall('ภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
            paddedTextSmall('ยอดขายไม่รวมภาษี\nมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white
                ),
                align: TextAlign.center
            ),
          ],
        ),
        // Data rows with color coding for type 1
        if (type == 1)
          for (int i = 0; i < orders.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: orders[i]!.status == "2" ? PdfColors.pink100 : PdfColors.white
              ),
              children: [
                paddedTextSmall('${i + 1}', style: TextStyle(
                    fontSize: 10,
                    color: orders[i]!.status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall(orders[i]!.orderId, style: TextStyle(
                    fontSize: 10,
                    color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.red900
                )),
                paddedTextSmall(Global.dateOnly(orders[i]!.orderDate.toString()), style: TextStyle(
                    fontSize: 10,
                    color: orders[i]!.status == "2" ? PdfColors.red900 : null
                )),
                // paddedTextSmall(Global.timeOnly(orders[i]!.orderDate.toString()), style: TextStyle(fontSize: 10)),
                paddedTextSmall('${getCustomerName(orders[i]!.customer!)} ', style: TextStyle(
                    fontSize: 10,
                    color: orders[i]!.status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall(orders[i]!.customer?.taxNumber != null
                    ? orders[i]!.customer?.taxNumber ?? ''
                    : '', style: TextStyle(
                    fontSize: 10,
                    color: orders[i]!.status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall(Global.format(getWeight(orders[i]!)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.blue600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.green600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.purchasePrice ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.orange600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.priceDiff ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.purple600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.taxBase ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.teal600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.taxAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.red600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(orders[i]!.priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.indigo600
                    ),
                    align: TextAlign.right)
              ],
            ),
        // Data rows with color coding for type 2
        if (type == 2)
          for (int i = 0; i < list.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: list[i].status == "2" ? PdfColors.pink100 : PdfColors.white
              ),
              children: [
                paddedTextSmall('${i + 1}', style: TextStyle(
                    fontSize: 10,
                    color: list[i].status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall(Global.dateOnly(list[i].orderDate.toString()), style: TextStyle(
                    fontSize: 10,
                    color: list[i].status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall(list[i].orderId, style: TextStyle(
                    fontSize: 10,
                    color: list[i].status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall('ทองคำรูปพรรณ 96.5%',
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : PdfColors.orange600,
                        fontWeight: FontWeight.bold
                    )),
                paddedTextSmall(
                    list[i].weight == null ? '' : Global.format(list[i].weight!),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : PdfColors.blue600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].priceIncludeTax == null
                        ? ''
                        : Global.format(list[i].priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : PdfColors.green600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].purchasePrice == null
                        ? ''
                        : Global.format(list[i].purchasePrice ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : PdfColors.orange600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].priceDiff == null
                        ? ''
                        : Global.format(list[i].priceDiff ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : PdfColors.purple600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].taxBase == null
                        ? ''
                        : Global.format(list[i].taxBase ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : PdfColors.teal600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].taxAmount == null
                        ? ''
                        : Global.format(list[i].taxAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : PdfColors.red600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].priceExcludeTax == null
                        ? ''
                        : Global.format(list[i].priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : PdfColors.indigo600
                    ),
                    align: TextAlign.right)
              ],
            ),
        // Data rows with color coding for type 2
        if (type == 3)
          for (int i = 0; i < list3.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: list3[i].status == "2" ? PdfColors.pink100 : PdfColors.white
              ),
              children: [
                paddedTextSmall('${i + 1}', style: TextStyle(
                    fontSize: 10,
                    color: list3[i].status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall(Global.dateOnly(list[i].orderDate.toString()), style: TextStyle(
                    fontSize: 10,
                    color: list3[i].status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall(list3[i].orderId, style: TextStyle(
                    fontSize: 10,
                    color: list3[i].status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall('ทองคำรูปพรรณ 96.5%',
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2" ? PdfColors.red900 : PdfColors.orange600,
                        fontWeight: FontWeight.bold
                    )),
                paddedTextSmall(
                    list3[i].weight == null ? '' : Global.format(list3[i].weight!),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2" ? PdfColors.red900 : PdfColors.blue600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].priceIncludeTax == null
                        ? ''
                        : Global.format(list3[i].priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2" ? PdfColors.red900 : PdfColors.green600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].purchasePrice == null
                        ? ''
                        : Global.format(list3[i].purchasePrice ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2" ? PdfColors.red900 : PdfColors.orange600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].priceDiff == null
                        ? ''
                        : Global.format(list3[i].priceDiff ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2" ? PdfColors.red900 : PdfColors.purple600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].taxBase == null
                        ? ''
                        : Global.format(list3[i].taxBase ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2" ? PdfColors.red900 : PdfColors.teal600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].taxAmount == null
                        ? ''
                        : Global.format(list3[i].taxAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2" ? PdfColors.red900 : PdfColors.red600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].priceExcludeTax == null
                        ? ''
                        : Global.format(list3[i].priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2" ? PdfColors.red900 : PdfColors.indigo600
                    ),
                    align: TextAlign.right)
              ],
            ),
        // Data rows with color coding for type 4
        if (type == 4)
          for (int i = 0; i < orders.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: orders[i]?.status == "2" ? PdfColors.pink100 : PdfColors.white
              ),
              children: [
                paddedTextSmall('${i + 1}', style: TextStyle(
                    fontSize: 10,
                    color: orders[i]?.status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall(Global.formatDateMFT(orders[i]!.orderDate.toString()), style: TextStyle(
                    fontSize: 10,
                    color: orders[i]?.status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall(orders[i]!.orderId, style: TextStyle(
                    fontSize: 10,
                    color: orders[i]?.status == "2" ? PdfColors.red900 : null
                )),
                paddedTextSmall('ทองคำรูปพรรณ 96.5%',
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2" ? PdfColors.red900 : PdfColors.orange600,
                        fontWeight: FontWeight.bold
                    )),
                paddedTextSmall(
                    orders[i]?.weight == null ? '' : Global.format(orders[i]?.weight!),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2" ? PdfColors.red900 : PdfColors.blue600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]?.priceIncludeTax == null
                        ? ''
                        : Global.format(orders[i]?.priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2" ? PdfColors.red900 : PdfColors.green600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]?.purchasePrice == null
                        ? ''
                        : Global.format(orders[i]?.purchasePrice ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2" ? PdfColors.red900 : PdfColors.orange600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]?.priceDiff == null
                        ? ''
                        : Global.format(orders[i]?.priceDiff ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2" ? PdfColors.red900 : PdfColors.purple600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]?.taxBase == null
                        ? ''
                        : Global.format(orders[i]?.taxBase ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2" ? PdfColors.red900 : PdfColors.teal600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]?.taxAmount == null
                        ? ''
                        : Global.format(orders[i]?.taxAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2" ? PdfColors.red900 : PdfColors.red600
                    ),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]?.priceExcludeTax == null
                        ? ''
                        : Global.format(orders[i]?.priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2" ? PdfColors.red900 : PdfColors.indigo600
                    ),
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
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 1) paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              // if (type == 1) paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 1) paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 2 || type == 3 || type == 4) paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800
                  ),
                  align: TextAlign.right),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeightTotal(orders))
                      : Global.format(getWeightTotalB(orders)),
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
              paddedTextSmall(Global.format(purchasePriceTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.orange700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceDiffTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.purple700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxBaseTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.teal700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxAmountTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceExcludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
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

getHeaderText(int type) {
  if (type == 1) {
    return Text(
      'จัดลำดับตามเลขที่ใบเสร็จรับเงิน/ใบกำกับภาษี',
      style: TextStyle(
        color: PdfColors.white, // White text on pink background
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  if (type == 2) {
    return Text(
      'จัดลำดับตามวันที่',
      style: TextStyle(
        color: PdfColors.white, // White text on pink background
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  if (type == 3) {
    return Text(
      'จัดลำดับตามวันที่\nเฉพาะวันที่มียอดขาย',
      style: TextStyle(
        color: PdfColors.white, // White text on pink background
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  if (type == 4) {
    return Text(
      'จัดลำดับตามเดือน',
      style: TextStyle(
        color: PdfColors.white, // White text on pink background
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  return Text(''); // Default return for other types
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