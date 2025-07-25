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

Future<Uint8List> makeSellThengBill(Invoice invoice) async {
  // Global.printLongString(invoice.order!.toJson().toString());
  // motivePrint(NumberToThaiWords.convertDouble(474445.99));
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
    icons: await PdfGoogleFonts.materialIcons(),
  );
  final pdf = Document(theme: myTheme);
  // final imageLogo = MemoryImage(
  //     (await rootBundle.load('assets/images/app_icon2.png'))
  //         .buffer
  //         .asUint8List());
  // var data =
  //     await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf");
  // var font = Font.ttf(data);

  List<Widget> originalWidgets = [];
  originalWidgets.add(
    await header(invoice.order, 'ใบส่งของ / ใบเสร็จรับเงิน / ใบกํากับภาษี',
        versionText: 'ต้นฉบับ'),
  );
  originalWidgets.add(
    docNo(invoice.order),
  );
  originalWidgets.add(
    Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: buyerSellerInfoBuySellTheng(invoice.customer, invoice.order),
    ),
  );
  originalWidgets.add(
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
                  child: paddedText('หลักประกัน', align: TextAlign.center),
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
    originalWidgets.add(Container(
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

  originalWidgets.add(
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
  originalWidgets.add(
    Container(
      height: 45,
      decoration: const BoxDecoration(
        border: Border(
            left: BorderSide(), bottom: BorderSide(), right: BorderSide()),
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
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('หมายเหตุ :',
                                style: const TextStyle(fontSize: 9)),
                            Text(
                                '${invoice.order.remark ?? ''}       บันทึกเข้าระบบ ${Global.formatDateNT(invoice.order.createdDate.toString())}',
                                style: const TextStyle(fontSize: 9),
                                overflow: TextOverflow.span),
                            Spacer(),
                            Row(children: [
                              Text(
                                  '- ${NumberToThaiWords.convertDouble(invoice.order.priceIncludeTax ?? 0)} -',
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(fontSize: 9)),
                            ]),
                            SizedBox(height: 3),
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
                          Text('ราคาทองคำแท่งรวม :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          // Text('ค่าบล็อกทอง/บรรจุภัณฑ์ รวมภาษีมูลค่าเพิ่ม :',
                          //     textAlign: TextAlign.right,
                          //     style: const TextStyle(fontSize: 9)),
                          // Text('ราคาสินค้ารวมภาษีมูลค่าเพิ่ม :',
                          //     textAlign: TextAlign.right,
                          //     style: const TextStyle(fontSize: 9)),
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
                            '${Global.format(getLineTotal(invoice.order))}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 9)),
                        // Text(
                        //     '${Global.format(commissionTotal(invoice.orders!))}',
                        //     textAlign: TextAlign.right,
                        //     style: const TextStyle(fontSize: 9)),
                        // Text(
                        //   '${Global.format(priceIncludeTaxTotal(invoice.orders!))}',
                        //   textAlign: TextAlign.right,
                        //   style: const TextStyle(
                        //     fontSize: 9,
                        //   ),
                        // ),
                      ]),
                ),
              ),
            ),
          ]),
    ),
  );
  originalWidgets.add(Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(width: 1.0),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left section - "อื่นๆ" with checkboxes
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('อื่นๆ :',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    // First checkbox row
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: (getCommission(invoice.order) > 0)
                              ? Icon(
                                  const IconData(0xe5ca), // checkmark
                                  color: PdfColors.black,
                                  size: 20,
                                )
                              : Container(),
                        ),
                        SizedBox(width: 5),
                        Text('ค่าบล็อกทอง',
                            style: const TextStyle(fontSize: 9)),
                      ],
                    ),
                    SizedBox(height: 4),
                    // Second checkbox row
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: (getPackageNoVat(invoice.order) > 0)
                              ? Icon(
                                  const IconData(0xe5ca), // checkmark
                                  color: PdfColors.black,
                                  size: 20,
                                )
                              : Container(),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                              'ค่าบรรจุภัณฑ์ จำนวน...${getTotalPackageQty(invoice.order) > 0 ? Global.format(getTotalPackageQty(invoice.order)) : ""}...ชิ้น',
                              style: const TextStyle(fontSize: 9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Empty middle section for spacing
              Expanded(
                flex: 1,
                child: Container(),
              ),

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
                          flex: 5,
                          child: Text('ค่าบล็อกทองไม่รวมภาษีมูลค่าเพิ่ม',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${Global.format(getCommissionNoVat(invoice.order))}',
                            style: const TextStyle(fontSize: 9),
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 2),

                    // Row 2: ค่าบรรจุภัณฑ์ไม่รวมภาษีมูลค่าเพิ่ม
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('ค่าบรรจุภัณฑ์ไม่รวมภาษีมูลค่าเพิ่ม',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${Global.format(getPackageNoVat(invoice.order))}',
                            style: const TextStyle(fontSize: 9),
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
                          flex: 5,
                          child: Text('ภาษีมูลค่าเพิ่ม 7%',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${Global.format(getVat(invoice.order))}',
                            style: const TextStyle(fontSize: 9),
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 2),

                    // Row 4: รวม/ค่าบรรจุภัณฑ์รวมภาษีมูลค่าเพิ่ม
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('รวม/ค่าบรรจุภัณฑ์รวมภาษีมูลค่าเพิ่ม',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                            flex: 3,
                            child: Text(
                              '${Global.format(getTotalAmount(invoice.order))}',
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.right,
                            )),
                      ],
                    ),
                    SizedBox(height: 2),

                    // Row 5: ชำระเงินสุทธิ (highlighted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('ชำระเงินสุทธิ',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                            flex: 3,
                            child: Text(
                              '${Global.format(getTotalPayment(invoice.order))}',
                              style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.bold),
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
  originalWidgets.add(
    Container(
      height: 50,
      padding: const EdgeInsets.all(4.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'ข้าพเจ้าขอรับรองว่า ข้าพเจ้าเป็นเจ้าของและมีกรรมสิทธิ์โดยชอบด้วยกฎหมายแต่เพียงผู้เดียวในทองคำที่นำมาขายให้กับบริษัทฯ โดยปราศจากภาระผูกพัน',
                style: const TextStyle(fontSize: 9)),
            Text(
                'และการลิดรอนสิทธิใดๆ ทั้งสิ้น ข้าพเจ้ามีความยินยอมให้ทางบริษัทฯ นำทองคำที่ส่งมอบข้างต้นไปดำเนินการตรวจสอบคุณภาพตามวิธีการของบริษัทฯ ',
                style: const TextStyle(fontSize: 9)),
            Text(
                'หากไม่ผ่านการตรวจสอบ ข้าพเจ้ายอมให้บริษัทฯ มีสิทธิปฏิเสธการรับทองคำและชดใช้ค่าเสียหายตามที่บริษัทฯ เรียกร้องโดยไม่มีข้อโต้แย้งในทุกกรณี',
                style: const TextStyle(fontSize: 9)),
          ]),
    ),
  );
  originalWidgets.add(
    Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(children: [
          Expanded(
            flex: 8,
            child: Container(
              // width: double.infinity,
              // height: 55,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text('ร้านทองเพิ่ม(ลด)ให้:',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, color: PdfColors.blue700)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            '${addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) < 0 ? "(${addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0)})" : addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0)} บาท',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 9,
                                color: addDisValue(invoice.order.discount ?? 0,
                                            invoice.order.addPrice ?? 0) <
                                        0
                                    ? PdfColors.red
                                    : PdfColors.blue700)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text(
                          '${Global.getRefillPayTittle(Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} :  ',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 9, color: PdfColors.blue700),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            '${Global.format(Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) >= 0 ? Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) : -Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} บาท',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, color: PdfColors.blue700)),
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
                                      fontSize: 9, color: PdfColors.blue700))),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  "${Global.format(invoice.payments![i].amount ?? 0)} บาท",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 9, color: PdfColors.blue700)))
                        ])))
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 85,
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Text('(                                )',
                      style: const TextStyle(fontSize: 9)),
                  SizedBox(height: 5),
                  Text('ผู้รับเงิน/ผู้ส่งมอบทอง',
                      style: const TextStyle(fontSize: 9)),
                  Spacer(),
                  Text('(                                )',
                      style: const TextStyle(fontSize: 9)),
                  SizedBox(height: 5),
                  Text('ผู้ซื้อ/ผู้รับมอบทอง',
                      style: const TextStyle(fontSize: 9)),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ])),
  );

  // Copy version

  List<Widget> copyWidgets = [];
  copyWidgets.add(
    await header(invoice.order, 'ใบส่งของ / ใบเสร็จรับเงิน / ใบกํากับภาษี',
        versionText: 'สำเนา'),
  );
  copyWidgets.add(
    docNo(invoice.order),
  );
  copyWidgets.add(
    Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: buyerSellerInfoBuySellTheng(invoice.customer, invoice.order),
    ),
  );
  copyWidgets.add(
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
    copyWidgets.add(Container(
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

  copyWidgets.add(
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
  copyWidgets.add(
    Container(
      height: 45,
      decoration: const BoxDecoration(
        border: Border(
            left: BorderSide(), bottom: BorderSide(), right: BorderSide()),
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
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('หมายเหตุ :',
                                style: const TextStyle(fontSize: 9)),
                            Text(
                                '${invoice.order.remark ?? ''}       บันทึกเข้าระบบ ${Global.formatDateNT(invoice.order.createdDate.toString())}',
                                style: const TextStyle(fontSize: 9),
                                overflow: TextOverflow.span),
                            Spacer(),
                            Row(children: [
                              Text(
                                  '- ${NumberToThaiWords.convertDouble(invoice.order.priceIncludeTax ?? 0)} -',
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(fontSize: 9)),
                            ]),
                            SizedBox(height: 3),
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
                          Text('ราคาทองคำแท่งรวม :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text('ค่าบล็อกทอง/บรรจุภัณฑ์ รวมภาษีมูลค่าเพิ่ม :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                          Text('ราคาสินค้ารวมภาษีมูลค่าเพิ่ม :',
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
                            '${Global.format(priceExcludeTaxTotal(invoice.orders!))}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 9)),
                        Text(
                            '${Global.format(commissionTotal(invoice.orders!))}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 9)),
                        Text(
                          '${Global.format(priceIncludeTaxTotal(invoice.orders!))}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 9,
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ]),
    ),
  );
  copyWidgets.add(Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(width: 1.0),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left section - "อื่นๆ" with checkboxes
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('อื่นๆ :',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    // First checkbox row
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: (getCommission(invoice.order) > 0)
                              ? Icon(
                            const IconData(0xe5ca), // checkmark
                            color: PdfColors.black,
                            size: 20,
                          )
                              : Container(),
                        ),
                        SizedBox(width: 5),
                        Text('ค่าบล็อกทอง',
                            style: const TextStyle(fontSize: 9)),
                      ],
                    ),
                    SizedBox(height: 4),
                    // Second checkbox row
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: (getPackageNoVat(invoice.order) > 0)
                              ? Icon(
                            const IconData(0xe5ca), // checkmark
                            color: PdfColors.black,
                            size: 20,
                          )
                              : Container(),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                              'ค่าบรรจุภัณฑ์ จำนวน...${getTotalPackageQty(invoice.order) > 0 ? Global.format(getTotalPackageQty(invoice.order)) : ""}...ชิ้น',
                              style: const TextStyle(fontSize: 9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Empty middle section for spacing
              Expanded(
                flex: 1,
                child: Container(),
              ),

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
                          flex: 5,
                          child: Text('ค่าบล็อกทองไม่รวมภาษีมูลค่าเพิ่ม',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${Global.format(getCommissionNoVat(invoice.order))}',
                            style: const TextStyle(fontSize: 9),
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 2),

                    // Row 2: ค่าบรรจุภัณฑ์ไม่รวมภาษีมูลค่าเพิ่ม
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('ค่าบรรจุภัณฑ์ไม่รวมภาษีมูลค่าเพิ่ม',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${Global.format(getPackageNoVat(invoice.order))}',
                            style: const TextStyle(fontSize: 9),
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
                          flex: 5,
                          child: Text('ภาษีมูลค่าเพิ่ม 7%',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${Global.format(getVat(invoice.order))}',
                            style: const TextStyle(fontSize: 9),
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 2),

                    // Row 4: รวม/ค่าบรรจุภัณฑ์รวมภาษีมูลค่าเพิ่ม
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('รวม/ค่าบรรจุภัณฑ์รวมภาษีมูลค่าเพิ่ม',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 9)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                            flex: 3,
                            child: Text(
                              '${Global.format(getTotalAmount(invoice.order))}',
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.right,
                            )),
                      ],
                    ),
                    SizedBox(height: 2),

                    // Row 5: ชำระเงินสุทธิ (highlighted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('ชำระเงินสุทธิ',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                            flex: 3,
                            child: Text(
                              '${Global.format(getTotalPayment(invoice.order))}',
                              style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.bold),
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
  copyWidgets.add(
    Container(
      height: 50,
      padding: const EdgeInsets.all(4.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'ข้าพเจ้าขอรับรองว่า ข้าพเจ้าเป็นเจ้าของและมีกรรมสิทธิ์โดยชอบด้วยกฎหมายแต่เพียงผู้เดียวในทองคำที่นำมาขายให้กับบริษัทฯ โดยปราศจากภาระผูกพัน',
                style: const TextStyle(fontSize: 9)),
            Text(
                'และการลิดรอนสิทธิใดๆ ทั้งสิ้น ข้าพเจ้ามีความยินยอมให้ทางบริษัทฯ นำทองคำที่ส่งมอบข้างต้นไปดำเนินการตรวจสอบคุณภาพตามวิธีการของบริษัทฯ ',
                style: const TextStyle(fontSize: 9)),
            Text(
                'หากไม่ผ่านการตรวจสอบ ข้าพเจ้ายอมให้บริษัทฯ มีสิทธิปฏิเสธการรับทองคำและชดใช้ค่าเสียหายตามที่บริษัทฯ เรียกร้องโดยไม่มีข้อโต้แย้งในทุกกรณี',
                style: const TextStyle(fontSize: 9)),
          ]),
    ),
  );
  copyWidgets.add(
    Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(children: [
          Expanded(
            flex: 8,
            child: Container(
              // width: double.infinity,
              // height: 55,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text('ร้านทองเพิ่ม(ลด)ให้:',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, color: PdfColors.blue700)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            '${addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) < 0 ? "(${addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0)})" : addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0)} บาท',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 9,
                                color: addDisValue(invoice.order.discount ?? 0,
                                            invoice.order.addPrice ?? 0) <
                                        0
                                    ? PdfColors.red
                                    : PdfColors.blue700)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text(
                          '${Global.getRefillPayTittle(Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} :  ',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 9, color: PdfColors.blue700),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            '${Global.format(Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) >= 0 ? Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) : -Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} บาท',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, color: PdfColors.blue700)),
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
                                      fontSize: 9, color: PdfColors.blue700))),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  "${Global.format(invoice.payments![i].amount ?? 0)} บาท",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 9, color: PdfColors.blue700)))
                        ])))
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 85,
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Text('(                                )',
                      style: const TextStyle(fontSize: 9)),
                  SizedBox(height: 5),
                  Text('ผู้รับเงิน/ผู้ส่งมอบทอง',
                      style: const TextStyle(fontSize: 9)),
                  Spacer(),
                  Text('(                                )',
                      style: const TextStyle(fontSize: 9)),
                  SizedBox(height: 5),
                  Text('ผู้ซื้อ/ผู้รับมอบทอง',
                      style: const TextStyle(fontSize: 9)),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ])),
  );

  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(20),
      pageFormat: PdfPageFormat.a4,
      // orientation: PageOrientation.landscape,
      build: (context) => originalWidgets,
    ),
  );

  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(20),
      pageFormat: PdfPageFormat.a4,
      // orientation: PageOrientation.landscape,
      build: (context) => copyWidgets,
    ),
  );
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
      vat += (order.details![i].commission! + order.details![i].packagePrice!) * 7 / 107;
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
            flex: 3,
            child: Text('ขายทองคำแท่ง 96.5% : ',
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
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9))),
          Expanded(
              flex: 3,
              child: Text(
                  "มูลค่า :     ${Global.format(orders[i].priceIncludeTax ?? 0)} บาท",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9))),
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
            flex: 3,
            child: Text('รับซื้อทองแท่ง 96.5% : ',
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
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9))),
          Expanded(
              flex: 3,
              child: Text(
                  "มูลค่า :     ${Global.format(orders[i].priceIncludeTax ?? 0)} บาท",
                  textAlign: TextAlign.right,
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
