import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeSellUsedWholesalePaphunReportPdf(List<OrderModel?> orders,
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

  // Sort by orderId for type == 1
  if (type == 1) {
    list.sort((a, b) => a.orderId.compareTo(b.orderId));
  }

  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  // Header widget - will be repeated on every page
  Widget buildHeader() {
    return Column(children: [
      reportsCompanyTitle(),
      Center(
        child: Text(
          'สมุดบัญชีขายทองรูปพรรณเก่า',
          style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      Center(
        child: type == 3
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
      // Header with rowspan effect
      Container(
        height: 90,
        decoration: BoxDecoration(
          // color: PdfColors.blue600,
          border: Border(
            left: BorderSide(color: PdfColors.grey400, width: 0.5),
            top: BorderSide(color: PdfColors.grey400, width: 0.5),
            bottom: BorderSide(color: PdfColors.grey400, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Column 1: เลขที่ใบกํากับภาษี (spans 2 rows)
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: PdfColors.grey400, width: 0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    'เลขที่ใบกํากับภาษี',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
            ),
            // Column 2: วัน/เดือน/ปี (spans 2 rows)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: PdfColors.grey400, width: 0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    type == 3 ? 'เดือน' : 'วัน/เดือน/ปี',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
            ),
            // Column 3: ชื่อผู้ซื้อ (spans 2 rows) - only for type 1
            if (type == 1)
              Expanded(
                flex: 7,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: PdfColors.grey400, width: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'ชื่อผู้ซื้อ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ),
              ),
            // เดบิต section (2 levels)
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  // Top level: เดบิต
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: PdfColors.grey400, width: 0.5),
                        bottom:
                            BorderSide(color: PdfColors.grey400, width: 0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'เดบิต',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                  ),
                  // Bottom level: Sub-column
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right:
                              BorderSide(color: PdfColors.grey400, width: 0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'เงินสด/ธนาคาร\nจำนวนเงิน(บาท)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // เครดิต section (2 levels)
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  // Top level: เครดิต
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: PdfColors.grey400, width: 0.5),
                        bottom:
                            BorderSide(color: PdfColors.grey400, width: 0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'เครดิต',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                  ),
                  // Bottom level: Sub-columns
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    color: PdfColors.grey400, width: 0.5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'ขายทอง\nรูปพรรณเก่า\nจำนวนเงิน(บาท)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    color: PdfColors.grey400, width: 0.5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'ภาษีขาย\nจำนวนเงิน(บาท)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  // Build table for data rows with dynamic height
  List<TableRow> tableRows = [];

  // Define column widths to match header flex ratios using FlexColumnWidth
  // For type 1: [6, 5, 7, 4, 4, 4] total = 30 (increased date, decreased name)
  // For type 2/3: [6, 5, 4, 4, 4] total = 23
  // Using FlexColumnWidth instead of FractionColumnWidth for better alignment with Row/Expanded
  Map<int, TableColumnWidth> columnWidths = type == 1
      ? {
          0: FlexColumnWidth(6),      // Order ID
          1: FlexColumnWidth(5),      // Date
          2: FlexColumnWidth(7),      // Customer Name
          3: FlexColumnWidth(4),      // Cash/Bank
          4: FlexColumnWidth(4),      // Sales Amount
          5: FlexColumnWidth(4),      // VAT Amount
        }
      : {
          0: FlexColumnWidth(6),      // Order ID
          1: FlexColumnWidth(5),      // Date
          2: FlexColumnWidth(4),      // Cash/Bank
          3: FlexColumnWidth(4),      // Sales Amount
          4: FlexColumnWidth(4),      // VAT Amount
        };

  if (type == 1 || type == 2 || type == 3) {
    for (int i = 0; i < list.length; i++) {
      final isCancel = list[i].status == "2";
      final textColor = isCancel ? PdfColors.red900 : PdfColors.black;
      final bgColor = i % 2 == 0 ? PdfColors.grey100 : PdfColors.white;

      List<Widget> cells = [
        // Order ID
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              list[i].orderId,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ),
        // Date
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              type == 3
                  ? Global.formatDateMFT(list[i].orderDate.toString())
                  : Global.dateOnly(list[i].orderDate.toString()),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ),
      ];

      // Customer name (only for type 1)
      if (type == 1) {
        cells.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isCancel
                    ? "ยกเลิกเอกสาร***"
                    : getCustomerName(list[i].customer!, forReport: true),
                maxLines: 2,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
            ),
          ),
        );
      }

      // Cash/Bank
      cells.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              isCancel ? "0.00" : Global.format(getCashBank(list[i])),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ),
      );

      // Sales Amount
      cells.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              isCancel ? "0.00" : Global.format(getSalesAmount(list[i])),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ),
      );

      // VAT Amount
      cells.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              isCancel ? "0.00" : Global.format(getVatAmount(list[i])),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ),
      );

      tableRows.add(
        TableRow(
          decoration: BoxDecoration(color: bgColor),
          children: cells,
        ),
      );
    }
  }

  // Build table with borders
  List<Widget> dataRows = [];
  if (tableRows.isNotEmpty) {
    dataRows.add(
      Table(
        border: TableBorder.all(
          color: PdfColors.grey400,
          width: 0.5,
        ),
        columnWidths: columnWidths,
        children: tableRows,
      ),
    );
  }

  // Total row
  dataRows.add(Container(
    height: 24,
    decoration: BoxDecoration(
      color: PdfColors.blue50,
      border: Border(
        top: BorderSide(color: PdfColors.grey400, width: 0.5),
        left: BorderSide(color: PdfColors.grey400, width: 0.8),
        right: BorderSide(color: PdfColors.grey400, width: 0.8),
        bottom: BorderSide(color: PdfColors.grey400, width: 0.8),
      ),
    ),
    child: Row(
      children: [
        Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: PdfColors.grey400, width: 0.5))),
              child: Container(),
            )),
        if (type == 1)
          Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        right:
                            BorderSide(color: PdfColors.grey400, width: 0.5))),
                child: Container(),
              )),
        Expanded(
            flex: type == 1 ? 7 : 5,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: PdfColors.grey400, width: 0.5))),
              child: paddedTextSmall('รวมท้ังหมด',
                  align: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )),
            )),
        Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: PdfColors.grey400, width: 0.5))),
              child: Align(
                alignment: Alignment.centerRight,
                child: paddedTextSmall(
                    type == 1
                        ? Global.formatTruncate(getCashBankTotal(orders))
                        : Global.formatTruncate(getCashBankTotalB(list)),
                    align: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            )),
        Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: PdfColors.grey400, width: 0.5))),
              child: Align(
                alignment: Alignment.centerRight,
                child: paddedTextSmall(
                    type == 1
                        ? Global.formatTruncate(getSalesAmountTotal(orders))
                        : Global.formatTruncate(getSalesAmountTotalB(list)),
                    align: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            )),
        Expanded(
            flex: 4,
            child: Container(
              child: Align(
                alignment: Alignment.centerRight,
                child: paddedTextSmall(
                    type == 1
                        ? Global.formatTruncate(getVatAmountTotal(orders))
                        : Global.formatTruncate(getVatAmountTotalB(list)),
                    align: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            )),
      ],
    ),
  ));

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.portrait,
        header: (context) => buildHeader(),
        build: (context) => dataRows,
        footer: (context) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('*บัญชีเงินสด/ธนาคาร , แสดงในสมุดบัญชีรับ-จ่ายเงิน'),
                Text('${context.pageNumber} / ${context.pagesCount}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
              ]);
        }),
  );
  return pdf.save();
}

// Report 2: PAPHUN sell-used-wholesale (ขายทองรูปพรรณเก่าให้ร้านค้าส่ง)
// F = เงินสด/ธนาคาร = Total received
double getCashBank(OrderModel order) {
  return (order.priceIncludeTax ?? 0);
}

// G = ขายทองรูปพรรณเก่า = Revenue (base without VAT)
double getSalesAmount(OrderModel order) {
  double total = (order.priceExcludeTax ?? 0);
  return total;
}

// H = ภาษีขาย = Sales tax (extract 7% from total)
double getVatAmount(OrderModel order) {
  return (order.taxAmount ?? 0);
}

// Total functions for Type 1 (all orders)
double getCashBankTotal(List<OrderModel?> orders) {
  double total = 0;
  for (var order in orders) {
    if (order != null && order.status != "2") {
      total += getCashBank(order);
    }
  }
  return total;
}

double getSalesAmountTotal(List<OrderModel?> orders) {
  double total = 0;
  for (var order in orders) {
    if (order != null && order.status != "2") {
      total += getSalesAmount(order);
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

// Total functions for Type 2/3 (filtered list)
double getCashBankTotalB(List<OrderModel> list) {
  double total = 0;
  for (var order in list) {
    if (order.orderId != 'ไม่มียอดขาย' && order.status != "2") {
      total += getCashBank(order);
    }
  }
  return total;
}

double getSalesAmountTotalB(List<OrderModel> list) {
  double total = 0;
  for (var order in list) {
    if (order.orderId != 'ไม่มียอดขาย' && order.status != "2") {
      total += getSalesAmount(order);
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
        final TextStyle style = const TextStyle(fontSize: 14)}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );
