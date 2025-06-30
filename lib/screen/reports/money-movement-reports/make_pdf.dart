import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeMoneyMovementReportPdf(List<OrderModel>? orders, int type,
    String date) async {
  // Global.printLongString(orders!.map((e) => e.toJson()).toString());
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
      child:
      Text("ระหว่างวันที่: $date"),
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
          "ชื่อผู้ประกอบการ: ${Global.branch?.name}"),
      Text('วันที่พิมพ์: ${Global.formatDate(DateTime.now().toString())}'),
    ],
  ));
  // widgets.add(Row(
  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //   children: [
  //     Text(
  //         "ที่อยู่: ${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}"),
  //   ],
  // ));

  widgets.add(height());
  widgets.add(Table(
    border: TableBorder.all(color: PdfColors.grey500),
    children: [
      TableRow(children: [
        paddedText('ลำดับ'),
        paddedText('เลขที่ใบกํากับภาษี'),
        paddedText('ชื่อผู้ซื้อ'),
        paddedText('วันที่'),
        paddedText('เวลา'),
        paddedText('นน.\nทองรูปพรรณใหม่ 96.5%\nขายออก (กรัม)'),
        paddedText('นน.\nทองรูปพรรณเก่า 96.5%\nรับซื้อ (กรัม)'),
        paddedText('จำนวนเงิน'),
        paddedText('เลขที่อ้างอิง'),
        paddedText('เส้นทางการเงิน'),
        paddedText('ผลต่าง'),
        paddedText('ยอดรับเงิน'),
        paddedText('ยอดจ่ายเงิน'),
        paddedText('ส่วนลด'),
        paddedText('จ่ายเงินสด'),
        paddedText('จ่ายเงินโอน'),
        paddedText('บัตรเครดิต'),
      ]),
      for (int i = 0; i < orders!.length; i++)
        TableRow(
          decoration: const BoxDecoration(),
          children: [
            paddedText('${i + 1}'),
            paddedText(orders[i].orderId),
            paddedText(
                '${orders[i].customer?.firstName} ${orders[i].customer
                    ?.lastName}'),
            paddedText(Global.dateOnly(orders[i].createdDate.toString())),
            paddedText(Global.timeOnly(orders[i].createdDate.toString())),
            paddedText(
                (orders[i].orderTypeId == 1)
                    ? Global.format(getWeight(orders[i]))
                    : "",
                align: TextAlign.right),
            paddedText(
                (orders[i].orderTypeId == 2)
                    ? Global.format(getWeight(orders[i]))
                    : "",
                align: TextAlign.right),
            paddedText(Global.format(orders[i].priceIncludeTax ?? 0),
                align: TextAlign.right),
            paddedText(getReferenceNumber(orders, orders[i]),
                align: TextAlign.right),
            paddedText(Global.getPayTittle(
                payToCustomerOrShopValue(orders, orders[i]))),
            paddedText(
                Global.format(payToCustomerOrShopValue(orders, orders[i])),
                align: TextAlign.right),
            paddedText(
                (orders[i].orderTypeId == 1)
                    ? Global.format(orders[i].priceIncludeTax ?? 0)
                    : "",
                align: TextAlign.right),
            paddedText(
                (orders[i].orderTypeId == 2)
                    ? Global.format(orders[i].priceIncludeTax ?? 0)
                    : "",
                align: TextAlign.right),
            paddedText(
                (orders[i].orderTypeId == 1)
                    ? Global.format(orders[i].discount ?? 0)
                    : "",
                align: TextAlign.right),
            paddedText(getCashPayment(orders, orders[i]),
                align: TextAlign.right),
            paddedText(getTransferPayment(orders, orders[i]),
                align: TextAlign.right),
            paddedText(getCreditPayment(orders, orders[i]),
                align: TextAlign.right),
          ],
        ),
      TableRow(children: [
        paddedText(''),
        paddedText(''),
        paddedText(''),
        paddedText(''),
        paddedText('รวมท้ังหมด'),
        paddedText(Global.format(getWeightTotalSN(orders)),
            align: TextAlign.right),
        paddedText(Global.format(getWeightTotalBU(orders)),
            align: TextAlign.right),
        paddedText(Global.format(priceIncludeTaxTotal(orders)),
            align: TextAlign.right),
        paddedText('', align: TextAlign.right),
        paddedText('', align: TextAlign.right),
        paddedText('', align: TextAlign.right),
        paddedText(Global.format(priceIncludeTaxTotalSN(orders)),
            align: TextAlign.right),
        paddedText(Global.format(priceIncludeTaxTotalBU(orders)),
            align: TextAlign.right),
        paddedText(Global.format(discountTotal(orders)),
            align: TextAlign.right),
        paddedText(Global.format(getCashPaymentTotal(orders)),
            align: TextAlign.right),
        paddedText(Global.format(getTransferPaymentTotal(orders)),
            align: TextAlign.right),
        paddedText(Global.format(getCreditPaymentTotal(orders)),
            align: TextAlign.right),
      ])
    ],
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
      // motivePrint(orders[i].cashPayment ?? 0);
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
      // motivePrint(orders[i].cashPayment ?? 0);
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
      // motivePrint(orders[i].cashPayment ?? 0);
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

Widget paddedText(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 10)}) =>
    Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );
