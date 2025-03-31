import 'dart:typed_data';

import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/classes/number_to_thai_words.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> makeRefillBill(Invoice invoice) async {
  // motivePrint(invoice.order?.toJson());
  // motivePrint(NumberToThaiWords.convertDouble(474445.99));
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
    headerRefill(invoice.order, 'ใบรับทอง (Goods Receive Note)'),
  );
  widgets.add(
    docNo(invoice.order),
  );
  widgets.add(
    Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: buyerSellerInfoRefill(invoice.customer, invoice.order),
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
                      '${Global.format(invoice.items[i].priceExcludeTax ?? 0)}',
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
                    border: Border(right: BorderSide()),
                  ),
                  child: paddedText('รวมน้ำหนักทอง', align: TextAlign.right),
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
      height: 70,
      decoration: const BoxDecoration(
        border: Border(
            left: BorderSide(), bottom: BorderSide(), right: BorderSide()),
      ),
      child: Row(children: [
        Expanded(
          flex: 7,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide()),
            ),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'หมายเหตุ :',
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 5,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide()),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 0.0, right: 4.0),
                              child: Text(
                                'ราคาสินค้ารวมค่ากำเหน็จและอื่นๆ ก่อนภาษีมูลค่าเพิ่ม :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                          )),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '       บันทึกเข้าระบบ ${Global.formatDateNT(invoice.order.createdDate.toString())}',
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide()),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 0.0, right: 4.0),
                              child: Text(
                                'หัก ราคารับซื้อทองประจำวัน ',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                          )),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '',
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 5,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide()),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 0.0, right: 4.0),
                              child: Text(
                                'ผลต่าง ฐานภาษี :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                          )),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '',
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 5,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide()),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 0.0, right: 4.0),
                              child: Text(
                                'ภาษีมูลค่าเพิ่ม 7% :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                          )),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            ' - ${NumberToThaiWords.convertDouble(invoice.order.priceIncludeTax ?? 0)} - ',
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide()),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 0.0, right: 4.0),
                              child: Text(
                                'จำนวนเงินสุทธิ :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                          )),
                    ]),


              ],
            ),
          ),
        ),
        Expanded(
            flex: 2,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
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
                            '${Global.format(invoice.order.priceExcludeTax ?? 0)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 9)),
                        Text(
                            '${Global.format(invoice.order.purchasePrice ?? 0)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 9)),
                        Text('${Global.format(invoice.order.priceDiff ?? 0)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 9,
                                color: (invoice.order.priceDiff ?? 0) < 0
                                    ? PdfColors.red
                                    : PdfColors.black)),
                        // Text(
                        //     '${Global.format((Global.getOrderTotal(invoice.order) - Global.getPapunTotal(invoice.order)) * 100 / 107)}',
                        //     textAlign: TextAlign.right,
                        //     style: const TextStyle(fontSize: 9)),
                        Text('${Global.format(invoice.order.taxAmount ?? 0)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 9)),
                        Text(
                            '${Global.format(invoice.order.priceIncludeTax ?? 0)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 9)),
                      ]),
                ),
              ),
            ])),
        // Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Expanded(
        //           flex: 3,
        //           child: Container(
        //             decoration: const BoxDecoration(
        //               border: Border(),
        //             ),
        //             child: Padding(
        //                 padding: const EdgeInsets.only(left: 8.0),
        //                 child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     mainAxisAlignment: MainAxisAlignment.start,
        //                     children: [
        //                       Text('หมายเหตุ :',
        //                           style: const TextStyle(fontSize: 9)),
        //                       Row(children: [
        //                         SizedBox(width: 20),
        //                         Text(
        //                             'บันทึกเข้าระบบ ${Global.formatDateNT(invoice.order.createdDate.toString())}',
        //                             style: const TextStyle(fontSize: 9)),
        //                       ]),
        //                       SizedBox(height: 10),
        //                       Text(
        //                           ' - ${NumberToThaiWords.convertDouble(invoice.order.priceIncludeTax ?? 0)} - ',
        //                           overflow: TextOverflow.visible,
        //                           style: const TextStyle(fontSize: 9)),
        //                     ])),
        //           )),
        //       Expanded(
        //           flex: 4,
        //           child: Container(
        //             decoration: const BoxDecoration(
        //               border: Border(right: BorderSide()),
        //             ),
        //             child: Padding(
        //               padding: const EdgeInsets.only(bottom: 0.0, right: 4.0),
        //               child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.end,
        //                   mainAxisAlignment: MainAxisAlignment.start,
        //                   children: [
        //                     Text(
        //                         'ราคาสินค้ารวมค่ากำเหน็จและอื่นๆ ก่อนภาษีมูลค่าเพิ่ม :',
        //                         textAlign: TextAlign.right,
        //                         style: const TextStyle(fontSize: 9)),
        //                     Text('หัก ราคารับซื้อทองประจำวัน :',
        //                         textAlign: TextAlign.right,
        //                         style: const TextStyle(fontSize: 9)),
        //                     Text('ผลต่าง ฐานภาษี :',
        //                         textAlign: TextAlign.right,
        //                         style: const TextStyle(fontSize: 9)),
        //                     // Text('ฐานภาษีมูลค่าเพิ่ม :',
        //                     //     textAlign: TextAlign.right,
        //                     //     style: const TextStyle(fontSize: 9)),
        //                     Text('ภาษีมูลค่าเพิ่ม 7% :',
        //                         textAlign: TextAlign.right,
        //                         style: const TextStyle(fontSize: 9)),
        //                     Text('จำนวนเงินสุทธิ :',
        //                         textAlign: TextAlign.right,
        //                         style: const TextStyle(fontSize: 9)),
        //                   ]),
        //             ),
        //           )),
        //       Expanded(
        //         flex: 2,
        //         child: Container(
        //           decoration: const BoxDecoration(
        //             border: Border(),
        //           ),
        //           child: Padding(
        //             padding: const EdgeInsets.only(
        //               right: 4.0,
        //               bottom: 0.0,
        //             ),
        //             child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.end,
        //                 children: [
        //                   Text(
        //                       '${Global.format(invoice.order.priceExcludeTax ?? 0)}',
        //                       textAlign: TextAlign.right,
        //                       style: const TextStyle(fontSize: 9)),
        //                   Text(
        //                       '${Global.format(invoice.order.purchasePrice ?? 0)}',
        //                       textAlign: TextAlign.right,
        //                       style: const TextStyle(fontSize: 9)),
        //                   Text('${Global.format(invoice.order.priceDiff ?? 0)}',
        //                       textAlign: TextAlign.right,
        //                       style: TextStyle(
        //                           fontSize: 9,
        //                           color: (invoice.order.priceDiff ?? 0) < 0
        //                               ? PdfColors.red
        //                               : PdfColors.black)),
        //                   // Text(
        //                   //     '${Global.format((Global.getOrderTotal(invoice.order) - Global.getPapunTotal(invoice.order)) * 100 / 107)}',
        //                   //     textAlign: TextAlign.right,
        //                   //     style: const TextStyle(fontSize: 9)),
        //                   Text('${Global.format(invoice.order.taxAmount ?? 0)}',
        //                       textAlign: TextAlign.right,
        //                       style: const TextStyle(fontSize: 9)),
        //                   Text(
        //                       '${Global.format(invoice.order.priceIncludeTax ?? 0)}',
        //                       textAlign: TextAlign.right,
        //                       style: const TextStyle(fontSize: 9)),
        //                 ]),
        //           ),
        //         ),
        //       ),
        //     ]),
      ]),
    ),
  );
  widgets.add(
    Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(children: [
          Expanded(
            flex: 8,
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
                            '${Global.getRefillPayTittle(Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0))} :  ',
                            style: const TextStyle(
                                fontSize: 9, color: PdfColors.blue700)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            '${Global.format(Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0) >= 0 ? Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0) : -Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0))}',
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
                        Expanded(flex: 3, child: Container())
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
                height: 55,
                child: Column(children: [
                  SizedBox(height: 5),
                  Text('ผู้รับทอง/ผู้บันทึกรายการ',
                      style: const TextStyle(fontSize: 9)),
                  Spacer(),
                  SizedBox(height: 5),
                ])),
          ),
        ])),
  );

  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(20),
      pageFormat: PdfPageFormat.a4,
      // orientation: PageOrientation.landscape,
      build: (context) => widgets,
    ),
  );
  return pdf.save();
}

Widget sn(List<OrderModel>? orders) {
  for (int i = 0; i < orders!.length; i++) {
    if (orders[i].orderTypeId == 5) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('ซื้อทองคำรูปพรรณ 96.5% : ',
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
    if (orders[i].orderTypeId == 6) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('ขายทองคำรูปพรรณเก่า 96.5% : ',
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
