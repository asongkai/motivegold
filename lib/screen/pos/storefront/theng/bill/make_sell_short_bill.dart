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
import 'package:flutter/material.dart' as mt;
import 'package:printing/printing.dart';

Future<Uint8List> makeSellThengShortBill(Invoice invoice, {int option = 1}) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
    icons: await PdfGoogleFonts.materialIcons(),
  );
  final pdf = Document(theme: myTheme);

  // Function to create bill content with version text
  Future<List<Widget>> createBillContent(String versionText) async {
    List<Widget> widgets = [];

    widgets.add(
      await header(invoice.order, 'ใบเสร็จรับเงิน / ใบกำกับภาษีอย่างย่อ',
          versionText: versionText, showPosId: true),
    );
    widgets.add(
      docNo(invoice.order),
    );
    widgets.add(
      Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.25),
        ),
        child: buyerSellerInfoBuySellTheng(invoice.customer, invoice.order),
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
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                      ),
                    ),
                    child:
                    paddedText('วันที่จองราคา', align: TextAlign.right),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                      ),
                    ),
                    child:
                    paddedText('น้ำหนัก (บาททอง)', align: TextAlign.right),
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
                  flex: 3,
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
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                        left: BorderSide(width: 0.25),
                        // bottom: BorderSide(),
                      ),
                    ),
                    child: paddedText(
                        invoice.items[i].bookDate != null ? Global.formatDateNT(invoice.items[i].bookDate.toString()) : "",
                        align: TextAlign.right),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                        left: BorderSide(width: 0.25),
                        // bottom: BorderSide(),
                      ),
                    ),
                    child: paddedText(
                        '${Global.format(invoice.items[i].weightBath ?? 0, option: true)}',
                        align: TextAlign.right),
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
                        '${Global.format4(invoice.items[i].weight ?? 0)}',
                        align: TextAlign.right),
                  )),
              Expanded(
                  flex: 3,
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
      height: 4,
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
                flex: 3,
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
            Expanded(
                flex: 3,
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
            Expanded(
                flex: 3,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                        bottom: BorderSide(width: 0.25),
                      ),
                    ),
                    child: paddedText('รวมน้ำหนักทองคำแท่ง/รวมราคาทองคำแท่ง',
                        align: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                        left: BorderSide(width: 0.25),
                        bottom: BorderSide(width: 0.25),
                      ),
                    ),
                    child: paddedText(
                        '${Global.format(Global.getOrderTotalWeightBaht(invoice.items), option: true)}',
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
                        '${Global.format4(Global.getOrderTotalWeight(invoice.items))}',
                        align: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
              Expanded(
                  flex: 3,
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
        height: 20,
        decoration: const BoxDecoration(
            border: Border()
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 0.0, top: 4.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('หมายเหตุ : สินค้าทองคำแท่ง บริษัทฯได้รับการยกเว้นภาษีมูลค่าเพิ่ม ${invoice.order.remark ?? ''}',
                                  style: const TextStyle(fontSize: 12)),
                            ])),
                  )),
            ]),
      ),
    );

    widgets.add(Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
                border: Border.all(width: 0.25),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left section - "อื่นๆ" with checkboxes
                Expanded(
                  flex: 3,
                  child: Column(children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 8,
                            child: Text('ค่าบริการ ค่าสินค้าที่มีภาษีมูลค่าเพิ่ม :',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal))),
                      ],
                    ),
                    SizedBox(height: 18),
                    Text(
                        '(${NumberToThaiWords.convertDouble(invoice.order.priceIncludeTax ?? 0)})',
                        style: TextStyle(fontSize: 12))
                  ]),
                ),

                // Empty middle section for spacing
                Container(width: 20),

                // Right section - Financial details
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Row 1: ค่าบล็อกทองไม่รวมภาษีมูลค่าเพิ่ม
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text('รวมค่าบริการ/ค่าสินค้าก่อนภาษีมูลค่าเพิ่ม :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12)),
                          ),
                          SizedBox(width: 30),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${Global.format(getCommissionNoVat(invoice.order) + getPackageNoVat(invoice.order))}',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 2),

                      // Row 3: ภาษีมูลค่าเพิ่ม 7%
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text('ภาษีมูลค่าเพิ่ม 7% :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12)),
                          ),
                          SizedBox(width: 30),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${Global.format(getVat(invoice.order))}',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 2),

                      // Row 5: ชำระเงินสุทธิ (highlighted)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text('รวมสุทธิทองคำแท่ง และค่าบริการ/ค่าสินค้า (รวมภาษีมูลค่าเพิ่ม) :',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(width: 30),
                          Expanded(
                              flex: 3,
                              child: Text(
                                '${Global.format(getTotalPayment(invoice.order))}',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    ));

    // widgets.add(
    //   Padding(
    //       padding: const EdgeInsets.only(top: 0.0),
    //       child: Row(children: [
    //         Expanded(
    //           flex: 8,
    //           child: Container(),
    //         ),
    //         SizedBox(width: 5),
    //         Expanded(
    //           flex: 3,
    //           child: Container(
    //             height: 65,
    //             child: Column(
    //               children: [
    //                 SizedBox(height: 15),
    //                 Text('                                ',
    //                     style: const TextStyle(fontSize: 12)),
    //                 Text('ผู้ซื้อ / ผู้จ่ายเงิน / ผู้รับทอง',
    //                     style: TextStyle(
    //                         fontSize: 12, fontWeight: FontWeight.bold)),
    //                 Spacer(),
    //                 Text('${Global.company?.name} (${Global.branch?.name})',
    //                     style: const TextStyle(fontSize: 12)),
    //                 Text('ผู้ขาย / ผู้รับเงิน / ผู้ส่งมอบทอง',
    //                     style: TextStyle(
    //                         fontSize: 12, fontWeight: FontWeight.bold)),
    //                 SizedBox(height: 5),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ])),
    // );

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
  combinedWidgets.add(SizedBox(height: 40));
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
  combinedWidgets.add(SizedBox(height: 40));

  // Add copy version
  combinedWidgets.addAll(copyWidgets);

  // Create single page with both versions
  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.only(left: 50, top: 20, bottom: 20, right: 20),
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

getCommission(OrderModel order) {
  double com = 0;
  for (int i = 0; i < order.details!.length; i++) {
    com += order.details![i].commission ?? 0;
  }
  return com;
}

getVat(OrderModel order) {
  double vat = 0;
  for (int i = 0; i < order.details!.length; i++) {
    if (order.details![i].vatOption == 'Include') {
      vat += (order.details![i].commission! + order.details![i].packagePrice!) *
          7 /
          107;
    }

    if (order.details![i].vatOption == 'Exclude') {
      vat += order.details![i].taxAmount!;
    }
  }
  return vat;
}

getPackageNoVat(OrderModel order) {
  double vat = 0;
  for (int i = 0; i < order.details!.length; i++) {
    if (order.details![i].vatOption == 'Include') {
      vat += order.details![i].packagePrice! * 100 / 107;
    }

    if (order.details![i].vatOption == 'Exclude') {
      vat += order.details![i].packagePrice!;
    }
  }
  return vat;
}

getCommissionNoVat(OrderModel order) {
  double vat = 0;
  for (int i = 0; i < order.details!.length; i++) {
    if (order.details![i].vatOption == 'Include') {
      vat += order.details![i].commission! * 100 / 107;
    }

    if (order.details![i].vatOption == 'Exclude') {
      vat += order.details![i].commission!;
    }
  }
  return vat;
}

getTotalPackageQty(OrderModel order) {
  double total = 0;
  for (int i = 0; i < order.details!.length; i++) {
    total += order.details![i].packageQty ?? 0;
  }
  return total;
}

getTotalAmount(OrderModel order) {
  return getCommissionNoVat(order) + getPackageNoVat(order) + getVat(order);
}

getTotalPayment(OrderModel order) {
  return getTotalAmount(order) + getLineTotal(order);
}

getLineTotal(OrderModel order) {
  double total = 0;
  for (int i = 0; i < order.details!.length; i++) {
    total += order.details![i].priceExcludeTax ?? 0;
  }
  return total;
}

Widget sn(List<OrderModel>? orders) {
  for (int i = 0; i < orders!.length; i++) {
    if (orders[i].orderTypeId == 4) {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: Text('ขายทองคำแท่ง : ${orders[i].orderId}',
                style: const TextStyle(fontSize: 12)),
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
    if (orders[i].orderTypeId == 44) {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: Text('รับซื้อทองแท่ง : ${orders[i].orderId}',
                style: const TextStyle(fontSize: 12)),
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
