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

Future<Uint8List> makeBuyUsedThengGoldReportPdf(List<OrderModel?> orders,
    int type, String date, DateTime fromDate, DateTime toDate) async {
  List<OrderModel> list = [];
  List<OrderModel> list3 = [];

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
        list3.add(order);
      }
    } else {
      // No orders for this day, add one "no sales" record
      list.add(OrderModel(
          orderId: 'ไม่มียอดซื้อ',
          orderDate: indexDay,
          customer: orders.isNotEmpty ? orders.first!.customer : null));
    }
  }

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
  //           color: PdfColor.fromHex('#c5e1a5'),
  //           // Or whatever pink shade you prefer
  //           borderRadius: BorderRadius.circular(0), // Optional: rounded corners
  //         ),
  //         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //         child: getHeaderText(type))));
  // widgets.add(height());
  widgets.add(reportsCompanyTitle());
  widgets.add(Center(
    child: Text(
      'รายงานซื้อทองคำแท่งเก่า',
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: 20,
          fontWeight: FontWeight.bold),
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
            'เดือนภาษี : ${Global.formatDateMFT(fromDate.toString())} ปี : ${Global.formatDateYFT(fromDate.toString())} ระหว่างวันที่ : $date',
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
            paddedTextSmall('เลขที่ใบสำคัญจ่าย',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.white),
                align: TextAlign.center),
            if (type == 1)
              paddedTextSmall('ชื่อผู้ขาย',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white),
                  align: TextAlign.center),
            if (type == 1)
              paddedTextSmall('เลขประจำตัวผู้เสียภาษี',
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
            paddedTextSmall('จำนวนเงิน (บาท)',
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
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : null)),
                paddedTextSmall(
                    Global.dateOnly(orders[i]!.orderDate.toString()),
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
                paddedTextSmall('${orders[i]!.status == "2" ? "ยกเลิกเอกสาร" : getCustomerName(orders[i]!.customer!)} ',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]!.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall(orders[i]!.status == "2" ? "" :
                orders[i]!.customer?.taxNumber != null
                        ? orders[i]!.customer?.taxNumber ?? ''
                        : '',
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
                paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format(getWeightBaht(orders[i]!)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format4(getWeight(orders[i]!)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format(orders[i]!.priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.green600),
                    align: TextAlign.right),
              ],
            ),
        // Data rows with color coding for type 2
        if (type == 2)
          for (int i = 0; i < list.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: list[i].status == "2"
                      ? PdfColors.red100
                      : PdfColors.white),
              children: [
                paddedTextSmall('${i + 1}',
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall(Global.dateOnly(list[i].orderDate.toString()),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall(list[i].orderId,
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall('ทองคำแท่ง',
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.orange600,
                        fontWeight: FontWeight.bold),
                    align: TextAlign.center),
                // paddedTextSmall(
                //     Global.format((list[i].weight ?? 0) / getUnitWeightValue()),
                //     style: TextStyle(
                //         fontSize: 10,
                //         color: list[i].status == "2"
                //             ? PdfColors.red900
                //             : PdfColors.blue600),
                //     align: TextAlign.right),
                paddedTextSmall(list[i].status == "2" ? "0.00" :
                Global.format((list[i].weightBath ?? 0)),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(list[i].status == "2" ? "0.00" : Global.format4(list[i].weight ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(list[i].status == "2" ? "0.00" : Global.format(list[i].priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.green600),
                    align: TextAlign.right),
              ],
            ),
        // Data rows with color coding for type 3
        if (type == 3)
          for (int i = 0; i < list3.length; i++)
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: BoxDecoration(
                  color: list3[i].status == "2"
                      ? PdfColors.red100
                      : PdfColors.white),
              children: [
                paddedTextSmall('${i + 1}',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall(Global.dateOnly(list3[i].orderDate.toString()),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall(list3[i].orderId,
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            list3[i].status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall('ทองคำแท่ง',
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.orange600,
                        fontWeight: FontWeight.bold),
                    align: TextAlign.center),
                // paddedTextSmall(
                //     Global.format(
                //         (list3[i].weight ?? 0) / getUnitWeightValue()),
                //     style: TextStyle(
                //         fontSize: 10,
                //         color: list3[i].status == "2"
                //             ? PdfColors.red900
                //             : PdfColors.blue600),
                //     align: TextAlign.right),
                paddedTextSmall(list3[i].status == "2" ? "0.00" :
                Global.format(
                        (list3[i].weightBath ?? 0)),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(list3[i].status == "2" ? "0.00" : Global.format4(list3[i].weight ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(list3[i].status == "2" ? "0.00" : Global.format(list3[i].priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: list3[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.green600),
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
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall(
                    Global.formatDateMFT(orders[i]!.orderDate.toString()),
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall(orders[i]!.orderId,
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            orders[i]?.status == "2" ? PdfColors.red900 : null),
                    align: TextAlign.center),
                paddedTextSmall('ทองคำแท่ง',
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]?.status == "2"
                            ? PdfColors.red900
                            : PdfColors.orange600,
                        fontWeight: FontWeight.bold),
                    align: TextAlign.center),
                // paddedTextSmall(
                //     Global.format(
                //         (orders[i]!.weight ?? 0) / getUnitWeightValue()),
                //     style: TextStyle(
                //         fontSize: 10,
                //         color: orders[i]!.status == "2"
                //             ? PdfColors.red900
                //             : PdfColors.blue600),
                //     align: TextAlign.right),
                paddedTextSmall(orders[i]!.status == "2" ? "0.00" :
                Global.format(
                        (orders[i]!.weightBath ?? 0)),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format4(orders[i]!.weight ?? 0),
                    style: TextStyle(
                        fontSize: 10,
                        color: orders[i]!.status == "2"
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format(orders[i]!.priceIncludeTax ?? 0),
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
            verticalAlignment: TableCellVerticalAlignment.middle,
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
            ]),
      ],
    ),
  ));

  widgets.add(height());

  widgets.add(Row(
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
        build: (context) => widgets,
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
  if (type == 2) {
    return Text(
      'จัดลำดับตามวันที่',
      style: TextStyle(
        color: PdfColors.black, // White text on pink background
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  if (type == 3) {
    return Text(
      'จัดลำดับตามวันที่\nเฉพาะวันที่มียอดขาย',
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
