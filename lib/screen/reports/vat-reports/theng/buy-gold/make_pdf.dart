import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:sizer/sizer.dart';

Future<Uint8List> makeBuyThengVatReportPdf(List<OrderModel?> orders, int type,
    String date, DateTime fromDate, DateTime toDate) async {
  List<OrderModel> list = [];

  int days = Global.daysBetween(fromDate, toDate);

  for (int j = 0; j <= days; j++) {
    var indexDay = fromDate.add(Duration(days: j));

    // Find all orders for this specific day
    var ordersForDay =
        orders.where((order) => order!.createdDate == indexDay).toList();

    if (ordersForDay.isNotEmpty) {
      // Add all orders for this day
      for (var order in ordersForDay) {
        list.add(order!);
      }
    }
  }

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
            'รายงานภาษีมูลค่าเพิ่ม : รายงานภาษีซื้อทองคำแท่ง',
            style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: type == 2
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
            top: BorderSide(color: PdfColors.grey200, width: 0.5),
            bottom: BorderSide(color: PdfColors.grey200, width: 0.5),
            left: BorderSide(color: PdfColors.grey200, width: 0.5),
            right: BorderSide(color: PdfColors.grey200, width: 0.5),
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide(color: PdfColors.white, width: 0.5),
          ),
          columnWidths: type == 1
              ? {
                  0: const FixedColumnWidth(25),
                  1: const FixedColumnWidth(70),
                  2: const FixedColumnWidth(45),
                  3: const FixedColumnWidth(75),
                  4: const FixedColumnWidth(60),
                  5: const FixedColumnWidth(50),
                  6: const FixedColumnWidth(45),
                  7: const FixedColumnWidth(70),
                  8: const FixedColumnWidth(55),
                  9: const FixedColumnWidth(60),
                  10: const FixedColumnWidth(65),
                  11: const FixedColumnWidth(60),
                  12: const FixedColumnWidth(65),
                }
              : {
                  0: const FixedColumnWidth(30),
                  1: const FixedColumnWidth(55),
                  2: const FixedColumnWidth(70),
                  3: const FixedColumnWidth(80),
                  4: const FixedColumnWidth(55),
                  5: const FixedColumnWidth(50),
                  6: const FixedColumnWidth(75),
                  7: const FixedColumnWidth(60),
                  8: const FixedColumnWidth(65),
                  9: const FixedColumnWidth(70),
                  10: const FixedColumnWidth(65),
                  11: const FixedColumnWidth(75),
                },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue600,
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: type == 1
                  ? [
                      paddedTextSmall('ลําดับ',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('เลขที่\nใบกํากับภาษี',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('วันที่',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('ชื่อผู้ซื้อ',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('น้ำหนักรวม\n(บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('น้ำหนักรวม\n(กรัม)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall(
                          'ฐานภาษีมูลค่ายกเว้น\nราคาทองคําแท่ง(บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('ค่าบล็อกทอง',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('ค่าบรรจุภัณฑ์',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('รวมมูลค่าฐานภาษี',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('ภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('ราคาขาย\nรวมภาษีมูลค่าเพิ่ม\n(บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                    ]
                  : [
                      paddedTextSmall('ลําดับ',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall(type == 4 ? 'เดือน' : 'วันที่',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('เลขที่\nใบกํากับภาษี',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('รายการสินค้า',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('น้ำหนักรวม\n(บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('น้ำหนักรวม\n(กรัม)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall(
                          'ฐานภาษีมูลค่ายกเว้น\nราคาทองคําแท่ง(บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('ค่าบล็อกทอง',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('ค่าบรรจุภัณฑ์',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('รวมมูลค่าฐานภาษี',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('ภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
                          align: TextAlign.center),
                      paddedTextSmall('ราคาขาย\nรวมภาษีมูลค่าเพิ่ม\n(บาท)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white),
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
      columnWidths: type == 1
          ? {
              0: const FixedColumnWidth(25),
              1: const FixedColumnWidth(70),
              2: const FixedColumnWidth(45),
              3: const FixedColumnWidth(75),
              4: const FixedColumnWidth(60),
              5: const FixedColumnWidth(50),
              6: const FixedColumnWidth(45),
              7: const FixedColumnWidth(70),
              8: const FixedColumnWidth(55),
              9: const FixedColumnWidth(60),
              10: const FixedColumnWidth(65),
              11: const FixedColumnWidth(60),
              12: const FixedColumnWidth(65),
            }
          : {
              0: const FixedColumnWidth(30),
              1: const FixedColumnWidth(55),
              2: const FixedColumnWidth(70),
              3: const FixedColumnWidth(80),
              4: const FixedColumnWidth(55),
              5: const FixedColumnWidth(50),
              6: const FixedColumnWidth(75),
              7: const FixedColumnWidth(60),
              8: const FixedColumnWidth(65),
              9: const FixedColumnWidth(70),
              10: const FixedColumnWidth(65),
              11: const FixedColumnWidth(75),
            },
      children: [
        // Data rows with color coding for type 1
        if (type == 1)
          for (int i = 0; i < orders.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: orders[i]!.status == "2"
                      ? PdfColors.red100
                      : PdfColors.white),
              children: [
                paddedTextSmall('${i + 1}',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]!.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall(orders[i]!.orderId,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.red900),
                    align: TextAlign.center),
                paddedTextSmall(
                    Global.dateOnly(orders[i]!.orderDate.toString()),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]!.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                // paddedTextSmall(Global.timeOnly(orders[i]!.orderDate.toString()), style: TextStyle(fontSize: 10)),
                paddedTextSmall(
                    '${orders[i]!.status == "2" ? "ยกเลิกเอกสาร" : getCustomerName(orders[i]!.customer!)} ',
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : null)),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? ""
                        : orders[i]!.customer?.taxNumber != null
                            ? orders[i]!.customer?.taxNumber ?? ''
                            : '',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]!.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(getWeightBaht(orders[i]!)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format4(getWeight(orders[i]!)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.green600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(getCommissionDetailTotal(orders[i])),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.orange600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(getPackagePriceDetailTotal(orders[i])),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.purple600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(getCommissionDetailTotal(orders[i]) +
                            getPackagePriceDetailTotal(orders[i])),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.teal600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format((getCommissionDetailTotal(orders[i]) +
                                getPackagePriceDetailTotal(orders[i])) *
                            getVatValue()),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.red600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format((orders[i]!.priceIncludeTax ?? 0)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.indigo600),
                    align: TextAlign.right),
              ],
            ),

        // Data rows with color coding for type 4
        if (type == 4)
          for (int i = 0; i < orders.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: orders[i]?.status == "2"
                      ? PdfColors.red100
                      : PdfColors.white),
              children: [
                paddedTextSmall('${i + 1}',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2"
                            ? PdfColors.red900
                            : null)),
                paddedTextSmall(
                    Global.formatDateMFT(orders[i]!.orderDate.toString()),
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2"
                            ? PdfColors.red900
                            : null)),
                paddedTextSmall(orders[i]!.orderId,
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2"
                            ? PdfColors.red900
                            : null)),
                paddedTextSmall('ทองคำแท่ง',
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2"
                            ? PdfColors.red900
                            : PdfColors.orange600,
                        fontWeight: FontWeight.bold)),
                // paddedTextSmall(
                //     Global.format((orders[i]!.weight ?? 0) / getUnitWeightValue()),
                //     style: TextStyle(
                //         fontSize: 10,
                //         color: orders[i]!.status == "2"
                //             ? PdfColors.red900
                //             : PdfColors.blue600),
                //     align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format((orders[i]!.weightBath ?? 0)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format4(orders[i]!.weight ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.priceExcludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.green600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.commissionAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.orange600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(orders[i]!.packageAmount ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.purple600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format((orders[i]!.commissionAmount ?? 0) +
                            (orders[i]!.packageAmount ?? 0)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.teal600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format(((orders[i]!.commissionAmount ?? 0) +
                                (orders[i]!.packageAmount ?? 0)) *
                            getVatValue()),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.red600),
                    align: TextAlign.right),
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "0.00"
                        : Global.format((orders[i]!.priceIncludeTax ?? 0)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.indigo600),
                    align: TextAlign.right),
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
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 2 || type == 3 || type == 4)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800),
                  align: TextAlign.right),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeightBahtTotal(orders))
                      : Global.format(getWeightTotalBahtTheng(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700),
                  align: TextAlign.right),
              paddedTextSmall(
                  type == 1
                      ? Global.format4(getWeightTotal(orders))
                      : Global.format4(getWeightTotalB(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700),
                  align: TextAlign.right),
              paddedTextSmall(
                  type == 1
                      ? Global.format(priceExcludeTaxTotal(orders))
                      : Global.format(getPriceExcludeTaxTotalType2(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700),
                  align: TextAlign.right),
              // Commission total (ค่าบล็อกทอง)
              paddedTextSmall(
                  type == 1
                      ? Global.format(getCommissionTotal(orders))
                      : Global.format(getCommissionTotalType2(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.orange700),
                  align: TextAlign.right),
              // Package price total (ค่าบรรจุภัณฑ์)
              paddedTextSmall(
                  type == 1
                      ? Global.format(getPackagePriceTotal(orders))
                      : Global.format(getPackagePriceTotalType2(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.purple700),
                  align: TextAlign.right),
              // Tax base total (รวมมูลค่าฐานภาษี)
              paddedTextSmall(
                  type == 1
                      ? Global.format(getTaxBaseTotal(orders))
                      : Global.format(getTaxBaseTotalType2(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.teal700),
                  align: TextAlign.right),
              // VAT amount total (ภาษีมูลค่าเพิ่ม)
              paddedTextSmall(
                  type == 1
                      ? Global.format(getVatAmountTotal(orders))
                      : Global.format(getVatAmountTotalType2(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700),
                  align: TextAlign.right),
              // Total selling price including VAT (ราคาขายรวมภาษีมูลค่าเพิ่ม)
              paddedTextSmall(
                  type == 1
                      ? Global.format(getTotalSellingPriceIncludingVat(orders))
                      : Global.format(
                          getTotalSellingPriceIncludingVatType2(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.indigo700),
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
                Text('หมายเหตุ : น้ำหนักจะเป็นน้ำหนักในหน่วยของทอง 96.5%'),
                Text('${context.pageNumber} / ${context.pagesCount}')
              ]);
        }),
  );
  return pdf.save();
}

// Function to calculate total commission (ค่าบล็อกทอง)
double getCommissionTotal(List<OrderModel?> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i] != null) {
      total += getCommissionDetailTotal(orders[i]!);
    }
  }
  return total;
}

// Function to calculate total package price (ค่าบรรจุภัณฑ์)
double getPackagePriceTotal(List<OrderModel?> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i] != null) {
      total += getPackagePriceDetailTotal(orders[i]!);
    }
  }
  return total;
}

// Function to calculate total tax base (รวมมูลค่าฐานภาษี)
double getTaxBaseTotal(List<OrderModel?> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i] != null) {
      total += getCommissionDetailTotal(orders[i]!) +
          getPackagePriceDetailTotal(orders[i]!);
    }
  }
  return total;
}

// Function to calculate total VAT amount (ภาษีมูลค่าเพิ่ม)
double getVatAmountTotal(List<OrderModel?> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i] != null) {
      double taxBase = getCommissionDetailTotal(orders[i]!) +
          getPackagePriceDetailTotal(orders[i]!);
      total += taxBase * getVatValue();
    }
  }
  return total;
}

// Function to calculate total selling price including VAT (ราคาขายรวมภาษีมูลค่าเพิ่ม)
double getTotalSellingPriceIncludingVat(List<OrderModel?> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i] != null) {
      double priceIncludeTax = orders[i]!.priceIncludeTax ?? 0;
      // double commission = getCommissionDetailTotal(orders[i]!);
      // double packagePrice = getPackagePriceDetailTotal(orders[i]!);
      // double taxBase = commission + packagePrice;
      // double vatAmount = taxBase * getVatValue();

      total += priceIncludeTax; // + taxBase + vatAmount;
    }
  }
  return total;
}

// For type 2 calculations using the 'list' array
// For type 2 calculations using the 'list' array
double getCommissionTotalType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดขาย') {
      total += list[i].commissionAmount ?? 0;
    }
  }
  return total;
}

double getPackagePriceTotalType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดขาย') {
      total += list[i].packageAmount ?? 0;
    }
  }
  return total;
}

double getTaxBaseTotalType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดขาย') {
      total += (list[i].commissionAmount ?? 0) + (list[i].packageAmount ?? 0);
    }
  }
  return total;
}

double getVatAmountTotalType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดขาย') {
      double taxBase =
          (list[i].commissionAmount ?? 0) + (list[i].packageAmount ?? 0);
      total += taxBase * getVatValue();
    }
  }
  return total;
}

double getTotalSellingPriceIncludingVatType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดซื้อ') {
      total += list[i].priceIncludeTax ?? 0;
    }
  }
  return total;
}

double getPriceExcludeTaxTotalType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดซื้อ') {
      total += list[i].priceExcludeTax ?? 0;
    }
  }
  return total;
}

getHeaderText(int type) {
  if (type == 1) {
    return Text(
      'จัดลำดับตามเลขที่ใบเสร็จรับเงิน/ใบกำกับภาษี',
      style: TextStyle(
        color: PdfColors.black, // White text on pink background
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  if (type == 4) {
    return Text(
      'จัดลำดับตามเดือน',
      style: TextStyle(
        color: PdfColors.black, // White text on pink background
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
