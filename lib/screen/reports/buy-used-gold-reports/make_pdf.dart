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

Future<Uint8List> makeBuyUsedGoldReportPdf(List<OrderModel?> orders, int type,
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
            'รายงานซื้อทองรูปพรรณเก่า 96.5%',
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
        Table(
          border: TableBorder(
            top: BorderSide(color: PdfColors.grey400, width: 0.5),
            bottom: BorderSide(color: PdfColors.grey400, width: 0.5),
            left: BorderSide(color: PdfColors.grey400, width: 0.5),
            right: BorderSide(color: PdfColors.grey400, width: 0.5),
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide(color: PdfColors.grey400, width: 0.5),
          ),
          columnWidths: type == 1
              ? {
                  0: FixedColumnWidth(40),
                  1: FixedColumnWidth(60),
                  2: FixedColumnWidth(80),
                  3: FixedColumnWidth(100),
                  4: FixedColumnWidth(80),
                  5: FixedColumnWidth(100),
                  6: FixedColumnWidth(60),
                  7: FixedColumnWidth(80),
                }
              : {
                  0: FixedColumnWidth(50),
                  1: FixedColumnWidth(80),
                  2: FixedColumnWidth(100),
                  3: FixedColumnWidth(150),
                  4: FixedColumnWidth(80),
                  5: FixedColumnWidth(100),
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
                paddedTextSmall(type == 4 ? 'เดือน' : 'วันที่',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                    align: TextAlign.center),
                paddedTextSmall('เลขท่ีใบสําคัญ\nรับเงิน',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                    align: TextAlign.center),
                if (type == 1)
                  paddedTextSmall('ผู้ขาย',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.black),
                      align: TextAlign.center),
                if (type == 1)
                  paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
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
                paddedTextSmall('น้ําหนัก\n(กรัม)',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                    align: TextAlign.center),
                paddedTextSmall('จํานวนเงิน\n(บาท)',
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
      columnWidths: type == 1
          ? {
              0: FixedColumnWidth(40),
              1: FixedColumnWidth(60),
              2: FixedColumnWidth(80),
              3: FixedColumnWidth(100),
              4: FixedColumnWidth(80),
              5: FixedColumnWidth(100),
              6: FixedColumnWidth(60),
              7: FixedColumnWidth(80),
            }
          : {
              0: FixedColumnWidth(50),
              1: FixedColumnWidth(80),
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(150),
              4: FixedColumnWidth(80),
              5: FixedColumnWidth(100),
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
              paddedTextSmall(
                  type == 4
                      ? Global.formatDateMFT(orders[i]!.orderDate.toString())
                      : Global.dateOnly(orders[i]!.orderDate.toString()),
                  style: TextStyle(
                      fontSize: 11,
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
              if (type == 1)
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? "ยกเลิกเอกสาร***"
                        : type == 1
                            ? '${getCustomerName(orders[i]!.customer!)}'
                            : 'รวมรายการทองเก่า\nประจําวัน',
                    style: TextStyle(
                        fontSize: 11,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black),
                    align: TextAlign.center),
              if (type == 1)
                paddedTextSmall(
                    orders[i]!.status == "2"
                        ? ""
                        : orders[i]!.customer?.taxNumber != ''
                            ? orders[i]!.customer?.taxNumber ?? ''
                            : orders[i]!.customer?.idCard ?? '',
                    style: TextStyle(
                        fontSize: 11,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.black),
                    align: TextAlign.center),
              paddedTextSmall('ทองรูปพรรณเก่า',
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black,
                      fontWeight: FontWeight.bold),
                  align: TextAlign.center),
              paddedTextSmall(
                  orders[i]!.status == "2"
                      ? "0.00"
                      : '${type == 1 ? Global.format(getWeight(orders[i]!)) : Global.format(orders[i]!.weight!)}',
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == "2"
                          ? PdfColors.red900
                          : PdfColors.black),
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
        // Summary row with clean styling
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border(
                top: BorderSide(color: PdfColors.grey400, width: 0.5),
              ),
            ),
            children: [
              paddedTextSmall('', style: const TextStyle(fontSize: 11)),
              paddedTextSmall('', style: const TextStyle(fontSize: 11)),
              paddedTextSmall('', style: const TextStyle(fontSize: 11)),
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
              if (type == 1)
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  '${type == 1 ? Global.format(getWeightTotal(orders)) : Global.format(getWeightTotalB(orders))}',
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
