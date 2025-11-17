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

Future<Uint8List> makeSellUsedGoldReportPdf(List<OrderModel?> orders, int type,
    String date, DateTime fromDate, DateTime toDate) async {
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
            'รายงานภาษีขายทองคำรูปพรรณเก่า 96.5%',
            style:
                const TextStyle(decoration: TextDecoration.none, fontSize: 20),
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
                  0: FixedColumnWidth(28),
                  1: FixedColumnWidth(45),
                  2: FixedColumnWidth(65),
                  3: FixedColumnWidth(65),
                  4: FixedColumnWidth(65),
                  5: FixedColumnWidth(65),
                  6: FixedColumnWidth(60),
                  7: FixedColumnWidth(40),
                  8: FixedColumnWidth(70),
                  9: FixedColumnWidth(70),
                  10: FixedColumnWidth(75),
                  11: FixedColumnWidth(70),
                  12: FixedColumnWidth(55),
                  13: FixedColumnWidth(70),
                }
              : {
                  0: FixedColumnWidth(30),
                  1: FixedColumnWidth(50),
                  2: FixedColumnWidth(70),
                  3: FixedColumnWidth(70),
                  4: FixedColumnWidth(80),
                  5: FixedColumnWidth(45),
                  6: FixedColumnWidth(80),
                  7: FixedColumnWidth(80),
                  8: FixedColumnWidth(85),
                  9: FixedColumnWidth(80),
                  10: FixedColumnWidth(65),
                  11: FixedColumnWidth(80),
                },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue600,
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedTextSmall('ลำดับ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.left),
                paddedTextSmall(type == 2 ? 'เดือน' : 'วันที่',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่\nใบกำกับภาษี',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                paddedTextSmall('เลขท่ีใบสําคัญ\nรับเงิน',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                if (type == 1)
                  paddedTextSmall('ชื่อผู้ซื้อ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      align: TextAlign.center),
                if (type == 1)
                  paddedTextSmall('รหัสสำนักงานใหญ่/สาขา',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      align: TextAlign.center),
                if (type == 1)
                  paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      align: TextAlign.center),
                paddedTextSmall('รายการสินค้า',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                paddedTextSmall('น้ําหนัก\n(กรัม)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                paddedTextSmall('ราคาขายรวม\nภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                paddedTextSmall('มูลค่าฐานภาษียกเว้น\nจำนวนเงิน (บาท)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                paddedTextSmall(
                    'ผลต่างฐานภาษี\nต่ำกว่าราคารับซื้อ\nจำนวนเงิน (บาท)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                paddedTextSmall('ผลต่างฐาน\nภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                paddedTextSmall('ภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    align: TextAlign.center),
                paddedTextSmall(
                    'ราคาขายไม่รวม\nภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
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
        top: BorderSide(color: PdfColors.grey200, width: 0.5),
        bottom: BorderSide(color: PdfColors.grey200, width: 0.5),
        left: BorderSide(color: PdfColors.grey200, width: 0.5),
        right: BorderSide(color: PdfColors.grey200, width: 0.5),
        horizontalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
        verticalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
      ),
      columnWidths: type == 1
          ? {
              0: FixedColumnWidth(28),
              1: FixedColumnWidth(45),
              2: FixedColumnWidth(65),
              3: FixedColumnWidth(65),
              4: FixedColumnWidth(65),
              5: FixedColumnWidth(65),
              6: FixedColumnWidth(60),
              7: FixedColumnWidth(40),
              8: FixedColumnWidth(70),
              9: FixedColumnWidth(70),
              10: FixedColumnWidth(75),
              11: FixedColumnWidth(70),
              12: FixedColumnWidth(55),
              13: FixedColumnWidth(70),
            }
          : {
              0: FixedColumnWidth(30),
              1: FixedColumnWidth(50),
              2: FixedColumnWidth(70),
              3: FixedColumnWidth(70),
              4: FixedColumnWidth(80),
              5: FixedColumnWidth(45),
              6: FixedColumnWidth(80),
              7: FixedColumnWidth(80),
              8: FixedColumnWidth(85),
              9: FixedColumnWidth(80),
              10: FixedColumnWidth(65),
              11: FixedColumnWidth(80),
            },
      children: [
        // Data rows with color coding
        for (int i = 0; i < orders.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: orders[i]!.status == "2"
                    ? PdfColors.red100
                    : PdfColors.white),
            children: [
              paddedTextSmall('${i + 1}',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          orders[i]!.status == "2" ? PdfColors.red900 : null)),
              paddedTextSmall(
                  type == 2
                      ? Global.formatDateMFT(orders[i]!.orderDate.toString())
                      : Global.dateOnly(orders[i]!.orderDate.toString()),
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          orders[i]!.status == "2" ? PdfColors.red900 : null),
                  align: TextAlign.center),
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
                        ? "ยกเลิกเอกสาร"
                        : type == 1
                            ? '${getCustomerNameForReports(orders[i]!.customer!)}'
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
              paddedTextSmall('ทองรูปพรรณเก่า',
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
                      : '${type == 1 ? Global.format(getWeight(orders[i]!)) : Global.format(orders[i]!.weight!)}',
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
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : Global.format(orders[i]!.purchasePrice ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.green600),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : orders[i]!.priceDiff! < 0
                          ? '(${Global.format(orders[i]!.priceDiff ?? 0)})'
                          : "0.00",
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : orders[i]!.priceDiff! < 0
                              ? PdfColors.red600
                              : PdfColors.green600),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : orders[i]!.priceDiff! >= 0
                          ? Global.format(orders[i]!.priceDiff ?? 0)
                          : "0.00",
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.green600),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : orders[i]!.priceDiff! < 0
                          ? "0.00"
                          : Global.format(
                              orders[i]!.priceDiff! * getVatValue()),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.green600),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : Global.format((orders[i]!.priceIncludeTax ?? 0) -
                          (orders[i]!.priceDiff! < 0
                              ? 0
                              : orders[i]!.priceDiff! * getVatValue())),
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
                  '${type == 1 ? Global.format(getWeightTotal(orders)) : Global.format(getWeightTotalB(orders))}',
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
              paddedTextSmall(Global.format(purchasePriceTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700),
                  align: TextAlign.right),
              paddedTextSmall('(${Global.format(-priceDiffTotalM(orders))})',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceDiffTotalP(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(vatAmountTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceExcludeVatTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700),
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
