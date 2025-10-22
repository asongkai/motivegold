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

  List<Widget> widgets = [];
  // widgets.add(height());
  // widgets.add(Align(
  //     alignment: Alignment.topRight,
  //     child: Container(
  //         decoration: BoxDecoration(
  //           color: PdfColor.fromHex('#6d4c41'), // Or whatever pink shade you prefer
  //           borderRadius: BorderRadius.circular(0), // Optional: rounded corners
  //         ),
  //         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //         child: getHeaderText(type)
  //     )
  // ));
  // widgets.add(height());
  widgets.add(reportsCompanyTitle());
  widgets.add(Center(
    child: Text(
      'รายงานขายทองคำแท่งเก่า',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
    ),
  ));
  widgets.add(Center(
    child: type == 2
        ? Text(
            'ปีภาษี : ${Global.formatDateYFT(fromDate.toString())} ระหว่างวันที่ : $date',
            style:
                const TextStyle(decoration: TextDecoration.none, fontSize: 18),
          )
        : Text(
            'ระหว่างวันที่ : $date',
            style:
                const TextStyle(decoration: TextDecoration.none, fontSize: 18),
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
              paddedTextSmall('ลำดับ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall(type == 2 ? 'เดือน' : 'วันที่',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white),
                  align: TextAlign.center),
              if (type == 1)
                paddedTextSmall('เลขที่ใบรับซื้อ',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
              if (type == 1)
                paddedTextSmall('เลขที่ใบกำกับภาษี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
              if (type == 2)
                paddedTextSmall('เลขที่ใบสำคัญจ่าย',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
              if (type == 1)
                paddedTextSmall('ชื่อผู้ซื้อ',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
              if (type == 1)
                paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
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
              paddedTextSmall('น้ําหนัก\n(บาท)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white),
                  align: TextAlign.center),
              paddedTextSmall('น้ําหนัก\n(กรัม)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white),
                  align: TextAlign.center),
              paddedTextSmall('จำนวนเงิน (บาท)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white),
                  align: TextAlign.center),
            ]),
        // Data rows with color coding
        for (int i = 0; i < orders.length; i++)
          TableRow(
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
                        ? "ยกเลิกเอกสาร"
                        : type == 1
                            ? '${getCustomerName(orders[i]!.customer!)}'
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
        build: (context) => widgets,
        footer: (context) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('* น้ําหนักจะเป็นน้ําหนักในหน่วยของทอง 96.5%'),
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
