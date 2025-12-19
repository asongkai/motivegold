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

Future<Uint8List> makeThengMoneyMovementReportPdf(
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
          'รายงานเส้นทางทองคำแท่ง-เส้นทางการเงิน',
          style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 20,
              fontWeight: FontWeight.bold),
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
          4: FixedColumnWidth(45),   // นน.ทองคำแท่ง ขายออก
          5: FixedColumnWidth(45),   // นน.ทองคำแท่ง รับซื้อ
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
            decoration: const BoxDecoration(color: PdfColors.white),
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              paddedTextSmall('ลำดับ',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('เลขที่ใบกํากับภาษี',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('ชื่อลูกค้า',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('วันที่',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('นน.ทองคำแท่ง\nขายออก (กรัม)',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('นน.ทองคำแท่ง\nรับซื้อ (กรัม)',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('จำนวนเงินสุทธิ \n(บาท)',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall(
                  'เลขที่อ้างอิง\nใบส่งของ/ใบ\nเสร็จรับเงิน\nใบรับซื้อทองแท่ง',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('ร้านทองรับเงิน/\nร้านทองจ่ายเงิน',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('ยอดรับเงิน',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('ยอดจ่ายเงิน',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('ร้านทองรับ\n(จ่าย)เงินสุทธิ',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('ร้านทองเพิ่ม/\nลดให้',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('เงินสดรับ\n(จ่าย)',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('เงินโอน/\nฝากธนาคาร',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('บัตรเครดิต',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall('อื่นๆ',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
            ],
          ),
        ],
      ),
    ]);
  }

  List<Widget> dataRows = [];

  // Apply modern design pattern
  dataRows.add(Container(
    child: Table(
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
        4: FixedColumnWidth(45),   // นน.ทองคำแท่ง ขายออก
        5: FixedColumnWidth(45),   // นน.ทองคำแท่ง รับซื้อ
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
                  style: TextStyle(fontSize: 8), align: TextAlign.center),
              paddedTextSmall('${getCustomerName(orders[i].customer!)}',
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(Global.dateOnly(orders[i].orderDate.toString()),
                  style: TextStyle(fontSize: 8)),
              // paddedTextSmall(Global.timeOnly(orders[i].createdDate.toString()),
              //     style: TextStyle(fontSize: 8)),
              paddedTextSmall(
                  (orders[i].orderTypeId == 4)
                      ? Global.format4(getWeight(orders[i]))
                      : "",
                  style: TextStyle(fontSize: 8),
                  align: TextAlign.right),
              paddedTextSmall(
                  (orders[i].orderTypeId == 44)
                      ? Global.format4(getWeight(orders[i]))
                      : "",
                  style: TextStyle(fontSize: 8),
                  align: TextAlign.right),
              if (orders[i].orderTypeId == 4)
                paddedTextSmall(Global.format(orders[i].priceIncludeTax ?? 0),
                    style: TextStyle(
                        fontSize: 8,
                        color: getOrderTypeColor(orders[i].orderTypeId)),
                    align: TextAlign.right),
              if (orders[i].orderTypeId == 44)
                paddedTextSmall(
                    '(${Global.format(orders[i].priceIncludeTax ?? 0)})',
                    style: TextStyle(
                        fontSize: 8,
                        color: getOrderTypeColor(orders[i].orderTypeId)),
                    align: TextAlign.right),
              paddedTextSmall(getReferenceNumber(orders, orders[i]),
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(
                  Global.getPayTittle(
                      payToCustomerOrShopValue(orders, orders[i])),
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(
                  (orders[i].orderTypeId == 4)
                      ? Global.format(orders[i].priceIncludeTax ?? 0)
                      : "",
                  style: TextStyle(fontSize: 8),
                  align: TextAlign.right),
              paddedTextSmall(
                  (orders[i].orderTypeId == 44)
                      ? '(${Global.format(orders[i].priceIncludeTax ?? 0)})'
                      : "",
                  style: TextStyle(fontSize: 8, color: null),
                  align: TextAlign.right),
              paddedTextSmall(
                  payToCustomerOrShopValue(orders, orders[i]) > 0
                      ? Global.format(
                          payToCustomerOrShopValue(orders, orders[i]))
                      : '(${Global.format(-payToCustomerOrShopValue(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: payToCustomerOrShopValue(orders, orders[i]) > 0
                          ? null
                          : null),
                  align: TextAlign.right),
              paddedTextSmall(
                  getDiscountAddValueForPair(orders, orders[i]) == 0
                      ? ""
                      : "(${Global.format(getDiscountAddValueForPair(orders, orders[i]).abs())})",
                  style: TextStyle(
                      fontSize: 8,
                      color: getDiscountAddValueForPair(orders, orders[i]) < 0
                          ? null
                          : null),
                  align: TextAlign.right),
              paddedTextSmall(
                  getCashPayment(orders, orders[i]) == 0
                      ? ""
                      : orders[i].orderTypeId == 4
                          ? Global.format(getCashPayment(orders, orders[i]))
                          : '(${Global.format(getCashPayment(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].orderTypeId == 4
                          ? null
                          : null),
                  align: TextAlign.right),
              paddedTextSmall(
                  getTransferPayment(orders, orders[i]) == 0
                      ? ""
                      : orders[i].orderTypeId == 4
                          ? Global.format(getTransferPayment(orders, orders[i]))
                          : '(${Global.format(getTransferPayment(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].orderTypeId == 4
                          ? null
                          : null),
                  align: TextAlign.right),
              paddedTextSmall(
                  getCreditPayment(orders, orders[i]) == 0
                      ? ""
                      : orders[i].orderTypeId == 4
                          ? Global.format(getCreditPayment(orders, orders[i]))
                          : '(${Global.format(getCreditPayment(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].orderTypeId == 4
                          ? null
                          : null),
                  align: TextAlign.right),
              paddedTextSmall(
                  getOtherPayment(orders, orders[i]) == 0
                      ? ""
                      : orders[i].orderTypeId == 4
                          ? Global.format(getOtherPayment(orders, orders[i]))
                          : '(${Global.format(getOtherPayment(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: orders[i].orderTypeId == 4
                          ? null
                          : null),
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
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)),
              paddedTextSmall(Global.format4(getWeightTotalSN(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(Global.format4(getWeightTotalBU(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  priceIncludeTaxTotalMovement(orders) > 0
                      ? Global.format(priceIncludeTaxTotalMovement(orders))
                      : '(${Global.format(-priceIncludeTaxTotalMovement(orders))})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall(Global.format(priceIncludeTaxTotalBU(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  '(${Global.format(priceIncludeTaxTotalSN(orders))})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  payToCustomerOrShopValueTotalAlternative(orders) == 0
                      ? ""
                      : payToCustomerOrShopValueTotalAlternative(orders) > 0
                          ? '${Global.format(payToCustomerOrShopValueTotalAlternative(orders))}'
                          : '(${payToCustomerOrShopValueTotalAlternative(orders)})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  discountTotal(orders) == 0
                      ? ""
                      : discountTotal(orders) > 0
                          ? Global.format(discountTotal(orders))
                          : '(${Global.format(-discountTotal(orders))})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
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
                      color: PdfColors.black),
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
                      color: PdfColors.black),
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
                      color: PdfColors.black),
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
                      color: PdfColors.black),
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
      if (order.orderTypeId == 4) {
        return order.cashPayment ?? 0;
      } else {
        // Get the sell order's payment
        var sellOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 4,
          orElse: () => order
        );
        return sellOrder.cashPayment ?? 0;
      }
    } else {
      // Net is negative, show buy order's cash payment
      if (order.orderTypeId == 44) {
        return order.cashPayment ?? 0;
      } else {
        // Get the buy order's payment
        var buyOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 44,
          orElse: () => order
        );
        return buyOrder.cashPayment ?? 0;
      }
    }
  }

  // Not paired - use original logic
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 4) {
      return order.cashPayment ?? 0;
    }
    return 0;
  } else {
    if (order.orderTypeId == 44) {
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
        if (o.orderTypeId == 4) {
          sellTotal += o.priceIncludeTax ?? 0;
          sellCash += o.cashPayment ?? 0;
        } else if (o.orderTypeId == 44) {
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
      if (order.orderTypeId == 4) {
        total += order.cashPayment ?? 0;
      } else if (order.orderTypeId == 44) {
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
      if (order.orderTypeId == 4) {
        return (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
      } else {
        // Get the sell order's payment
        var sellOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 4,
          orElse: () => order
        );
        return (sellOrder.transferPayment ?? 0) + (sellOrder.depositPayment ?? 0);
      }
    } else {
      // Net is negative, show buy order's transfer payment
      if (order.orderTypeId == 44) {
        return (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
      } else {
        // Get the buy order's payment
        var buyOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 44,
          orElse: () => order
        );
        return (buyOrder.transferPayment ?? 0) + (buyOrder.depositPayment ?? 0);
      }
    }
  }

  // Not paired - use original logic
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 4) {
      return (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
    }
    return 0;
  } else {
    if (order.orderTypeId == 44) {
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
        if (o.orderTypeId == 4) {
          sellTotal += o.priceIncludeTax ?? 0;
          sellTransfer += (o.transferPayment ?? 0) + (o.depositPayment ?? 0);
        } else if (o.orderTypeId == 44) {
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
      if (order.orderTypeId == 4) {
        total += (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
      } else if (order.orderTypeId == 44) {
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
      if (order.orderTypeId == 4) {
        return order.creditPayment ?? 0;
      } else {
        // Get the sell order's payment
        var sellOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 4,
          orElse: () => order
        );
        return sellOrder.creditPayment ?? 0;
      }
    } else {
      // Net is negative, show buy order's credit payment
      if (order.orderTypeId == 44) {
        return order.creditPayment ?? 0;
      } else {
        // Get the buy order's payment
        var buyOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 44,
          orElse: () => order
        );
        return buyOrder.creditPayment ?? 0;
      }
    }
  }

  // Not paired - use original logic
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 4) {
      return order.creditPayment ?? 0;
    }
    return 0;
  } else {
    if (order.orderTypeId == 44) {
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
        if (o.orderTypeId == 4) {
          sellTotal += o.priceIncludeTax ?? 0;
          sellCredit += o.creditPayment ?? 0;
        } else if (o.orderTypeId == 44) {
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
      if (order.orderTypeId == 4) {
        total += order.creditPayment ?? 0;
      } else if (order.orderTypeId == 44) {
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
      if (order.orderTypeId == 4) {
        return order.otherPayment ?? 0;
      } else {
        // Get the sell order's payment
        var sellOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 4,
          orElse: () => order
        );
        return sellOrder.otherPayment ?? 0;
      }
    } else {
      // Net is negative, show buy order's other payment
      if (order.orderTypeId == 44) {
        return order.otherPayment ?? 0;
      } else {
        // Get the buy order's payment
        var buyOrder = orders.firstWhere(
          (e) => e.pairId == order.pairId && e.orderTypeId == 44,
          orElse: () => order
        );
        return buyOrder.otherPayment ?? 0;
      }
    }
  }

  // Not paired - use original logic
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 4) {
      return order.otherPayment ?? 0;
    }
    return 0;
  } else {
    if (order.orderTypeId == 44) {
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
        if (o.orderTypeId == 4) {
          sellTotal += o.priceIncludeTax ?? 0;
          sellOther += o.otherPayment ?? 0;
        } else if (o.orderTypeId == 44) {
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
      if (order.orderTypeId == 4) {
        total += order.otherPayment ?? 0;
      } else if (order.orderTypeId == 44) {
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
    for (int i = 0; i < orders0.length; i++) {
      for (int j = 0; j < orders0[i].details!.length; j++) {
        int type = orders0[i].orderTypeId!;
        double price = orders0[i].details![j].priceIncludeTax!;

        if (type == 2 || type == 44) {
          buy += -price;
        }
        if (type == 1 || type == 4) {
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

        if (type == 2 || type == 44) {
          buy += -price;
        }
        if (type == 1 || type == 4) {
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
