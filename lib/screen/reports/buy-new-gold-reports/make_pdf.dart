import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeBuyNewGoldReportPdf(
    List<OrderModel?> orders, int type, String date) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  Widget buildHeader() {
    return Column(
      children: [
        reportsCompanyTitle(),
        Center(
          child: Text(
            'รายงานซื้อทองรูปพรรณใหม่ 96.5%',
            style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            'ระหว่างวันที่ : $date',
            style:
                const TextStyle(decoration: TextDecoration.none, fontSize: 18),
          ),
        ),
        height(),
        reportsHeader(),
        height(h: 2),
        // Table column headers (repeat on every page)
        Table(
          border: TableBorder(
            top: BorderSide(color: PdfColors.grey400, width: 0.5),
            bottom: BorderSide(color: PdfColors.grey400, width: 0.5),
            left: BorderSide(color: PdfColors.grey400, width: 0.5),
            right: BorderSide(color: PdfColors.grey400, width: 0.5),
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
          ),
          columnWidths: {
            0: FixedColumnWidth(30),
            1: FixedColumnWidth(60),
            2: FixedColumnWidth(70),
            3: FixedColumnWidth(50),
            4: FixedColumnWidth(100), // ชื่อผู้ขาย - increased from 80
            5: FixedColumnWidth(45), // รหัส สนญ/สาขา - reduced to fit 6 chars
            6: FixedColumnWidth(65), // Tax ID - reduced from 80
            7: FixedColumnWidth(70),
            8: FixedColumnWidth(70),  // Last 5 columns same width
            9: FixedColumnWidth(70),  // Last 5 columns same width
            10: FixedColumnWidth(70), // Last 5 columns same width
            11: FixedColumnWidth(70), // Last 5 columns same width
            12: FixedColumnWidth(70), // Last 5 columns same width
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: PdfColors.white,
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedTextSmall('ลำดับ',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่ใบกำกับภาษี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่ใบรับทอง',
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
                paddedTextSmall('ชื่อผู้ขาย',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                    align: TextAlign.center),
                paddedTextSmall('รหัส\nสนญ/สาขา',
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
                paddedTextSmall('น้ําหนักรวม\n(กรัม)',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                    align: TextAlign.center),
                paddedTextSmall(
                    'ราคาซื้อ\nไม่รวมภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
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
                paddedTextSmall('ผลต่างฐานภาษี\nจำนวนเงิน (บาท)',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                    align: TextAlign.center),
                paddedTextSmall('ภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                    align: TextAlign.center),
                paddedTextSmall('ราคาซื้อ\nรวมภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
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

  List<Widget> dataRows = [];
  // Apply modern design pattern
  dataRows.add(
    Table(
      border: TableBorder(
        top: BorderSide(color: PdfColors.grey400, width: 0.5),
        bottom: BorderSide(color: PdfColors.grey400, width: 0.5),
        left: BorderSide(color: PdfColors.grey400, width: 0.5),
        right: BorderSide(color: PdfColors.grey400, width: 0.5),
        horizontalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
        verticalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
      ),
      columnWidths: {
        0: FixedColumnWidth(30),
        1: FixedColumnWidth(60),
        2: FixedColumnWidth(70),
        3: FixedColumnWidth(50),
        4: FixedColumnWidth(100), // ชื่อผู้ขาย - increased from 80
        5: FixedColumnWidth(45), // รหัส สนญ/สาขา - reduced to fit 6 chars
        6: FixedColumnWidth(65), // Tax ID - reduced from 80
        7: FixedColumnWidth(70),
        8: FixedColumnWidth(70),  // Last 5 columns same width
        9: FixedColumnWidth(70),  // Last 5 columns same width
        10: FixedColumnWidth(70), // Last 5 columns same width
        11: FixedColumnWidth(70), // Last 5 columns same width
        12: FixedColumnWidth(70), // Last 5 columns same width
      },
      children: [
        // Data rows with color coding
        for (int i = 0; i < orders.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: i % 2 == 0 ? PdfColors.white : PdfColors.grey100),
            children: [
              paddedTextSmall('${i + 1}',
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall(orders[i]!.referenceNo ?? '',
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall(orders[i]!.orderId,
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall(Global.dateOnly(orders[i]!.orderDate.toString()),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.center),

              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "ยกเลิกเอกสาร***"
                      : getCustomerNameForWholesaleReports(
                          orders[i]!.customer!),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black)),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? ""
                      : getCustomerBranchCode(orders[i]!.customer!),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? ""
                      : orders[i]!.customer?.taxNumber != null
                          ? orders[i]!.customer?.taxNumber ?? ''
                          : '',
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black)),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : type == 1
                          ? Global.format(getWeight(orders[i]!))
                          : Global.format(orders[i]!.weight!),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : Global.format(orders[i]!.priceExcludeTax ?? 0),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : Global.format(orders[i]!.purchasePrice ?? 0),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : Global.format(orders[i]!.taxBase ?? 0),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.right),
              // paddedTextSmall(Global.format(orders[i]!.taxBase ?? 0),
              //     style: TextStyle(
              //         fontSize: 10,
              //         color: orders[i]!.status == "2" ? PdfColors.red900 : null
              //     ),
              //     align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : Global.format(orders[i]!.taxAmount ?? 0),
                  style: TextStyle(
                      fontSize: 11,
                      color:
                          orders[i]!.status == "2" ? PdfColors.red900 : null),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : Global.format(orders[i]!.priceIncludeTax ?? 0),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
                  align: TextAlign.right)
            ],
          ),
        // Summary row
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border(
                top: BorderSide(color: PdfColors.grey400, width: 0.5),
              ),
            ),
            children: [
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeightTotal(orders))
                      : Global.format(getWeightTotalB(orders)),
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
              paddedTextSmall(Global.format(purchasePriceTotal(orders)),
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
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
            ]),
      ],
    ),
  );

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
