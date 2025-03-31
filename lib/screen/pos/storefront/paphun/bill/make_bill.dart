import 'dart:typed_data';

import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/classes/number_to_thai_words.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> makeBill(Invoice invoice) async {
  // motivePrint(invoice.payments?.length);
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);
  // final imageLogo = MemoryImage(
  //     (await rootBundle.load('assets/images/app_icon2.png'))
  //         .buffer
  //         .asUint8List());
  // var data =
  //     await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf");
  // var font = Font.ttf(data);

  List<Widget> widgets = [];
  widgets.add(
    await header(invoice.order, 'ใบส่งของ / ใบเสร็จรับเงิน / ใบกํากับภาษี'),
  );
  widgets.add(
    docNo(invoice.order),
  );
  widgets.add(
    Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: buyerSellerInfo(invoice.customer, invoice.order),
    ),
  );
  widgets.add(
    Container(
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                    ),
                  ),
                  child: paddedText(
                    'ลําดับ',
                    align: TextAlign.center,
                  ),
                )),
            Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                    ),
                  ),
                  child: paddedText('รายการสินค้า', align: TextAlign.center),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                    ),
                  ),
                  child: paddedText('น้ำหนัก (บาททอง)', align: TextAlign.right),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                    ),
                  ),
                  child: paddedText('น้ำหนัก (กรัม)', align: TextAlign.right),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                    ),
                  ),
                  child: paddedText('จํานวนเงิน (บาท)', align: TextAlign.right),
                )),
          ]),
    ),
  );
  for (int i = 0; i < invoice.items.length; i++) {
    widgets.add(Container(
      height: 20,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                      left: BorderSide(),
                      bottom: BorderSide(),
                    ),
                  ),
                  child: paddedText('${i + 1}', align: TextAlign.center),
                )),
            Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                      left: BorderSide(),
                      bottom: BorderSide(),
                    ),
                  ),
                  child: paddedText(invoice.items[i].productName),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                      left: BorderSide(),
                      bottom: BorderSide(),
                    ),
                  ),
                  child: paddedText(
                      '${Global.format(invoice.items[i].weightBath ?? 0)}',
                      align: TextAlign.right),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                      left: BorderSide(),
                      bottom: BorderSide(),
                    ),
                  ),
                  child: paddedText(
                      '${Global.format(invoice.items[i].weight ?? 0)}',
                      align: TextAlign.right),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                    ),
                  ),
                  child: paddedText(
                      '${Global.format(invoice.items[i].priceIncludeTax ?? 0)}',
                      align: TextAlign.right),
                )),
          ]),
    ));
  }

  widgets.add(
    Container(
      height: 20,
      decoration: const BoxDecoration(
        border: Border(
            left: BorderSide(), bottom: BorderSide(), right: BorderSide()),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(),
                  ),
                  child: paddedText(' ', align: TextAlign.center),
                )),
            Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(),
                  ),
                  child: paddedText('รวมน้ำหนักทอง', align: TextAlign.right),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(),
                  ),
                  child: paddedText(
                      '${Global.format(Global.getOrderTotalWeightBaht(invoice.items))}',
                      align: TextAlign.right),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(),
                    ),
                  ),
                  child: paddedText(
                      '${Global.format(Global.getOrderTotalWeight(invoice.items))}',
                      align: TextAlign.right),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(),
                  ),
                  child: paddedText(' ', align: TextAlign.right),
                )),
          ]),
    ),
  );
  widgets.add(
    Container(
      height: 90,
      decoration: const BoxDecoration(
        border: Border(
            left: BorderSide(), bottom: BorderSide(), right: BorderSide()),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 5,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('หมายเหตุ :',
                                style: const TextStyle(fontSize: 9)),
                            Row(children: [
                              // SizedBox(width: 20),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'ใบเสร็จรับเงินนี้จะสมบูรณ์่ต่อเมื่อ',
                                                style: const TextStyle(
                                                    fontSize: 9)),
                                            Text(
                                                'กิจการได้รับชำระค่าสินค้าครบถ้วนเรียบร้อย',
                                                style: const TextStyle(
                                                    fontSize: 9))
                                          ])),
                                ),
                              ),
                            ]),
                            Text(
                                '- ${NumberToThaiWords.convertDouble(Global.getOrderTotal(invoice.order))} -',
                                style: const TextStyle(fontSize: 9)),
                          ])),
                )),
            Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0.0, right: 4.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                              'ราคาสินค้ารวมค่ากําเหน็จและอื่นๆ (รวมภาษีมูลค่าเพิ่ม) :',
                              textAlign: TextAlign.right, overflow: TextOverflow.clip,
                              style: const TextStyle(fontSize: 9)),
                          Text('หัก ราคารับซื้อทองประจําวัน :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text('ผลต่าง (รวมภาษีมูลค่าเพิ่ม) :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text('ฐานภาษีมูลค่าเพิ่ม :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text('ภาษีมูลค่าเพิ่ม 7% :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text('ราคาสินค้าไม่รวมภาษีมูลค่าเพิ่ม :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ]),
                  ),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 4.0,
                      bottom: 0.0,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              '${Global.format(Global.getOrderTotal(invoice.order))}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text(
                              '${Global.format(Global.getPapunTotal(invoice.order))}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text(
                              '${Global.format(Global.getOrderTotal(invoice.order) - Global.getPapunTotal(invoice.order))}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text(
                              '${Global.format((Global.getOrderTotal(invoice.order) - Global.getPapunTotal(invoice.order)) * 100 / 107)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text(
                              '${Global.format(((Global.getOrderTotal(invoice.order) - Global.getPapunTotal(invoice.order)) * 100 / 107) * getVatValue())}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text(
                              '${Global.format(Global.getOrderTotal(invoice.order) - (((Global.getOrderTotal(invoice.order) - Global.getPapunTotal(invoice.order)) * 100 / 107) * getVatValue()))}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ]),
                  ),
                )),
          ]),
    ),
  );
  widgets.add(
    Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            sn(invoice.orders),
            bu(invoice.orders),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                      '${Global.getPayTittle(Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0))} :  ',
                      style: const TextStyle(
                          fontSize: 9, color: PdfColors.blue700)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                      '${Global.format(Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0) >= 0 ? Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0) : -Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0))}',
                      style: const TextStyle(
                          fontSize: 9, color: PdfColors.blue700)),
                ),
                for (int i = 0; i < invoice.payments!.length; i++)
                  Expanded(
                      flex: 3,
                      child: Text(
                          "${getPaymentType(invoice.payments![i].paymentMethod)} :   ${Global.format(invoice.payments![i].amount ?? 0)}",
                          style: const TextStyle(
                              fontSize: 9, color: PdfColors.blue700))),
                if (invoice.payments!.length <= 1)
                  Expanded(flex: 3, child: Container()),
                if (invoice.payments!.isEmpty)
                  Expanded(flex: 3, child: Container()),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(20),
      pageFormat: PdfPageFormat.a4,
      build: (context) => widgets,
    ),
  );
  return pdf.save();
}

Widget sn(List<OrderModel>? orders) {
  for (int i = 0; i < orders!.length; i++) {
    if (orders[i].orderTypeId == 1) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('ขายทองคํารูปพรรณใหม่ : ',
                style: const TextStyle(fontSize: 9)),
          ),
          Expanded(
              flex: 2,
              child:
                  Text(orders[i].orderId, style: const TextStyle(fontSize: 9))),
          Expanded(
              flex: 3,
              child: Text(
                  'วันที่ :     ${Global.formatDateNT(orders[i].orderDate.toString())}',
                  style: const TextStyle(fontSize: 9))),
          Expanded(
              flex: 3,
              child: Text(
                  "มูลค่า :     ${Global.format(orders[i].priceIncludeTax ?? 0)} บาท",
                  style: const TextStyle(fontSize: 9))),
        ],
      );
    }
  }
  return Container();
}

Widget bu(List<OrderModel>? orders) {
  for (int i = 0; i < orders!.length; i++) {
    if (orders[i].orderTypeId == 2) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('รับซื้อทองคํารูปพรรณเก่า : ',
                style: const TextStyle(fontSize: 9)),
          ),
          Expanded(
              flex: 2,
              child:
                  Text(orders[i].orderId, style: const TextStyle(fontSize: 9))),
          Expanded(
              flex: 3,
              child: Text(
                  'วันที่ :     ${Global.formatDateNT(orders[i].orderDate.toString())}',
                  style: const TextStyle(fontSize: 9))),
          Expanded(
              flex: 3,
              child: Text(
                  "มูลค่า :     ${Global.format(orders[i].priceIncludeTax ?? 0)} บาท",
                  style: const TextStyle(fontSize: 9))),
        ],
      );
    }
  }
  return Container();
}

Widget paddedText(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 9)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
