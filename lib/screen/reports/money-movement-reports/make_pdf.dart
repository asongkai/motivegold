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

  if (orderTypeId == 1) {
    return PdfColors.green600; // Sale (selling to customer)
  } else if (orderTypeId == 2) {
    return PdfColors.red600;   // Buy (buying from customer)
  } else {
    return PdfColors.grey600;
  }
}

Future<Uint8List> makeMoneyMovementReportPdf(List<OrderModel>? orders, int type,
    String date) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  List<Widget> widgets = [];

  widgets.add(Center(
    child: Text(
      'รายงานเส้นทางการเงินซื้อ-ขายทองรูปพรรณใหม่ 96.5%',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
    ),
  ));
  widgets.add(Center(
    child: Text("ระหว่างวันที่: $date"),
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("ชื่อผู้ประกอบการ: ${Global.branch?.name}"),
      Text('วันที่พิมพ์: ${Global.formatDate(DateTime.now().toString())}'),
    ],
  ));

  widgets.add(height());

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
        verticalInside: BorderSide.none,
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
            children: [
              paddedTextSmall('ลำดับ',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('เลขที่ใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('ชื่อผู้ซื้อ',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('วันที่',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('เวลา',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('นน.\nทองรูปพรรณใหม่ 96.5%\nขายออก (กรัม)',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('นน.\nทองรูปพรรณเก่า 96.5%\nรับซื้อ (กรัม)',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('จำนวนเงิน',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('เลขที่อ้างอิง',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('เส้นทางการเงิน',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('ผลต่าง',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ยอดรับเงิน',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ยอดจ่ายเงิน',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ส่วนลด',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('จ่ายเงินสด',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('จ่ายเงินโอน',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('บัตรเครดิต',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
            ]
        ),
        // Data rows with color coding
        for (int i = 0; i < orders!.length; i++)
          TableRow(
            decoration: const BoxDecoration(),
            children: [
              paddedTextSmall('${i + 1}', style: TextStyle(fontSize: 8)),
              paddedTextSmall(orders[i].orderId, style: TextStyle(fontSize: 8)),
              paddedTextSmall('${getCustomerName(orders[i].customer!)}',
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(Global.dateOnly(orders[i].createdDate.toString()),
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(Global.timeOnly(orders[i].createdDate.toString()),
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(
                  (orders[i].orderTypeId == 1)
                      ? Global.format(getWeight(orders[i]))
                      : "",
                  style: TextStyle(fontSize: 8, color: PdfColors.green600),
                  align: TextAlign.right),
              paddedTextSmall(
                  (orders[i].orderTypeId == 2)
                      ? Global.format(getWeight(orders[i]))
                      : "",
                  style: TextStyle(fontSize: 8, color: PdfColors.red600),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i].priceIncludeTax ?? 0),
                  style: TextStyle(fontSize: 8, color: getOrderTypeColor(orders[i].orderTypeId)),
                  align: TextAlign.right),
              paddedTextSmall(getReferenceNumber(orders, orders[i]),
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(Global.getPayTittle(
                  payToCustomerOrShopValue(orders, orders[i])),
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(
                  Global.format(payToCustomerOrShopValue(orders, orders[i])),
                  style: TextStyle(fontSize: 8, color: PdfColors.orange600),
                  align: TextAlign.right),
              paddedTextSmall(
                  (orders[i].orderTypeId == 1)
                      ? Global.format(orders[i].priceIncludeTax ?? 0)
                      : "",
                  style: TextStyle(fontSize: 8, color: PdfColors.green600),
                  align: TextAlign.right),
              paddedTextSmall(
                  (orders[i].orderTypeId == 2)
                      ? Global.format(orders[i].priceIncludeTax ?? 0)
                      : "",
                  style: TextStyle(fontSize: 8, color: PdfColors.red600),
                  align: TextAlign.right),
              paddedTextSmall(
                  (orders[i].orderTypeId == 1)
                      ? Global.format(orders[i].discount ?? 0)
                      : "",
                  style: TextStyle(fontSize: 8, color: PdfColors.orange700),
                  align: TextAlign.right),
              paddedTextSmall(getCashPayment(orders, orders[i]),
                  style: TextStyle(fontSize: 8, color: PdfColors.blue600),
                  align: TextAlign.right),
              paddedTextSmall(getTransferPayment(orders, orders[i]),
                  style: TextStyle(fontSize: 8, color: PdfColors.purple600),
                  align: TextAlign.right),
              paddedTextSmall(getCreditPayment(orders, orders[i]),
                  style: TextStyle(fontSize: 8, color: PdfColors.teal600),
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
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800
                  )),
              paddedTextSmall(Global.format(getWeightTotalSN(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(getWeightTotalBU(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700
                  ),
                  align: TextAlign.right),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall(Global.format(priceIncludeTaxTotalSN(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceIncludeTaxTotalBU(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(discountTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.orange700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(getCashPaymentTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(getTransferPaymentTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.purple700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(getCreditPaymentTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.teal700
                  ),
                  align: TextAlign.right),
            ]
        ),
      ],
    ),
  ));

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
        pageFormat: PdfPageFormat(
          PdfPageFormat.a4.height, // height becomes width
          PdfPageFormat.a4.width,  // width becomes height
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

String getCashPayment(List<OrderModel> orders, OrderModel order) {
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 1) {
      return Global.format(order.cashPayment ?? 0);
    }
    return "";
  } else {
    if (order.orderTypeId == 2) {
      return order.cashPayment != null
          ? "-${Global.format(order.cashPayment ?? 0)}"
          : "";
    }
    return "";
  }
}

double getCashPaymentTotal(List<OrderModel> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    if (payToCustomerOrShopValue(orders, orders[i]) > 0) {
      if (orders[i].orderTypeId == 1) {
        total += orders[i].cashPayment ?? 0;
      }
    } else {
      if (orders[i].orderTypeId == 2) {
        total -= orders[i].cashPayment ?? 0;
      }
    }
  }
  return total;
}

String getTransferPayment(List<OrderModel> orders, OrderModel order) {
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 1) {
      return Global.format(order.transferPayment ?? 0);
    }
    return "";
  } else {
    if (order.orderTypeId == 2) {
      return order.transferPayment != null
          ? "-${Global.format(order.transferPayment ?? 0)}"
          : "";
    }
    return "";
  }
}

double getTransferPaymentTotal(List<OrderModel> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    if (payToCustomerOrShopValue(orders, orders[i]) > 0) {
      if (orders[i].orderTypeId == 1) {
        total += orders[i].transferPayment ?? 0;
      }
    } else {
      if (orders[i].orderTypeId == 2) {
        total -= orders[i].transferPayment ?? 0;
      }
    }
  }
  return total;
}

String getCreditPayment(List<OrderModel> orders, OrderModel order) {
  if (payToCustomerOrShopValue(orders, order) > 0) {
    if (order.orderTypeId == 1) {
      return Global.format(order.creditPayment ?? 0);
    }
    return "";
  } else {
    if (order.orderTypeId == 2) {
      return order.creditPayment != null
          ? "-${Global.format(order.creditPayment ?? 0)}"
          : "";
    }
    return "";
  }
}

double getCreditPaymentTotal(List<OrderModel> orders) {
  double total = 0;
  for (int i = 0; i < orders.length; i++) {
    if (payToCustomerOrShopValue(orders, orders[i]) > 0) {
      if (orders[i].orderTypeId == 1) {
        total += orders[i].creditPayment ?? 0;
      }
    } else {
      if (orders[i].orderTypeId == 2) {
        total -= orders[i].creditPayment ?? 0;
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
      final TextStyle style = const TextStyle(fontSize: 9)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );