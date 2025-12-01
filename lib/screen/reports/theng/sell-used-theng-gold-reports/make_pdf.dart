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

Future<Uint8List> makeSellUsedThengGoldReportPdf(List<OrderModel?> orders,
    int type, String date, DateTime fromDate, DateTime toDate) async {
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
            'รายงานขายทองคำแท่งเก่า',
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
                  'ระหว่างวันที่ : $date',
                  style: const TextStyle(
                      decoration: TextDecoration.none, fontSize: 18),
                ),
        ),
        height(),
        reportsHeader(),
        height(h: 2),
        // Table column headers
        Table(
          border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
          columnWidths: type == 1
              ? {
                  0: FixedColumnWidth(25), // Seq
                  1: FixedColumnWidth(70), // Date
                  2: FixedColumnWidth(45), // Ref
                  3: FixedColumnWidth(75), // Order ID
                  4: FixedColumnWidth(60), // Name
                  5: FixedColumnWidth(50), // Branch
                  6: FixedColumnWidth(45), // Tax
                  7: FixedColumnWidth(45), // Product
                  8: FixedColumnWidth(70), // Weight Baht
                  9: FixedColumnWidth(55), // Weight Gram
                  10: FixedColumnWidth(
                      55), // Amount (THIS WAS MISSING IN YOUR ORIGINAL CODE)
                }
              : {
                  0: const FixedColumnWidth(30),
                  1: const FixedColumnWidth(55),
                  2: const FixedColumnWidth(70),
                  3: const FixedColumnWidth(80),
                  4: const FixedColumnWidth(55),
                  5: const FixedColumnWidth(50),
                  6: const FixedColumnWidth(75),
                },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: PdfColors.blue600),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedTextSmall('ลำดับ',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                paddedTextSmall(type == 2 ? 'เดือน' : 'วันที่',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                if (type == 1)
                  paddedTextSmall('เลขที่ใบรับซื้อ',
                      align: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.white)),
                paddedTextSmall(
                    type == 1 ? 'เลขที่ใบกำกับภาษี' : 'เลขที่ใบสำคัญจ่าย',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                if (type == 1)
                  paddedTextSmall('ชื่อผู้ซื้อ',
                      align: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.white)),
                if (type == 1)
                  paddedTextSmall('รหัสสำนักงานใหญ่/สาขา',
                      align: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.white)),
                if (type == 1)
                  paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                      align: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.white)),
                paddedTextSmall('รายการสินค้า',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                paddedTextSmall('น้ําหนัก\n(บาท)',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                paddedTextSmall('น้ําหนัก\n(กรัม)',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                paddedTextSmall('จำนวนเงิน (บาท)',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> dataRows = [];
  // Apply modern design pattern
  dataRows.add(Container(
    child: Table(
      border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
      columnWidths: type == 1
          ? {
              0: FixedColumnWidth(25), // Seq
              1: FixedColumnWidth(70), // Date
              2: FixedColumnWidth(45), // Ref
              3: FixedColumnWidth(75), // Order ID
              4: FixedColumnWidth(60), // Name
              5: FixedColumnWidth(50), // Branch
              6: FixedColumnWidth(45), // Tax
              7: FixedColumnWidth(45), // Product
              8: FixedColumnWidth(70), // Weight Baht
              9: FixedColumnWidth(55), // Weight Gram
              10: FixedColumnWidth(
                  55), // Amount (THIS WAS MISSING IN YOUR ORIGINAL CODE)
            }
          : {
              0: const FixedColumnWidth(30),
              1: const FixedColumnWidth(55),
              2: const FixedColumnWidth(70),
              3: const FixedColumnWidth(80),
              4: const FixedColumnWidth(55),
              5: const FixedColumnWidth(50),
              6: const FixedColumnWidth(75),
            },
      children: [
        // Data rows with color coding
        for (int i = 0; i < orders.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: PdfColors.white),
            children: [
              paddedTextSmall('${i + 1}',
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          orders[i]!.status == "2" ? PdfColors.red900 : null),
                  align: TextAlign.center),
              paddedTextSmall(
                  type == 2
                      ? Global.formatDateMFT(orders[i]!.orderDate.toString())
                      : Global.dateOnly(orders[i]!.orderDate.toString()),
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          orders[i]!.status == "2" ? PdfColors.red900 : null),
                  align: TextAlign.center),
              if (type == 1)
                paddedTextSmall(orders[i]!.referenceNo ?? '',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]!.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
              paddedTextSmall(orders[i]!.orderId,
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          orders[i]!.status == "2" ? PdfColors.red900 : null),
                  align: TextAlign.center),
              if (type == 1)
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "ยกเลิกเอกสาร***"
                        : type == 1
                            ? '${getCustomerNameForWholesaleReports(orders[i]!.customer!)}'
                            : 'รวมรายการทองเก่า\nประจําวัน',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]!.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
              if (type == 1)
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? ""
                        : getCustomerBranchCode(orders[i]!.customer!),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]!.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
              if (type == 1)
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? ""
                        : orders[i]!.customer?.taxNumber != ''
                            ? orders[i]!.customer?.taxNumber ?? ''
                            : orders[i]!.customer?.idCard ?? '',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]!.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
              paddedTextSmall('ทองคำแท่ง',
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.orange600,
                      fontWeight: FontWeight.bold),
                  align: TextAlign.center),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : '${type == 1 ? Global.format(getWeight(orders[i]!) / getUnitWeightValue(orders[i]!.details!.first.productId)) : Global.format(orders[i]!.weightBath)}',
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.blue600),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : '${type == 1 ? Global.format4(getWeight(orders[i]!)) : Global.format4(orders[i]!.weight!)}',
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.blue600),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : Global.format(orders[i]!.priceIncludeTax ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.green600),
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
            children: [
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800),
                  align: TextAlign.right),
              paddedTextSmall(
                  '${type == 1 ? Global.format(getWeightTotal(orders) / getUnitWeightValue(orders.first?.details?.first.productId)) : Global.format(getWeightTotalBaht(orders))}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700),
                  align: TextAlign.right),
              paddedTextSmall(
                  '${type == 1 ? Global.format4(getWeightTotal(orders)) : Global.format4(getWeightTotalB(orders))}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700),
                  align: TextAlign.right),
            ]),
      ],
    ),
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

// Function to calculate total VAT amount (column 13)
double vatAmountTotal(List<OrderModel?> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i]!.priceDiff! > 0) {
      total += orders[i]!.priceDiff! * getVatValue();
    }
  }
  return total;
}

// Function to calculate total price excluding VAT (column 14)
double priceExcludeVatTotal(List<OrderModel?> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    double vatAmount =
        orders[i]!.priceDiff! < 0 ? 0 : orders[i]!.priceDiff! * getVatValue();
    total += (orders[i]!.priceIncludeTax ?? 0) - vatAmount;
  }
  return total;
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
