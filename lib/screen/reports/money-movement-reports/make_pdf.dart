import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

// Helper function to get order type color for PDF
PdfColor getOrderTypeColor(int? orderTypeId) {
  // All order types use default black color
  return PdfColors.black;
}

Future<Uint8List> makeMoneyMovementReportPdf(
    List<OrderModel>? orders, int type, String date) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  Widget buildHeader() {
    return Column(children: [
      reportsCompanyTitle(),
      Center(
        child: Text(
          'รายงานเส้นทางทองรูปพรรณ-เส้นทางการเงิน',
          style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
        ),
      ),
      Center(
        child: Text(
          'ระหว่างวันที่ : $date',
          style: const TextStyle(decoration: TextDecoration.none, fontSize: 18),
        ),
      ),
      height(),
      reportsHeader(),
      height(h: 2),
      // Table column headers
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
          0: FixedColumnWidth(25),   // ลำดับ
          1: FixedColumnWidth(58),   // เลขที่ใบกํากับภาษี
          2: FixedColumnWidth(55),   // ชื่อลูกค้า
          3: FixedColumnWidth(42),   // วันที่
          4: FixedColumnWidth(45),   // นน.ทองรูปพรรณ 96.5% ขายออก
          5: FixedColumnWidth(45),   // นน.ทองรูปพรรณเก่า 96.5% รับซื้อ
          6: FixedColumnWidth(55),   // จำนวนเงินสุทธิ
          7: FixedColumnWidth(58),   // เลขที่อ้างอิง
          8: FixedColumnWidth(55),   // ร้านทองรับเงิน/จ่ายเงิน
          9: FixedColumnWidth(60),   // ยอดรับเงิน
          10: FixedColumnWidth(60),  // ยอดจ่ายเงิน
          11: FixedColumnWidth(55),  // ร้านทองรับ(จ่าย)เงินสุทธิ
          12: FixedColumnWidth(45),  // ร้านทองเพิ่ม/ลดให้
          13: FixedColumnWidth(55),  // เงินสดรับ(จ่าย)
          14: FixedColumnWidth(55),  // เงินโอน/ฝากธนาคาร
          15: FixedColumnWidth(50),  // บัตรเครดิต
          16: FixedColumnWidth(50),  // อื่นๆ
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
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('เลขที่ใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('ชื่อลูกค้า',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('วันที่',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('นน.ทองรูปพรรณ \n96.5% ขายออก (กรัม)',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('นน.ทองรูปพรรณเก่า \n96.5% รับซื้อ (กรัม)',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('จำนวนเงินสุทธิ \n(บาท)',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall(
                  'เลขที่อ้างอิง\nใบส่งของ/ใบ\nเสร็จรับเงิน\nใบรับซื้อทองเก่า',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('ร้านทองรับเงิน/\nร้านทองจ่ายเงิน',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('ยอดรับเงิน',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('ยอดจ่ายเงิน',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('ร้านทองรับ\n(จ่าย)เงินสุทธิ',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('ร้านทองเพิ่ม/\nลดให้',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('เงินสดรับ\n(จ่าย)',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('เงินโอน/\nฝากธนาคาร',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('บัตรเครดิต',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall('อื่นๆ',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.center),
            ],
          ),
        ],
      ),
    ]);
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
        0: FixedColumnWidth(25),   // ลำดับ
        1: FixedColumnWidth(58),   // เลขที่ใบกํากับภาษี
        2: FixedColumnWidth(55),   // ชื่อลูกค้า
        3: FixedColumnWidth(42),   // วันที่
        4: FixedColumnWidth(45),   // นน.ทองรูปพรรณ 96.5% ขายออก
        5: FixedColumnWidth(45),   // นน.ทองรูปพรรณเก่า 96.5% รับซื้อ
        6: FixedColumnWidth(55),   // จำนวนเงินสุทธิ
        7: FixedColumnWidth(58),   // เลขที่อ้างอิง
        8: FixedColumnWidth(55),   // ร้านทองรับเงิน/จ่ายเงิน
        9: FixedColumnWidth(60),   // ยอดรับเงิน
        10: FixedColumnWidth(60),  // ยอดจ่ายเงิน
        11: FixedColumnWidth(55),  // ร้านทองรับ(จ่าย)เงินสุทธิ
        12: FixedColumnWidth(45),  // ร้านทองเพิ่ม/ลดให้
        13: FixedColumnWidth(55),  // เงินสดรับ(จ่าย)
        14: FixedColumnWidth(55),  // เงินโอน/ฝากธนาคาร
        15: FixedColumnWidth(50),  // บัตรเครดิต
        16: FixedColumnWidth(50),  // อื่นๆ
      },
      children: [
        // Data rows with color coding
        for (int i = 0; i < orders!.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: i % 2 == 0 ? PdfColors.white : PdfColors.grey100),
            children: [
              paddedTextSmall('${i + 1}',
                  style: TextStyle(fontSize: 8), align: TextAlign.center),
              paddedTextSmall(orders[i].orderId,
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2" ? PdfColors.red900 : PdfColors.black),
                  align: TextAlign.center),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "***ยกเลิกเอกสาร"
                      : '${getCustomerName(orders[i].customer!)}',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2" ? PdfColors.red900 : PdfColors.black)),
              paddedTextSmall(Global.dateOnly(orders[i].orderDate.toString()),
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2" ? PdfColors.red900 : PdfColors.black)),
              // paddedTextSmall(Global.timeOnly(orders[i].createdDate.toString()),
              //     style: TextStyle(fontSize: 8)),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : (orders[i].orderTypeId == 1)
                          ? Global.format(getWeight(orders[i]))
                          : "",
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2" ? PdfColors.red900 : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : (orders[i].orderTypeId == 2)
                          ? Global.format(getWeight(orders[i]))
                          : "",
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2" ? PdfColors.red900 : PdfColors.black),
                  align: TextAlign.right),
              if (orders[i].orderTypeId == 1)
                paddedTextSmall(
                    orders[i].status == "2"
                        ? "0.00"
                        : Global.format(orders[i].priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 8,
                        color: orders[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.green),
                    align: TextAlign.right),
              if (orders[i].orderTypeId == 2)
                paddedTextSmall(
                    orders[i].status == "2"
                        ? "0.00"
                        : '(${Global.format(orders[i].priceIncludeTax ?? 0)})',
                    style: TextStyle(
                        fontSize: 8,
                        color: orders[i].status == "2"
                            ? PdfColors.red900
                            : PdfColors.red),
                    align: TextAlign.right),
              paddedTextSmall(
                  orders[i].status == "2" ? "" : getReferenceNumber(orders, orders[i]),
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2" ? PdfColors.red900 : PdfColors.black)),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? ""
                      : Global.getPayTittle(
                          payToCustomerOrShopValue(orders, orders[i])),
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2" ? PdfColors.red900 : PdfColors.black)),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : (orders[i].orderTypeId == 1)
                          ? Global.format(orders[i].priceIncludeTax ?? 0)
                          : "",
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2"
                          ? PdfColors.red900
                          : orders[i].orderTypeId == 1
                              ? PdfColors.green
                              : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : (orders[i].orderTypeId == 2)
                          ? '(${Global.format(orders[i].priceIncludeTax ?? 0)})'
                          : "",
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2"
                          ? PdfColors.red900
                          : orders[i].orderTypeId == 2
                              ? PdfColors.red
                              : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : payToCustomerOrShopValue(orders, orders[i]) > 0
                          ? Global.format(
                              payToCustomerOrShopValue(orders, orders[i]))
                          : payToCustomerOrShopValue(orders, orders[i]) < 0
                              ? '(${Global.format(-payToCustomerOrShopValue(orders, orders[i]))})'
                              : '',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2"
                          ? PdfColors.red900
                          : payToCustomerOrShopValue(orders, orders[i]) > 0
                              ? PdfColors.green
                              : payToCustomerOrShopValue(orders, orders[i]) < 0
                                  ? PdfColors.red
                                  : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : getDiscountAddValueForPair(orders, orders[i]) == 0
                          ? ""
                          : "(${Global.format(getDiscountAddValueForPair(orders, orders[i]).abs())})",
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2" ? PdfColors.red900 : PdfColors.red),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : getCashPayment(orders, orders[i]) == 0
                          ? ""
                          : orders[i].orderTypeId == 1
                              ? Global.format(getCashPayment(orders, orders[i]))
                              : '(${Global.format(getCashPayment(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2"
                          ? PdfColors.red900
                          : getCashPayment(orders, orders[i]) == 0
                              ? PdfColors.black
                              : orders[i].orderTypeId == 1
                                  ? PdfColors.green
                                  : PdfColors.red),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : getTransferPayment(orders, orders[i]) == 0
                          ? ""
                          : orders[i].orderTypeId == 1
                              ? Global.format(getTransferPayment(orders, orders[i]))
                              : '(${Global.format(getTransferPayment(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2"
                          ? PdfColors.red900
                          : getTransferPayment(orders, orders[i]) == 0
                              ? PdfColors.black
                              : orders[i].orderTypeId == 1
                                  ? PdfColors.green
                                  : PdfColors.red),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : getCreditPayment(orders, orders[i]) == 0
                          ? ""
                          : orders[i].orderTypeId == 1
                              ? Global.format(getCreditPayment(orders, orders[i]))
                              : '(${Global.format(getCreditPayment(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2"
                          ? PdfColors.red900
                          : getCreditPayment(orders, orders[i]) == 0
                              ? PdfColors.black
                              : orders[i].orderTypeId == 1
                                  ? PdfColors.green
                                  : PdfColors.red),
                  align: TextAlign.right),
              paddedTextSmall(
                  orders[i].status == "2"
                      ? "0.00"
                      : getOtherPayment(orders, orders[i]) == 0
                          ? ""
                          : orders[i].orderTypeId == 1
                              ? Global.format(getOtherPayment(orders, orders[i]))
                              : '(${Global.format(getOtherPayment(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].status == "2"
                          ? PdfColors.red900
                          : getOtherPayment(orders, orders[i]) == 0
                              ? PdfColors.black
                              : orders[i].orderTypeId == 1
                                  ? PdfColors.green
                                  : PdfColors.red),
                  align: TextAlign.right),
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
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              // paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall(Global.format(getWeightTotalSN(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(getWeightTotalBU(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  priceIncludeTaxTotalMovement(orders) > 0
                      ? Global.format(priceIncludeTaxTotalMovement(orders))
                      : priceIncludeTaxTotalMovement(orders) < 0
                          ? '(${Global.format(-priceIncludeTaxTotalMovement(orders))})'
                          : '',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: priceIncludeTaxTotalMovement(orders) > 0
                          ? PdfColors.green
                          : priceIncludeTaxTotalMovement(orders) < 0
                              ? PdfColors.red
                              : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall(Global.format(priceIncludeTaxTotalSN(orders)),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.green,
                  ),
                  align: TextAlign.right),
              paddedTextSmall(
                  priceIncludeTaxTotalBU(orders) == 0
                      ? ""
                      : '(${Global.format(priceIncludeTaxTotalBU(orders))})',
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.bold, color: PdfColors.red),
                  align: TextAlign.right),
              paddedTextSmall(
                  payToCustomerOrShopValueTotalAlternative(orders) == 0
                      ? ""
                      : payToCustomerOrShopValueTotalAlternative(orders) > 0
                          ? Global.format(payToCustomerOrShopValueTotalAlternative(orders))
                          : '(${Global.format(payToCustomerOrShopValueTotalAlternative(orders).abs())})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color:
                          payToCustomerOrShopValueTotalAlternative(orders) > 0
                              ? PdfColors.green
                              : payToCustomerOrShopValueTotalAlternative(orders) < 0
                                  ? PdfColors.red
                                  : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  discountTotal(orders) == 0
                      ? ""
                      : '(${Global.format(discountTotal(orders).abs())})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red),
                  align: TextAlign.right),
              paddedTextSmall(
                  getCashPaymentTotal(orders) == 0
                      ? ""
                      : getCashPaymentTotal(orders) > 0
                          ? Global.format(getCashPaymentTotal(orders))
                          : '(${Global.format(-getCashPaymentTotal(orders))})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: getCashPaymentTotal(orders) > 0
                          ? PdfColors.green
                          : getCashPaymentTotal(orders) < 0
                              ? PdfColors.red
                              : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  getTransferPaymentTotal(orders) == 0
                      ? ""
                      : getTransferPaymentTotal(orders) > 0
                          ? Global.format(getTransferPaymentTotal(orders))
                          : '(${Global.format(-getTransferPaymentTotal(orders))})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: getTransferPaymentTotal(orders) > 0
                          ? PdfColors.green
                          : getTransferPaymentTotal(orders) < 0
                              ? PdfColors.red
                              : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  getCreditPaymentTotal(orders) == 0
                      ? ""
                      : getCreditPaymentTotal(orders) > 0
                          ? Global.format(getCreditPaymentTotal(orders))
                          : '(${Global.format(-getCreditPaymentTotal(orders))})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: getCreditPaymentTotal(orders) > 0
                          ? PdfColors.green
                          : getCreditPaymentTotal(orders) < 0
                              ? PdfColors.red
                              : PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  getOtherPaymentTotal(orders) == 0
                      ? ""
                      : getOtherPaymentTotal(orders) > 0
                          ? Global.format(getOtherPaymentTotal(orders))
                          : '(${Global.format(-getOtherPaymentTotal(orders))})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: getOtherPaymentTotal(orders) > 0
                          ? PdfColors.green
                          : getOtherPaymentTotal(orders) < 0
                              ? PdfColors.red
                              : PdfColors.black),
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

double getCashPayment(List<OrderModel> orders, OrderModel order) {
  // Check if this is a paired transaction
  var pairedOrders = orders
      .where((e) => e.pairId == order.pairId && e.orderId != order.orderId)
      .toList();

  if (pairedOrders.isNotEmpty) {
    // This is a paired transaction
    // Only show payment in the row that shows the net value
    double netValue = payToCustomerOrShopValue(orders, order);
    if (netValue == 0) {
      // This is not the display row
      return 0;
    }

    // This is the display row - show the payment from the appropriate order
    if (netValue > 0) {
      // Net is positive, show sell order's cash payment
      if (order.orderTypeId == 1) {
        return order.cashPayment ?? 0;
      } else {
        // Get the sell order's payment
        var sellOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 1,
          orElse: () => order
        );
        return sellOrder.cashPayment ?? 0;
      }
    } else {
      // Net is negative, show buy order's cash payment
      if (order.orderTypeId == 2) {
        return order.cashPayment ?? 0;
      } else {
        // Get the buy order's payment
        var buyOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 2,
          orElse: () => order
        );
        return buyOrder.cashPayment ?? 0;
      }
    }
  }

  // Not paired - use original logic
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 1 || order.orderTypeId == 4) {
      return order.cashPayment ?? 0;
    }
    return 0;
  } else {
    if (order.orderTypeId == 2 || order.orderTypeId == 44) {
      return order.cashPayment != null ? order.cashPayment ?? 0 : 0;
    }
    return 0;
  }
}

double getCashPaymentTotal(List<OrderModel> orders) {
  double total = 0;
  Set<int> processedPairs = {};

  for (int i = 0; i < orders.length; i++) {
    var order = orders[i];

    // Handle paired transactions - only process once per pair
    if (order.pairId != null && order.pairId != 0) {
      if (processedPairs.contains(order.pairId)) {
        continue; // Skip if already processed this pair
      }
      processedPairs.add(order.pairId!);

      // Find all orders in this pair
      var pairedOrders = orders.where((e) => e.pairId == order.pairId).toList();

      // Calculate net value for the pair
      double sellTotal = 0;
      double buyTotal = 0;
      double sellCash = 0;
      double buyCash = 0;

      for (var o in pairedOrders) {
        if (o.orderTypeId == 1) {
          sellTotal += o.priceIncludeTax ?? 0;
          sellCash += o.cashPayment ?? 0;
        } else if (o.orderTypeId == 2) {
          buyTotal += o.priceIncludeTax ?? 0;
          buyCash += o.cashPayment ?? 0;
        }
      }

      // Net = sell - buy
      if (sellTotal > buyTotal) {
        // Shop receives money - add sell order's cash payment
        total += sellCash;
      } else if (buyTotal > sellTotal) {
        // Shop pays money - subtract buy order's cash payment
        total -= buyCash;
      }
      // If equal, no cash exchange
    } else {
      // Non-paired orders
      if (order.orderTypeId == 1) {
        total += order.cashPayment ?? 0;
      } else if (order.orderTypeId == 2) {
        total -= order.cashPayment ?? 0;
      }
    }
  }
  return total;
}

double getTransferPayment(List<OrderModel> orders, OrderModel order) {
  // Check if this is a paired transaction
  var pairedOrders = orders
      .where((e) => e.pairId == order.pairId && e.orderId != order.orderId)
      .toList();

  if (pairedOrders.isNotEmpty) {
    // This is a paired transaction
    // Only show payment in the row that shows the net value
    double netValue = payToCustomerOrShopValue(orders, order);
    if (netValue == 0) {
      // This is not the display row
      return 0;
    }

    // This is the display row - show the payment from the appropriate order
    if (netValue > 0) {
      // Net is positive, show sell order's transfer payment
      if (order.orderTypeId == 1) {
        return (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
      } else {
        // Get the sell order's payment
        var sellOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 1,
          orElse: () => order
        );
        return (sellOrder.transferPayment ?? 0) + (sellOrder.depositPayment ?? 0);
      }
    } else {
      // Net is negative, show buy order's transfer payment
      if (order.orderTypeId == 2) {
        return (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
      } else {
        // Get the buy order's payment
        var buyOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 2,
          orElse: () => order
        );
        return (buyOrder.transferPayment ?? 0) + (buyOrder.depositPayment ?? 0);
      }
    }
  }

  // Not paired - use original logic
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 1 || order.orderTypeId == 4) {
      return (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
    }
    return 0;
  } else {
    if (order.orderTypeId == 2 || order.orderTypeId == 44) {
      return (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
    }
    return 0;
  }
}

double getTransferPaymentTotal(List<OrderModel> orders) {
  double total = 0;
  Set<int> processedPairs = {};

  for (int i = 0; i < orders.length; i++) {
    var order = orders[i];

    // Handle paired transactions - only process once per pair
    if (order.pairId != null && order.pairId != 0) {
      if (processedPairs.contains(order.pairId)) {
        continue; // Skip if already processed this pair
      }
      processedPairs.add(order.pairId!);

      // Find all orders in this pair
      var pairedOrders = orders.where((e) => e.pairId == order.pairId).toList();

      // Calculate net value for the pair
      double sellTotal = 0;
      double buyTotal = 0;
      double sellTransfer = 0;
      double buyTransfer = 0;

      for (var o in pairedOrders) {
        if (o.orderTypeId == 1) {
          sellTotal += o.priceIncludeTax ?? 0;
          sellTransfer += (o.transferPayment ?? 0) + (o.depositPayment ?? 0);
        } else if (o.orderTypeId == 2) {
          buyTotal += o.priceIncludeTax ?? 0;
          buyTransfer += (o.transferPayment ?? 0) + (o.depositPayment ?? 0);
        }
      }

      // Net = sell - buy
      if (sellTotal > buyTotal) {
        // Shop receives money - add sell order's transfer payment
        total += sellTransfer;
      } else if (buyTotal > sellTotal) {
        // Shop pays money - subtract buy order's transfer payment
        total -= buyTransfer;
      }
      // If equal, no transfer exchange
    } else {
      // Non-paired orders
      if (order.orderTypeId == 1) {
        total += (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
      } else if (order.orderTypeId == 2) {
        total -= (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
      }
    }
  }
  return total;
}

double getCreditPayment(List<OrderModel> orders, OrderModel order) {
  // Check if this is a paired transaction
  var pairedOrders = orders
      .where((e) => e.pairId == order.pairId && e.orderId != order.orderId)
      .toList();

  if (pairedOrders.isNotEmpty) {
    // This is a paired transaction
    // Only show payment in the row that shows the net value
    double netValue = payToCustomerOrShopValue(orders, order);
    if (netValue == 0) {
      // This is not the display row
      return 0;
    }

    // This is the display row - show the payment from the appropriate order
    if (netValue > 0) {
      // Net is positive, show sell order's credit payment
      if (order.orderTypeId == 1) {
        return order.creditPayment ?? 0;
      } else {
        // Get the sell order's payment
        var sellOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 1,
          orElse: () => order
        );
        return sellOrder.creditPayment ?? 0;
      }
    } else {
      // Net is negative, show buy order's credit payment
      if (order.orderTypeId == 2) {
        return order.creditPayment ?? 0;
      } else {
        // Get the buy order's payment
        var buyOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 2,
          orElse: () => order
        );
        return buyOrder.creditPayment ?? 0;
      }
    }
  }

  // Not paired - use original logic
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 1 || order.orderTypeId == 4) {
      return order.creditPayment ?? 0;
    }
    return 0;
  } else {
    if (order.orderTypeId == 2 || order.orderTypeId == 44) {
      return order.creditPayment != null ? order.creditPayment ?? 0 : 0;
    }
    return 0;
  }
}

double getCreditPaymentTotal(List<OrderModel> orders) {
  double total = 0;
  Set<int> processedPairs = {};

  for (int i = 0; i < orders.length; i++) {
    var order = orders[i];

    // Handle paired transactions - only process once per pair
    if (order.pairId != null && order.pairId != 0) {
      if (processedPairs.contains(order.pairId)) {
        continue; // Skip if already processed this pair
      }
      processedPairs.add(order.pairId!);

      // Find all orders in this pair
      var pairedOrders = orders.where((e) => e.pairId == order.pairId).toList();

      // Calculate net value for the pair
      double sellTotal = 0;
      double buyTotal = 0;
      double sellCredit = 0;
      double buyCredit = 0;

      for (var o in pairedOrders) {
        if (o.orderTypeId == 1) {
          sellTotal += o.priceIncludeTax ?? 0;
          sellCredit += o.creditPayment ?? 0;
        } else if (o.orderTypeId == 2) {
          buyTotal += o.priceIncludeTax ?? 0;
          buyCredit += o.creditPayment ?? 0;
        }
      }

      // Net = sell - buy
      if (sellTotal > buyTotal) {
        // Shop receives money - add sell order's credit payment
        total += sellCredit;
      } else if (buyTotal > sellTotal) {
        // Shop pays money - subtract buy order's credit payment
        total -= buyCredit;
      }
      // If equal, no credit exchange
    } else {
      // Non-paired orders
      if (order.orderTypeId == 1) {
        total += order.creditPayment ?? 0;
      } else if (order.orderTypeId == 2) {
        total -= order.creditPayment ?? 0;
      }
    }
  }
  return total;
}

double getOtherPayment(List<OrderModel> orders, OrderModel order) {
  // Check if this is a paired transaction
  var pairedOrders = orders
      .where((e) => e.pairId == order.pairId && e.orderId != order.orderId)
      .toList();

  if (pairedOrders.isNotEmpty) {
    // This is a paired transaction
    // Only show payment in the row that shows the net value
    double netValue = payToCustomerOrShopValue(orders, order);
    if (netValue == 0) {
      // This is not the display row
      return 0;
    }

    // This is the display row - show the payment from the appropriate order
    if (netValue > 0) {
      // Net is positive, show sell order's other payment
      if (order.orderTypeId == 1) {
        return order.otherPayment ?? 0;
      } else {
        // Get the sell order's payment
        var sellOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 1,
          orElse: () => order
        );
        return sellOrder.otherPayment ?? 0;
      }
    } else {
      // Net is negative, show buy order's other payment
      if (order.orderTypeId == 2) {
        return order.otherPayment ?? 0;
      } else {
        // Get the buy order's payment
        var buyOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 2,
          orElse: () => order
        );
        return buyOrder.otherPayment ?? 0;
      }
    }
  }

  // Not paired - use original logic
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 1 || order.orderTypeId == 4) {
      return order.otherPayment ?? 0;
    }
    return 0;
  } else {
    if (order.orderTypeId == 2 || order.orderTypeId == 44) {
      return order.otherPayment != null ? order.otherPayment ?? 0 : 0;
    }
    return 0;
  }
}

double getOtherPaymentTotal(List<OrderModel> orders) {
  double total = 0;
  Set<int> processedPairs = {};

  for (int i = 0; i < orders.length; i++) {
    var order = orders[i];

    // Handle paired transactions - only process once per pair
    if (order.pairId != null && order.pairId != 0) {
      if (processedPairs.contains(order.pairId)) {
        continue; // Skip if already processed this pair
      }
      processedPairs.add(order.pairId!);

      // Find all orders in this pair
      var pairedOrders = orders.where((e) => e.pairId == order.pairId).toList();

      // Calculate net value for the pair
      double sellTotal = 0;
      double buyTotal = 0;
      double sellOther = 0;
      double buyOther = 0;

      for (var o in pairedOrders) {
        if (o.orderTypeId == 1) {
          sellTotal += o.priceIncludeTax ?? 0;
          sellOther += o.otherPayment ?? 0;
        } else if (o.orderTypeId == 2) {
          buyTotal += o.priceIncludeTax ?? 0;
          buyOther += o.otherPayment ?? 0;
        }
      }

      // Net = sell - buy
      if (sellTotal > buyTotal) {
        // Shop receives money - add sell order's other payment
        total += sellOther;
      } else if (buyTotal > sellTotal) {
        // Shop pays money - subtract buy order's other payment
        total -= buyOther;
      }
      // If equal, no other exchange
    } else {
      // Non-paired orders
      if (order.orderTypeId == 1) {
        total += order.otherPayment ?? 0;
      } else if (order.orderTypeId == 2) {
        total -= order.otherPayment ?? 0;
      }
    }
  }
  return total;
}

double payToCustomerOrShopValue(List<OrderModel> orders, OrderModel order) {
  var orders0 = orders
      .where((e) => e.pairId == order.pairId && e.orderId != order.orderId)
      .toList();
  double amount = 0;
  double buy = 0;
  double sell = 0;
  if (orders0.isNotEmpty) {
    orders0.add(order);

    // Find which order has higher priceIncludeTax - only that row should display the value
    OrderModel? higherOrder;
    double maxPrice = 0;
    for (var o in orders0) {
      double price = o.priceIncludeTax ?? 0;
      if (price > maxPrice) {
        maxPrice = price;
        higherOrder = o;
      }
    }

    // If current order is not the higher one, return 0 (don't display in this row)
    if (higherOrder?.orderId != order.orderId) {
      return 0;
    }

    // Calculate net amount using Cash Received - Cash Paid
    for (int i = 0; i < orders0.length; i++) {
      int type = orders0[i].orderTypeId!;
      double price = orders0[i].priceIncludeTax!;

      if (type == 1) {
        // Sell - this is cash received
        sell += price;
      }
      if (type == 2) {
        // Buy - this is cash paid
        buy += price;
      }
    }

    // Net = Received - Paid
    amount = sell - buy;

    return amount;
  }

  // For non-paired transactions
  // Buy orders (orderTypeId 2, 44) should return negative value
  // Sell orders (orderTypeId 1, 4) should return positive value
  if (order.orderTypeId == 2 || order.orderTypeId == 44) {
    return -(order.priceIncludeTax ?? 0);
  }
  return order.priceIncludeTax ?? 0;
}

// Get discount/add value for paired transactions - only from the display order
double getDiscountAddValueForPair(List<OrderModel> orders, OrderModel order) {
  var orders0 = orders
      .where((e) => e.pairId == order.pairId && e.orderId != order.orderId)
      .toList();

  if (orders0.isNotEmpty) {
    orders0.add(order);

    // Find which order has higher priceIncludeTax - only that row should display the value
    OrderModel? higherOrder;
    double maxPrice = 0;
    for (var o in orders0) {
      double price = o.priceIncludeTax ?? 0;
      if (price > maxPrice) {
        maxPrice = price;
        higherOrder = o;
      }
    }

    // If current order is not the higher one, return 0 (don't display in this row)
    if (higherOrder?.orderId != order.orderId) {
      return 0;
    }

    // For paired transactions, return only the discount/add value from the higher order
    // The discount/addPrice is applied once to the transaction, not to each order separately
    return addDisValue(higherOrder?.discount ?? 0, higherOrder?.addPrice ?? 0);
  }

  // For non-paired transactions, return the single order's discount/add value
  return addDisValue(order.discount ?? 0, order.addPrice ?? 0);
}

double payToCustomerOrShopValueTotal(List<OrderModel> orders) {
  double totalAmount = 0;
  Set<int> processedPairs = {};

  for (OrderModel order in orders) {
    if (order.pairId != null && order.pairId != 0) {
      // Fixed: Changed == 0 to != 0
      // For paired orders, calculate once per pair
      if (!processedPairs.contains(order.pairId)) {
        processedPairs.add(order.pairId!);
        totalAmount += payToCustomerOrShopValue(orders, order);
      }
    } else {
      // For unpaired orders, add their individual amount
      totalAmount += payToCustomerOrShopValue(orders, order);
    }
  }

  return totalAmount;
}

// Alternative approach - Process each order but avoid double counting pairs
double payToCustomerOrShopValueTotalAlternative(List<OrderModel> orders) {
  double totalAmount = 0;

  for (OrderModel order in orders) {
    totalAmount += payToCustomerOrShopValue(orders, order);
  }

  return totalAmount;
}

double payToCustomerOrShopValueB(List<OrderModel> orders, OrderModel order) {
  var orders0 = orders
      .where((e) => e.pairId == order.pairId && e.orderId != order.orderId)
      .toList();
  double amount = 0;
  double buy = 0;
  double sell = 0;
  if (orders0.isNotEmpty) {
    orders0.add(order);
    for (int i = 0; i < orders0.length; i++) {
      for (int j = 0; j < orders0[i].details!.length; j++) {
        int type = orders0[i].orderTypeId!;
        double price = orders0[i].details![j].priceIncludeTax!;

        if (type == 2) {
          buy += -price;
        }
        if (type == 1) {
          sell += price;
        }
      }
    }
    double discount = order.discount ?? 0;
    amount = sell + buy;
    amount = amount < 0 ? -amount : amount;
    amount = discount != 0 ? amount - discount : amount;
    amount = (sell + buy) < 0 ? -amount : amount;
    return amount;
  }

  return order.priceIncludeTax ?? 0;
}

String getReferenceNumber(List<OrderModel?> orders, OrderModel? order) {
  var orders0 = orders
      .where((e) => e?.pairId == order?.pairId && e?.orderId != order?.orderId)
      .toList();
  if (orders0.isNotEmpty) {
    return orders0.first!.orderId;
  }
  return "";
}

Widget paddedTextSmall(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 10)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );
