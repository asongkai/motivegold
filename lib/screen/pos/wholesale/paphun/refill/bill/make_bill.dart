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

Future<Uint8List> makeRefillBill(Invoice invoice, {int option = 1}) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  // Function to create bill content with version text
  Future<List<Widget>> createBillContent(String versionText) async {
    List<Widget> widgets = [];

    widgets.add(
      await header(invoice.order, 'ใบรับทอง (Goods Receive Note)',
          versionText: versionText),
    );
    widgets.add(
      docNoRefill(invoice.order),
    );
    widgets.add(
      Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.25),
        ),
        child: buyerSellerInfoRefill(
            invoice.customer, invoice.order, invoice.items[0].productId!),
      ),
    );
    widgets.add(
      Container(
        height: 20,
        decoration: BoxDecoration(
          border: Border.all(width: 0.25),
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
                        right: BorderSide(width: 0.25),
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
                        right: BorderSide(width: 0.25),
                      ),
                    ),
                    child: paddedText('รายการสินค้า', align: TextAlign.center),
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                      ),
                    ),
                    child: paddedText('น้ำหนัก (กรัม)', align: TextAlign.right),
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                      ),
                    ),
                    child:
                        paddedText('จํานวนเงิน (บาท)', align: TextAlign.right),
                  )),
            ]),
      ),
    );
    for (int i = 0; i < invoice.items.length; i++) {
      widgets.add(Container(
        height: 25,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                        left: BorderSide(width: 0.25),
                      ),
                    ),
                    child: paddedText('${i + 1}', align: TextAlign.center),
                  )),
              Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                        left: BorderSide(width: 0.25),
                      ),
                    ),
                    child: paddedText(invoice.items[i].productName),
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                        left: BorderSide(width: 0.25),
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
                        right: BorderSide(width: 0.25),
                      ),
                    ),
                    child: paddedText(
                        '${Global.format(invoice.items[i].priceExcludeTax ?? 0)}',
                        align: TextAlign.right),
                  )),
            ]),
      ));
    }

    widgets.add(Container(
      height: 2,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(width: 0.25),
                      left: BorderSide(width: 0.25),
                      bottom: BorderSide(width: 0.25),
                    ),
                  ),
                  child: paddedText('', align: TextAlign.center),
                )),
            Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(width: 0.25),
                      left: BorderSide(width: 0.25),
                      bottom: BorderSide(width: 0.25),
                    ),
                  ),
                  child: paddedText(''),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 0.25),
                      bottom: BorderSide(width: 0.25),
                    ),
                  ),
                  child: paddedText('', align: TextAlign.right),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(width: 0.25),
                      left: BorderSide(width: 0.25),
                      bottom: BorderSide(width: 0.25),
                    ),
                  ),
                  child: paddedText('', align: TextAlign.right),
                )),
          ]),
    ));

    widgets.add(
      Container(
        height: 20,
        decoration: const BoxDecoration(
          border: Border(
              left: BorderSide(width: 0.25),
              bottom: BorderSide(width: 0.25),
              right: BorderSide(width: 0.25)),
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
                      border: Border(right: BorderSide(width: 0.25)),
                    ),
                    child: paddedText('รวม',
                        align: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                      ),
                    ),
                    child: paddedText(
                        '${Global.format(Global.getOrderTotalWeight(invoice.items))}',
                        align: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(),
                    ),
                    child: paddedText(
                        '${Global.format(Global.getOrderTotalAmountExclude(invoice.items))}',
                        align: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
            ]),
      ),
    );

    widgets.add(
      Container(
        height: 80,
        decoration: const BoxDecoration(
          border: Border(
              left: BorderSide(width: 0.25),
              bottom: BorderSide(width: 0.25),
              right: BorderSide(width: 0.25)),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 4.0, bottom: 4.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('หมายเหตุ : ${invoice.order.remark ?? ''}',
                                  style: const TextStyle(fontSize: 12)),
                              // Text(
                              //     'บันทึกเข้าระบบ ${Global.formatDateNT(invoice.order.createdDate.toString())}',
                              //     style: const TextStyle(fontSize: 12),
                              //     overflow: TextOverflow.span),
                              Spacer(),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        '(${NumberToThaiWords.convertDouble(invoice.order.priceIncludeTax ?? 0)})',
                                        overflow: TextOverflow.visible,
                                        style: const TextStyle(fontSize: 12)),
                                  ]),
                            ])),
                  )),
              Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 0.25)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 4.0, right: 4.0, top: 4.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('ราคาสินค้าไม่รวมภาษีมูลค่าเพิ่ม :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11)),
                            Text('หัก ราคารับซื้อทองประจำวัน :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11)),
                            Text('ส่วนต่าง (ฐานภาษีมูลค่าเพิ่ม) :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11)),
                            Text('ภาษีมูลค่าเพิ่ม 7% :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11)),
                            Text('จำนวนเงินรวมสุทธิ :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11)),
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
                        right: 4.0, bottom: 4.0, top: 4.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              '${Global.format(invoice.order.priceExcludeTax ?? 0)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11)),
                          Text(
                              '${Global.format(invoice.order.purchasePrice ?? 0)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11)),
                          Text('${Global.format((invoice.order.priceDiff ?? 0) * 100 / 107)}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: (invoice.order.priceDiff ?? 0) < 0
                                      ? PdfColors.red
                                      : PdfColors.black)),
                          Text('${Global.format(invoice.order.taxAmount ?? 0)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11)),
                          Text(
                              '${Global.format(invoice.order.priceIncludeTax ?? 0)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11)),
                        ]),
                  ),
                ),
              ),
            ]),
      ),
    );
    widgets.add(
      Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(children: [
            Expanded(
              flex: 9,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                    border: Border.all(width: 0.25),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    sn(invoice.orders),
                    bu(invoice.orders),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Text('ส่วนลด :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12, color: PdfColors.blue700)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(invoice.order.discount ?? 0)} บาท',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12, color: PdfColors.blue700)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Text(
                            '${Global.getRefillPayTittle(Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} :',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 12, color: PdfColors.blue700),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) >= 0 ? Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) : -Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} บาท',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12, color: PdfColors.blue700)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        for (int i = 0; i < invoice.payments!.length; i++)
                          Expanded(
                              child: Container(
                                  child: Row(children: [
                            Expanded(
                                flex: invoice.payments!.length > 1 ? 3 : 8,
                                child: Text(
                                    "${getPaymentType(invoice.payments![i].paymentMethod)} :",
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: PdfColors.blue700))),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    "${Global.format(invoice.payments![i].amount ?? 0)} บาท",
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: PdfColors.blue700)))
                          ])))
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 3,
              child: Container(
                  height: 55,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        SizedBox(height: 5),
                        Text('${Global.company?.name} (${Global.branch?.name})',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12)),
                        Text('ผู้ซื้อ / ผู้รับทอง / ผู้บันทึกรายการ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ])),
            ),
          ])),
    );

    return widgets;
  }

  // Create original and copy versions
  List<Widget> originalWidgets = await createBillContent('ต้นฉบับ');
  List<Widget> copyWidgets = await createBillContent('สำเนา');

  // Combine both versions on the same page
  List<Widget> combinedWidgets = [];

  // Add original version
  combinedWidgets.addAll(originalWidgets);

  // Add separator
  combinedWidgets.add(SizedBox(height: 5));
  combinedWidgets.add(
    Container(
      height: 1,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, style: BorderStyle.dashed),
        ),
      ),
    ),
  );
  combinedWidgets.add(SizedBox(height: 5));

  // Add copy version
  combinedWidgets.addAll(copyWidgets);

  // Create single page with both versions
  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.only(left: 50, top: 10, bottom: 10, right: 20),
      pageFormat: PdfPageFormat.a4,
      build: (context) => option == 1 ? combinedWidgets : originalWidgets,
    ),
  );

  if (option == 2) {
    pdf.addPage(
      MultiPage(
        margin: const EdgeInsets.only(left: 50, top: 20, bottom: 20, right: 20),
        pageFormat: PdfPageFormat.a4,
        build: (context) => copyWidgets,
      ),
    );
  }

  return pdf.save();
}

Widget sn(List<OrderModel>? orders) {
  for (int i = 0; i < orders!.length; i++) {
    if (orders[i].orderTypeId == 5) {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: Text('ซื้อทองคำรูปพรรณ 96.5% : ${orders[i].orderId}',
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
              flex: 3,
              child: Text(
                  'วันที่ :     ${Global.formatDateNT(orders[i].orderDate.toString())}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12))),
          Expanded(
              flex: 3,
              child: Text(
                  "มูลค่า :     ${Global.format(orders[i].priceIncludeTax ?? 0)} บาท",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12))),
        ],
      );
    }
  }
  return Container();
}

Widget bu(List<OrderModel>? orders) {
  for (int i = 0; i < orders!.length; i++) {
    if (orders[i].orderTypeId == 6) {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: Text('ขายทองคำรูปพรรณเก่า 96.5% : ${orders[i].orderId}',
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
              flex: 3,
              child: Text(
                  'วันที่ :     ${Global.formatDateNT(orders[i].orderDate.toString())}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12))),
          Expanded(
              flex: 3,
              child: Text(
                  "มูลค่า :     ${Global.format(orders[i].priceIncludeTax ?? 0)} บาท",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12))),
        ],
      );
    }
  }
  return Container();
}

Widget paddedText(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 12)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
