import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/sell-wholesale-theng/make_pdf.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeRefillWholesaleThengReportPdf(List<OrderModel?> orders,
    int type, String date, DateTime fromDate, DateTime toDate) async {
  List<OrderModel> list = [];

  int days = Global.daysBetween(fromDate, toDate);

  for (int j = 0; j <= days; j++) {
    var indexDay = fromDate.add(Duration(days: j));
    var ordersForDay = orders
        .where((order) =>
            order!.orderDate?.year == indexDay.year &&
            order.orderDate?.month == indexDay.month &&
            order.orderDate?.day == indexDay.day)
        .toList();

    if (ordersForDay.isNotEmpty) {
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

  List<Widget> widgets = [];

  widgets.add(reportsCompanyTitle());
  widgets.add(Center(
    child: Text(
      'สมุดบัญชีซื้อทองคำแท่งจากร้านค้าส่ง',
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: 20,
          fontWeight: FontWeight.bold),
    ),
  ));
  // widgets.add(Center(
  //   child: Text(
  //     'ระหว่างวันที่ : $date',
  //     style: const TextStyle(decoration: TextDecoration.none, fontSize: 18),
  //   ),
  // ));
  widgets.add(Center(
    child: type == 3
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
  ));
  widgets.add(height());
  widgets.add(reportsHeader());
  widgets.add(height(h: 2));

  widgets.add(Column(
    children: [
      // Merged header row (เดบิต/เครดิต)
      Container(
        height: 30,
        decoration: BoxDecoration(
          color: PdfColors.blue600,
          border: Border(
            top: BorderSide(color: PdfColors.grey700, width: 0.5),
            left: BorderSide(color: PdfColors.grey700, width: 0.5),
            right: BorderSide(color: PdfColors.grey700, width: 0.5),
            bottom: BorderSide(color: PdfColors.grey700, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(flex: 2, child: Container()), // เลขที่
            Expanded(flex: 3, child: Container()), // วันที่
            if (type == 1) Expanded(flex: 2, child: Container()), // ชื่อผู้ขาย

            // DEBIT section - spans 3 columns (ซื้อทองคำแท่ง + ต้นทุนค่าบล็อก/ค่าบรรจุภัณฑ์ + ภาษีซื้อ)
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: PdfColors.grey700, width: 0.5),
                    right: BorderSide(color: PdfColors.grey700, width: 0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    'เดบิต',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),
            ),

            // CREDIT section - spans 1 column (เงินสด/ธนาคาร)
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: PdfColors.grey700, width: 0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    'เครดิต',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Column names row
      Container(
        height: 40,
        decoration: BoxDecoration(
          color: PdfColors.blue600,
          border: Border(
            bottom: BorderSide(color: PdfColors.grey700, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: Center(
                      child: Text(type == 3 ? 'เดือน' : 'วัน/เดือน/ปี',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white))),
                )),
            Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: Center(
                      child: Text('เลขที่ใบรับทอง',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white))),
                )),
            if (type == 1)
              Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: PdfColors.grey700, width: 0.5),
                            right: BorderSide(
                                color: PdfColors.grey700, width: 0.5))),
                    child: Center(
                        child: Text('ชื่อผู้ขาย',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: PdfColors.white))),
                  )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: Center(
                      child: Text('ซื้อทองคำแท่ง\nจำนวนเงิน(บาท)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white))),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: Center(
                      child: Text(
                          'ต้นทุนค่าบล็อก/ค่าบรรจุภัณฑ์\nจำนวนเงิน(บาท)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white))),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: Center(
                      child: Text('ภาษีซื้อ\nจำนวนเงิน(บาท)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white))),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: Center(
                      child: Text('เงินสด/ธนาคาร\nจำนวนเงิน(บาท)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: PdfColors.white))),
                )),
          ],
        ),
      ),

      // Data rows
      if (type == 1 || type == 2 || type == 3)
        for (int i = 0; i < list.length; i++)
          Container(
            height: 18,
            decoration: BoxDecoration(
              color: list[i].status == "2" ? PdfColors.red100 : PdfColors.white,
              border: Border(
                left: BorderSide(color: PdfColors.grey700, width: 0.5),
                right: BorderSide(color: PdfColors.grey700, width: 0.5),
                bottom: BorderSide(color: PdfColors.grey700, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: PdfColors.grey700, width: 0.5),
                              right: BorderSide(
                                  color: PdfColors.grey700, width: 0.5))),
                      child: paddedTextSmall(
                          type == 3
                              ? Global.formatDateMFT(
                                  list[i].orderDate.toString())
                              : Global.dateOnly(list[i].orderDate.toString()),
                          align: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              color: list[i].status == "2"
                                  ? PdfColors.red900
                                  : null)),
                    )),
                Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: PdfColors.grey700, width: 0.5),
                              right: BorderSide(
                                  color: PdfColors.grey700, width: 0.5))),
                      child: paddedTextSmall(list[i].orderId,
                          align: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              color: list[i].status == "2"
                                  ? PdfColors.red900
                                  : PdfColors.red900)),
                    )),
                if (type == 1)
                  Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: PdfColors.grey700, width: 0.5),
                                right: BorderSide(
                                    color: PdfColors.grey700, width: 0.5))),
                        child: paddedTextSmall(
                            list[i].status == "2"
                                ? "ยกเลิกเอกสาร"
                                : getCustomerName(list[i].customer!),
                            style: TextStyle(
                                fontSize: 10,
                                color: list[i].status == "2"
                                    ? PdfColors.red900
                                    : null)),
                      )),
                Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: PdfColors.grey700, width: 0.5),
                              right: BorderSide(
                                  color: PdfColors.grey700, width: 0.5))),
                      child: paddedTextSmall(
                          list[i].status == "2"
                              ? "0.00"
                              : Global.format(getGoldValue(list[i])),
                          align: TextAlign.right,
                          style: TextStyle(
                              fontSize: 10,
                              color: list[i].status == "2"
                                  ? PdfColors.red900
                                  : PdfColors.purple600)),
                    )),
                Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: PdfColors.grey700, width: 0.5),
                              right: BorderSide(
                                  color: PdfColors.grey700, width: 0.5))),
                      child: paddedTextSmall(
                          list[i].status == "2"
                              ? "0.00"
                              : Global.format(getCommissionPackage(list[i])),
                          align: TextAlign.right,
                          style: TextStyle(
                              fontSize: 10,
                              color: list[i].status == "2"
                                  ? PdfColors.red900
                                  : PdfColors.blue600)),
                    )),
                Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: PdfColors.grey700, width: 0.5),
                              right: BorderSide(
                                  color: PdfColors.grey700, width: 0.5))),
                      child: paddedTextSmall(
                          list[i].status == "2"
                              ? "0.00"
                              : Global.format(getVatAmount(list[i])),
                          align: TextAlign.right,
                          style: TextStyle(
                              fontSize: 10,
                              color: list[i].status == "2"
                                  ? PdfColors.red900
                                  : PdfColors.orange600)),
                    )),
                Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: PdfColors.grey700, width: 0.5))),
                      child: paddedTextSmall(
                          list[i].status == "2"
                              ? "0.00"
                              : Global.format(getCashBank(list[i])),
                          align: TextAlign.right,
                          style: TextStyle(
                              fontSize: 10,
                              color: list[i].status == "2"
                                  ? PdfColors.red900
                                  : PdfColors.red600)),
                    )),
              ],
            ),
          ),

      // Total row
      Container(
        height: 18,
        decoration: BoxDecoration(
          color: PdfColors.blue50,
          border: Border(
            left: BorderSide(color: PdfColors.grey700, width: 0.5),
            right: BorderSide(color: PdfColors.grey700, width: 0.5),
            bottom: BorderSide(color: PdfColors.grey700, width: 0.5),
            top: BorderSide(color: PdfColors.blue200, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: Container(),
                )),
            if (type == 1)
              Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: PdfColors.grey700, width: 0.5),
                            right: BorderSide(
                                color: PdfColors.grey700, width: 0.5))),
                    child: Container(),
                  )),
            Expanded(
                flex: type == 1 ? 2 : 3,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: paddedTextSmall('รวมท้ังหมด',
                      align: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.blue800)),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: paddedTextSmall(
                      type == 1
                          ? Global.format(getGoldValueTotal(orders))
                          : Global.format(getGoldValueTotalB(list)),
                      align: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.purple700)),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: paddedTextSmall(
                      type == 1
                          ? Global.format(getCommissionPackageTotal(orders))
                          : Global.format(getCommissionPackageTotalB(list)),
                      align: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.blue700)),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: PdfColors.grey700, width: 0.5),
                          right: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: paddedTextSmall(
                      type == 1
                          ? Global.format(getVatAmountTotal(orders))
                          : Global.format(getVatAmountTotalB(list)),
                      align: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.orange700)),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              color: PdfColors.grey700, width: 0.5))),
                  child: paddedTextSmall(
                      type == 1
                          ? Global.format(getCashBankTotal(orders))
                          : Global.format(getCashBankTotalB(list)),
                      align: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.red700)),
                )),
          ],
        ),
      ),
    ],
  ));

  widgets.add(height());

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
        pageFormat: PdfPageFormat(
          PdfPageFormat.a4.height,
          PdfPageFormat.a4.width,
        ),
        orientation: PageOrientation.landscape,
        build: (context) => widgets,
        footer: (context) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('*บัญชีเงินสด/ธนาคาร , แสดงในสมุดบัญชีรับ-จ่ายเงิน'),
                Text('${context.pageNumber} / ${context.pagesCount}')
              ]);
        }),
  );
  return pdf.save();
}

// Report 5: THENG refill-wholesale (เติมทองคำแท่งกับร้านค้าส่ง)
// F = ซื้อทองคำแท่ง = Gold bars cost (total - packaging - vat)
double getGoldValue(OrderModel order) {
  double total = (order.priceExcludeTax ?? 0);
  // double packaging = getCommissionPackage(order);
  // double vat = getVatAmount(order);
  // return total - packaging - vat;
  return total;
}

// G = ต้นทุนค่าบล็อก/ค่าบรรจุภัณฑ์ = Packaging cost (commission + package, excluding VAT)
double getCommissionPackage(OrderModel order) {
  if (order.id == null || order.details == null || order.details!.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (var detail in order.details!) {
    // if (detail.vatOption == 'Include') {
    //   amount +=
    //       ((detail.commission ?? 0) + (detail.packagePrice ?? 0)) * 100 / 107;
    // } else {
    //   amount += (detail.commission ?? 0) + (detail.packagePrice ?? 0);
    // }
    amount += (detail.commission ?? 0) + (detail.packagePrice ?? 0);
  }
  return amount;
}

// H = ภาษีซื้อ = 7% VAT on packaging only
double getVatAmount(OrderModel order) {
  return order.taxAmount ?? 0; //getCommissionPackage(order) * 0.07;
}

// I = เงินสด/ธนาคาร = Total (F + G + H)
double getCashBank(OrderModel order) {
  return (order.priceIncludeTax ?? 0);
}

// Total functions for Type 1 (all orders)
double getGoldValueTotal(List<OrderModel?> orders) {
  double total = 0;
  for (var order in orders) {
    if (order != null && order.status != "2") {
      total += getGoldValue(order);
    }
  }
  return total;
}

double getCommissionPackageTotal(List<OrderModel?> orders) {
  double total = 0;
  for (var order in orders) {
    if (order != null && order.status != "2") {
      total += getCommissionPackage(order);
    }
  }
  return total;
}

double getVatAmountTotal(List<OrderModel?> orders) {
  double total = 0;
  for (var order in orders) {
    if (order != null && order.status != "2") {
      total += getVatAmount(order);
    }
  }
  return total;
}

double getCashBankTotal(List<OrderModel?> orders) {
  double total = 0;
  for (var order in orders) {
    if (order != null && order.status != "2") {
      total += getCashBank(order);
    }
  }
  return total;
}

// Total functions for Type 2/3 (filtered list)
double getGoldValueTotalB(List<OrderModel> list) {
  double total = 0;
  for (var order in list) {
    if (order.orderId != 'ไม่มียอดขาย' && order.status != "2") {
      total += getGoldValue(order);
    }
  }
  return total;
}

double getCommissionPackageTotalB(List<OrderModel> list) {
  double total = 0;
  for (var order in list) {
    if (order.orderId != 'ไม่มียอดขาย' && order.status != "2") {
      total += getCommissionPackage(order);
    }
  }
  return total;
}

double getVatAmountTotalB(List<OrderModel> list) {
  double total = 0;
  for (var order in list) {
    if (order.orderId != 'ไม่มียอดขาย' && order.status != "2") {
      total += getVatAmount(order);
    }
  }
  return total;
}

double getCashBankTotalB(List<OrderModel> list) {
  double total = 0;
  for (var order in list) {
    if (order.orderId != 'ไม่มียอดขาย' && order.status != "2") {
      total += getCashBank(order);
    }
  }
  return total;
}

double getWeightTotalB(List<OrderModel> list) {
  double total = 0;
  for (int i = 0; i < list.length; i++) {
    if (list[i].orderId != 'ไม่มียอดขาย') {
      total += getWeight(list[i]);
    }
  }
  return total;
}

Widget paddedTextSmall(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 11)}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );
