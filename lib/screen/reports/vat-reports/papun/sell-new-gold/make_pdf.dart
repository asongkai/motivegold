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
  // For types 2 and 3, the orders are already aggregated by genDailyList()
  // so we use them directly
  List<OrderModel> list = orders.whereType<OrderModel>().toList();
  List<OrderModel> list3 = orders.whereType<OrderModel>().toList();

  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  // Build header function for repeating on each page
  Widget buildHeader() {
    return Column(
      children: [
        reportsCompanyTitle(),
        Center(
          child: Text(
            'รายงานภาษีมูลค่าเพิ่ม : รายงานภาษีขายทองคำรูปพรรณใหม่ 96.5%',
            style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: type == 4
              ? Text(
                  'ปีภาษี : ${Global.formatDateYFT(fromDate.toString())} ระหว่างวันที่ : $date',
                  style: const TextStyle(
                      decoration: TextDecoration.none, fontSize: 18),
                )
              : Text(
                  'เดือนภาษี : ${Global.formatDateMFT(fromDate.toString())} ปี : ${Global.formatDateYFT(fromDate.toString())} ระหว่างวันที่ : $date',
                  style: const TextStyle(
                      decoration: TextDecoration.none, fontSize: 18),
                ),
        ),
        height(),
        reportsHeader(),
        height(h: 2),
        // Table column headers
        Table(
          border: TableBorder(
            top: BorderSide(color: PdfColors.grey400, width: 0.5),
            bottom: BorderSide(color: PdfColors.grey400, width: 0.5),
            left: BorderSide(color: PdfColors.grey400, width: 0.5),
            right: BorderSide(color: PdfColors.grey400, width: 0.5),
            horizontalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
            verticalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
          ),
          columnWidths: type == 1
              ? {
                  0: const FixedColumnWidth(25),
                  1: const FixedColumnWidth(55),
                  2: const FixedColumnWidth(45),
                  3: const FixedColumnWidth(70),
                  4: const FixedColumnWidth(60),
                  5: const FixedColumnWidth(50),
                  6: const FixedColumnWidth(70),
                  7: const FixedColumnWidth(70),
                  8: const FixedColumnWidth(70),
                  9: const FixedColumnWidth(70),
                  10: const FixedColumnWidth(60),
                  11: const FixedColumnWidth(70),
                }
              : {
                  0: const FixedColumnWidth(30),
                  1: const FixedColumnWidth(55),
                  2: const FixedColumnWidth(60),
                  3: const FixedColumnWidth(80),
                  4: const FixedColumnWidth(60),
                  5: const FixedColumnWidth(75),
                  6: const FixedColumnWidth(75),
                  7: const FixedColumnWidth(75),
                  8: const FixedColumnWidth(70),
                  9: const FixedColumnWidth(65),
                  10: const FixedColumnWidth(75),
                },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: PdfColors.white,
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: type == 1
                  ? [
                      paddedTextSmall('ลําดับ',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('เลขที่\nใบกํากับภาษี',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('วันที่',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('ชื่อผู้ซื้อ',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('น้ำหนักรวม\n(กรัม)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall(
                          'ยอดขายรวม\nภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('มูลค่าฐานภาษี\nยกเว้น\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall(
                          'ผลต่าง\nรวมภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('ฐานภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('ภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall(
                          'ยอดขายไม่รวมภาษี\nมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                    ]
                  : [
                      paddedTextSmall('ลําดับ',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall(type == 4 ? 'เดือน' : 'วันที่',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('เลขที่\nใบกํากับภาษี',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('รายการสินค้า',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('น้ำหนักรวม\n(กรัม)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall(
                          'ยอดขายรวม\nภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('มูลค่าฐานภาษี\nยกเว้น\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall(
                          'ผลต่าง\nรวมภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('ฐานภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall('ภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                      paddedTextSmall(
                          'ยอดขายไม่รวมภาษี\nมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.black),
                          align: TextAlign.center),
                    ],
            ),
          ],
        ),
      ],
    );
  }

  // Create list for data rows
  List<Widget> dataRows = [];

  // Apply modern design pattern
  dataRows.add(Container(
    decoration: BoxDecoration(
      border: Border.all(color: PdfColors.grey300, width: 0.5),
    ),
    child: Table(
      border: TableBorder(
        top: BorderSide(color: PdfColors.grey400, width: 0.5),
        bottom: BorderSide(color: PdfColors.grey400, width: 0.5),
        left: BorderSide(color: PdfColors.grey400, width: 0.5),
        right: BorderSide(color: PdfColors.grey400, width: 0.5),
        horizontalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
        verticalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
      ),
      columnWidths: type == 1
          ? {
              0: const FixedColumnWidth(25),
              1: const FixedColumnWidth(55),
              2: const FixedColumnWidth(45),
              3: const FixedColumnWidth(70),
              4: const FixedColumnWidth(60),
              5: const FixedColumnWidth(50),
              6: const FixedColumnWidth(70),
              7: const FixedColumnWidth(70),
              8: const FixedColumnWidth(70),
              9: const FixedColumnWidth(70),
              10: const FixedColumnWidth(60),
              11: const FixedColumnWidth(70),
            }
          : {
              0: const FixedColumnWidth(30),
              1: const FixedColumnWidth(55),
              2: const FixedColumnWidth(60),
              3: const FixedColumnWidth(80),
              4: const FixedColumnWidth(60),
              5: const FixedColumnWidth(75),
              6: const FixedColumnWidth(75),
              7: const FixedColumnWidth(75),
              8: const FixedColumnWidth(70),
              9: const FixedColumnWidth(65),
              10: const FixedColumnWidth(75),
            },
      children: [
        // Data rows with color coding for type 1
        if (type == 1)
          for (int i = 0; i < orders.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: i % 2 == 0 ? PdfColors.white : PdfColors.grey100),
              children: [
                paddedTextSmall('${i + 1}',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(orders[i]!.orderId,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(
                    Global.dateOnly(orders[i]!.orderDate.toString()),
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                // paddedTextSmall(Global.timeOnly(orders[i]!.orderDate.toString()), style: TextStyle(fontSize: 10)),
                paddedTextSmall(
                    '${orders[i]!.status == "2" ? "ยกเลิกเอกสาร***" : getCustomerName(orders[i]!.customer!)} ',
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? ""
                        : orders[i]!.customer?.taxNumber != null
                            ? orders[i]!.customer?.taxNumber ?? ''
                            : '',
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(getWeight(orders[i]!)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.purchasePrice ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.priceDiff ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.taxBase ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.taxAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]!.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black),
                    align: TextAlign.right)
              ],
            ),
        // Data rows with color coding for type 2
        if (type == 2)
          for (int i = 0; i < list.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: i % 2 == 0 ? PdfColors.white : PdfColors.grey100),
              children: [
                paddedTextSmall('${i + 1}',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(Global.dateOnly(list[i].orderDate.toString()),
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(list[i].orderId,
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall('ทองคำรูปพรรณ 96.5%',
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null,
                        fontWeight: FontWeight.bold)),
                paddedTextSmall(
                    list[i].status == "2"
                        ? "0.00"
                        : list[i].weight == null
                            ? '0.00'
                            : Global.format(list[i].weight!),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].status == "2"
                        ? "0.00"
                        : list[i].priceIncludeTax == null
                            ? '0.00'
                            : Global.format(list[i].priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].status == "2"
                        ? "0.00"
                        : list[i].purchasePrice == null
                            ? '0.00'
                            : Global.format(list[i].purchasePrice ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].status == "2"
                        ? "0.00"
                        : list[i].priceDiff == null
                            ? '0.00'
                            : Global.format(list[i].priceDiff ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].status == "2"
                        ? "0.00"
                        : list[i].taxBase == null
                            ? '0.00'
                            : Global.format(list[i].taxBase ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].status == "2"
                        ? "0.00"
                        : list[i].taxAmount == null
                            ? '0.00'
                            : Global.format(list[i].taxAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list[i].status == "2"
                        ? "0.00"
                        : list[i].priceExcludeTax == null
                            ? '0.00'
                            : Global.format(list[i].priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right)
              ],
            ),
        // Data rows with color coding for type 2
        if (type == 3)
          for (int i = 0; i < list3.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: i % 2 == 0 ? PdfColors.white : PdfColors.grey100),
              children: [
                paddedTextSmall('${i + 1}',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(Global.dateOnly(list3[i].orderDate.toString()),
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(list3[i].orderId,
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall('ทองคำรูปพรรณ 96.5%',
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2" ? PdfColors.red900 : null,
                        fontWeight: FontWeight.bold)),
                paddedTextSmall(
                    list3[i].status == "2"
                        ? "0.00"
                        : list3[i].weight == null
                            ? '0.00'
                            : Global.format(list3[i].weight!),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].status == "2"
                        ? "0.00"
                        : list3[i].priceIncludeTax == null
                            ? '0.00'
                            : Global.format(list3[i].priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].status == "2"
                        ? "0.00"
                        : list3[i].purchasePrice == null
                            ? '0.00'
                            : Global.format(list3[i].purchasePrice ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].status == "2"
                        ? "0.00"
                        : list3[i].priceDiff == null
                            ? '0.00'
                            : Global.format(list3[i].priceDiff ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].status == "2"
                        ? "0.00"
                        : list3[i].taxBase == null
                            ? '0.00'
                            : Global.format(list3[i].taxBase ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].status == "2"
                        ? "0.00"
                        : list3[i].taxAmount == null
                            ? '0.00'
                            : Global.format(list3[i].taxAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    list3[i].status == "2"
                        ? "0.00"
                        : list3[i].priceExcludeTax == null
                            ? '0.00'
                            : Global.format(list3[i].priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right)
              ],
            ),
        // Data rows with color coding for type 4
        if (type == 4)
          for (int i = 0; i < orders.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: i % 2 == 0 ? PdfColors.white : PdfColors.grey100),
              children: [
                paddedTextSmall('${i + 1}',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(
                    Global.formatDateMFT(orders[i]!.orderDate.toString()),
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall(orders[i]!.orderId,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black)),
                paddedTextSmall('ทองคำรูปพรรณ 96.5%',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null,
                        fontWeight: FontWeight.bold)),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : orders[i]?.weight == null
                            ? '0.00'
                            : Global.format(orders[i]?.weight!),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : orders[i]?.priceIncludeTax == null
                            ? '0.00'
                            : Global.format(orders[i]?.priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : orders[i]?.purchasePrice == null
                            ? '0.00'
                            : Global.format(orders[i]?.purchasePrice ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : orders[i]?.priceDiff == null
                            ? '0.00'
                            : Global.format(orders[i]?.priceDiff ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : orders[i]?.taxBase == null
                            ? '0.00'
                            : Global.format(orders[i]?.taxBase ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : orders[i]?.taxAmount == null
                            ? '0.00'
                            : Global.format(orders[i]?.taxAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : orders[i]?.priceExcludeTax == null
                            ? '0.00'
                            : Global.format(orders[i]?.priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.right)
              ],
            ),
        // Summary row with clean styling
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border(
                top: BorderSide(color: PdfColors.grey400, width: 0.5),
              ),
            ),
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              // if (type == 1) paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 2 || type == 3 || type == 4)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeightTotal(orders))
                      : Global.format(getWeightTotalB(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(purchasePriceTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceDiffTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxBaseTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxAmountTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceExcludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
            ]),
      ],
    ),
  ));

  dataRows.add(height());

  dataRows.add(Row(
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
          PdfPageFormat.a4.width, // width becomes height
        ),
        orientation: PageOrientation.landscape,
        header: (context) => buildHeader(),
        build: (context) => dataRows,
        footer: (context) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('หมายเหตุ : น้ำหนักจะเป็นน้ำหนักในหน่วยของทอง 96.5% '),
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
