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

Future<Uint8List> makeBuyThengReportPdf(List<OrderModel?> orders, int type,
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

  Widget buildHeader() {
    return Column(
      children: [
        reportsCompanyTitle(),
        Center(
          child: Text(
            'รายงานภาษีซื้อทองคำแท่ง',
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
                  style:
                      const TextStyle(decoration: TextDecoration.none, fontSize: 18),
                )
              : Text(
                  'เดือนภาษี : ${Global.formatDateMFT(fromDate.toString())} ปี : ${Global.formatDateYFT(fromDate.toString())} ระหว่างวันที่ : $date',
                  style:
                      const TextStyle(decoration: TextDecoration.none, fontSize: 18),
                ),
        ),
        height(),
        reportsHeader(),
        height(h: 2),
      ],
    );
  }

  List<Widget> dataRows = [];
  // Apply modern design pattern
  dataRows.add(Container(
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
                    color: PdfColors.white),
                align: TextAlign.center),
            if (type == 2 || type == 3 || type == 4)
              paddedTextSmall('วันที่',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white),
                  align: TextAlign.center),
            if (type == 1)
              paddedTextSmall('เลขที่\nใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white),
                  align: TextAlign.center),
            if (type == 1)
              paddedTextSmall('วันที่',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white),
                  align: TextAlign.center),
            // if (type == 1) paddedTextSmall('เวลา',
            //     style: TextStyle(
            //         fontSize: 11,
            //         fontWeight: FontWeight.bold,
            //         color: PdfColors.white
            //     ),
            //     align: TextAlign.center
            // ),
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
            if (type == 2 || type == 3 || type == 4)
              paddedTextSmall('เลขที่\nใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white),
                  align: TextAlign.center),
            if (type == 2 || type == 3 || type == 4)
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
            paddedTextSmall('ฐานภาษีมูลค่ายกเว้น\nราคาทองคําแท่ง(บาท)',
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
                        : Global.format((orders[i]!.priceIncludeTax ?? 0) +
                            (getCommissionDetailTotal(orders[i]) +
                                getPackagePriceDetailTotal(orders[i])) +
                            ((getCommissionDetailTotal(orders[i]) +
                                    getPackagePriceDetailTotal(orders[i])) *
                                getVatValue())),
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
                      : Global.format(getWeightTotalBaht(orders)),
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
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
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
                Text('หมายเหตุ : นําหนักจะเป็นนําหนักในหน่วยของทอง 96.5%'),
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
      double commission = getCommissionDetailTotal(orders[i]!);
      double packagePrice = getPackagePriceDetailTotal(orders[i]!);
      double taxBase = commission + packagePrice;
      double vatAmount = taxBase * getVatValue();

      total += priceIncludeTax + taxBase + vatAmount;
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
      total +=
          list[i].commissionAmount ?? 0; //getCommissionDetailTotal(list[i]);
    }
  }
  return total;
}

double getPackagePriceTotalType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดขาย') {
      total +=
          list[i].packageAmount ?? 0; //getPackagePriceDetailTotal(list[i]);
    }
  }
  return total;
}

double getTaxBaseTotalType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดขาย') {
      total += (list[i].commissionAmount ?? 0) +
          (list[i].packageAmount ??
              0); //getCommissionDetailTotal(list[i]) + getPackagePriceDetailTotal(list[i]);
    }
  }
  return total;
}

double getVatAmountTotalType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดขาย') {
      double taxBase = (list[i].commissionAmount ?? 0) +
          (list[i].packageAmount ??
              0); //getCommissionDetailTotal(list[i]) + getPackagePriceDetailTotal(list[i]);
      total += taxBase * getVatValue();
    }
  }
  return total;
}

double getTotalSellingPriceIncludingVatType2(dynamic list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    // Skip "no sales" records
    if (list[i].orderId != 'ไม่มียอดขาย') {
      double priceIncludeTax = list[i].priceIncludeTax ?? 0;
      double commission =
          list[i].commissionAmount ?? 0; //getCommissionDetailTotal(list[i]);
      double packagePrice =
          list[i].packageAmount ?? 0; //getPackagePriceDetailTotal(list[i]);
      double taxBase = commission + packagePrice;
      double vatAmount = taxBase * getVatValue();

      total += priceIncludeTax + taxBase + vatAmount;
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
