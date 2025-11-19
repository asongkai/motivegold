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
  if (orderTypeId == null) return PdfColors.grey600;

  if (orderTypeId == 4) {
    return PdfColors.green600; // Sale (selling to customer)
  } else if (orderTypeId == 44) {
    return PdfColors.red600; // Buy (buying from customer)
  } else {
    return PdfColors.grey600;
  }
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
        border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
        columnWidths: {
          0: const FixedColumnWidth(25),
          1: const FixedColumnWidth(60),
          2: const FixedColumnWidth(70),
          3: const FixedColumnWidth(45),
          4: const FixedColumnWidth(55),
          5: const FixedColumnWidth(55),
          6: const FixedColumnWidth(60),
          7: const FixedColumnWidth(65),
          8: const FixedColumnWidth(65),
          9: const FixedColumnWidth(50),
          10: const FixedColumnWidth(50),
          11: const FixedColumnWidth(60),
          12: const FixedColumnWidth(60),
          13: const FixedColumnWidth(50),
          14: const FixedColumnWidth(60),
          15: const FixedColumnWidth(50),
          16: const FixedColumnWidth(40),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: PdfColors.blue600),
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              paddedTextSmall('ลำดับ',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('เลขที่ใบกํากับภาษี',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('ชื่อลูกค้า',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('วันที่',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('นน.ทองคำแท่ง\nขายออก (กรัม)',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('นน.ทองคำแท่ง\nรับซื้อ (กรัม)',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('จำนวนเงินสุทธิ \n(บาท)',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall(
                  'เลขที่อ้างอิง\nใบส่งของ/ใบ\nเสร็จรับเงิน\nใบรับซื้อทองแท่ง',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('ร้านทองรับเงิน/\nร้านทองจ่ายเงิน',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('ยอดรับเงิน',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('ยอดจ่ายเงิน',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('ร้านทองรับ\n(จ่าย)เงินสุทธิ',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('ร้านทองเพิ่ม/\nลดให้',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('เงินสดรับ\n(จ่าย)',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('เงินโอน/\nฝากธนาคาร',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('บัตรเครดิต',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
              paddedTextSmall('อื่นๆ',
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white)),
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
      border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
      columnWidths: {
        0: const FixedColumnWidth(25),
        1: const FixedColumnWidth(60),
        2: const FixedColumnWidth(70),
        3: const FixedColumnWidth(45),
        4: const FixedColumnWidth(55),
        5: const FixedColumnWidth(55),
        6: const FixedColumnWidth(60),
        7: const FixedColumnWidth(65),
        8: const FixedColumnWidth(65),
        9: const FixedColumnWidth(50),
        10: const FixedColumnWidth(50),
        11: const FixedColumnWidth(60),
        12: const FixedColumnWidth(60),
        13: const FixedColumnWidth(50),
        14: const FixedColumnWidth(60),
        15: const FixedColumnWidth(50),
        16: const FixedColumnWidth(40),
      },
      children: [
        // Data rows with color coding
        for (int i = 0; i < orders!.length; i++)
          TableRow(
            decoration: const BoxDecoration(),
            children: [
              paddedTextSmall('${i + 1}',
                  style: TextStyle(fontSize: 8), align: TextAlign.center),
              paddedTextSmall(orders[i].orderId,
                  style: TextStyle(fontSize: 8), align: TextAlign.center),
              paddedTextSmall('${getCustomerName(orders[i].customer!)}',
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(Global.dateOnly(orders[i].createdDate.toString()),
                  style: TextStyle(fontSize: 8)),
              // paddedTextSmall(Global.timeOnly(orders[i].createdDate.toString()),
              //     style: TextStyle(fontSize: 8)),
              paddedTextSmall(
                  (orders[i].orderTypeId == 4)
                      ? Global.format4(getWeight(orders[i]))
                      : "",
                  style: TextStyle(fontSize: 8, color: PdfColors.black),
                  align: TextAlign.right),
              paddedTextSmall(
                  (orders[i].orderTypeId == 44)
                      ? Global.format4(getWeight(orders[i]))
                      : "",
                  style: TextStyle(fontSize: 8, color: PdfColors.black),
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
                  style: TextStyle(fontSize: 8, color: PdfColors.green600),
                  align: TextAlign.right),
              paddedTextSmall(
                  (orders[i].orderTypeId == 44)
                      ? '(${Global.format(orders[i].priceIncludeTax ?? 0)})'
                      : "",
                  style: TextStyle(fontSize: 8, color: PdfColors.red600),
                  align: TextAlign.right),
              paddedTextSmall(
                  payToCustomerOrShopValue(orders, orders[i]) > 0
                      ? Global.format(
                          payToCustomerOrShopValue(orders, orders[i]))
                      : '(${Global.format(-payToCustomerOrShopValue(orders, orders[i]))})',
                  style: TextStyle(
                      fontSize: 8,
                      color: payToCustomerOrShopValue(orders, orders[i]) > 0
                          ? PdfColors.green600
                          : PdfColors.red600),
                  align: TextAlign.right),
              paddedTextSmall(
                  addDisValue(orders[i].discount ?? 0,
                              orders[i].addPrice ?? 0) ==
                          0
                      ? ""
                      : (orders[i].orderTypeId == 4)
                          ? "${addDisValue(orders[i].discount ?? 0, orders[i].addPrice ?? 0) < 0 ? "(${-addDisValue(orders[i].discount ?? 0, orders[i].addPrice ?? 0)})" : addDisValue(orders[i].discount ?? 0, orders[i].addPrice ?? 0)}"
                          : "",
                  style: TextStyle(
                      fontSize: 8,
                      color: addDisValue(orders[i].discount ?? 0,
                                  orders[i].addPrice ?? 0) <
                              0
                          ? PdfColors.red600
                          : PdfColors.green600),
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
                          ? PdfColors.green600
                          : PdfColors.red600),
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
                          ? PdfColors.green600
                          : PdfColors.red600),
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
                          ? PdfColors.green600
                          : PdfColors.red600),
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
                          ? PdfColors.green600
                          : PdfColors.red600),
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
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800)),
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
                      color: priceIncludeTaxTotalMovement(orders) > 0
                          ? PdfColors.blue700
                          : PdfColors.red700),
                  align: TextAlign.right),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall(Global.format(priceIncludeTaxTotalBU(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700),
                  align: TextAlign.right),
              paddedTextSmall(
                  '(${Global.format(priceIncludeTaxTotalSN(orders))})',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700),
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
                      color:
                          payToCustomerOrShopValueTotalAlternative(orders) > 0
                              ? PdfColors.green700
                              : PdfColors.red700),
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
                      color: discountTotal(orders) > 0
                          ? PdfColors.green700
                          : PdfColors.red700),
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
                          ? PdfColors.green700
                          : PdfColors.red700),
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
                          ? PdfColors.green700
                          : PdfColors.red700),
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
                          ? PdfColors.green700
                          : PdfColors.red700),
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
                          ? PdfColors.green700
                          : PdfColors.red700),
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
  for (int i = 0; i < orders.length; i++) {
    if (payToCustomerOrShopValue(orders, orders[i]) > 0) {
      if (orders[i].orderTypeId == 4) {
        total += orders[i].cashPayment ?? 0;
      }
    } else {
      if (orders[i].orderTypeId == 44) {
        total -= orders[i].cashPayment ?? 0;
      }
    }
  }
  return total;
}

double getTransferPayment(List<OrderModel> orders, OrderModel order) {
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
  for (int i = 0; i < orders.length; i++) {
    if (payToCustomerOrShopValue(orders, orders[i]) > 0) {
      if (orders[i].orderTypeId == 4) {
        total += orders[i].transferPayment ?? 0;
      }
    } else {
      if (orders[i].orderTypeId == 44) {
        total -= orders[i].transferPayment ?? 0;
      }
    }
  }
  return total;
}

double getCreditPayment(List<OrderModel> orders, OrderModel order) {
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
  for (int i = 0; i < orders.length; i++) {
    if (payToCustomerOrShopValue(orders, orders[i]) > 0) {
      if (orders[i].orderTypeId == 4) {
        total += orders[i].creditPayment ?? 0;
      }
    } else {
      if (orders[i].orderTypeId == 44) {
        total -= orders[i].creditPayment ?? 0;
      }
    }
  }
  return total;
}

double getOtherPayment(List<OrderModel> orders, OrderModel order) {
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
  for (int i = 0; i < orders.length; i++) {
    if (payToCustomerOrShopValue(orders, orders[i]) > 0) {
      if (orders[i].orderTypeId == 4) {
        total += orders[i].otherPayment ?? 0;
      }
    } else {
      if (orders[i].orderTypeId == 44) {
        total -= orders[i].otherPayment ?? 0;
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
