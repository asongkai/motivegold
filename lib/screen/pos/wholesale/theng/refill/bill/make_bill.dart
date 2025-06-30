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
import 'package:printing/printing.dart';

Future<Uint8List> makeRefillThengBill(Invoice invoice) async {
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
    await header(invoice.order, 'ใบรับทอง (Goods Receipe Note)', versionText: 'ต้นฉบับ'),
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
                  border: Border.all(width: 0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('อื่นๆ:', style: const TextStyle(fontSize: 9)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                                child: Row(children: [
                              Text('['),
                              if (getCommission(invoice.order) > 0)
                                Icon(
                                  const IconData(0xe5ca),
                                  color: PdfColors.black,
                                  size: 18,
                                ),
                              if (getCommission(invoice.order) <= 0)
                                SizedBox(width: 18),
                              Text(']'),
                              SizedBox(width: 5),
                              Text('ค่าบล็อกทอง',
                                  style: const TextStyle(fontSize: 9)),
                            ]))),
                        SizedBox(width: 10),
                        Expanded(flex: 2, child: Container(child: Text(''))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                  Text('มูลค่าไม่รวมภาษี: ',
                                      style: const TextStyle(fontSize: 9)),
                                  Container(
                                      child: Text(
                                          '${Global.format(getCommissionNoVat(invoice.order))}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 9))),
                                  Text(' บาท',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 9)),
                                ]))),
                        SizedBox(width: 10),
                        Expanded(flex: 3, child: Container(child: Text(''))),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                                child: Row(children: [
                              Text('['),
                              if (getPackageNoVat(invoice.order) > 0)
                                Icon(
                                  const IconData(0xe5ca),
                                  color: PdfColors.black,
                                  size: 18,
                                ),
                              if (getPackageNoVat(invoice.order) <= 0)
                                SizedBox(width: 18),
                              Text(']'),
                              SizedBox(width: 5),
                              Text('ค่าบรรจุภัณฑ์',
                                  style: const TextStyle(fontSize: 9))
                            ]))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 2,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                  Text('จำนวน: ',
                                      style: const TextStyle(fontSize: 9)),
                                  Container(
                                      child: Text(
                                    '${getTotalPackageQty(invoice.order) > 0 ? Global.format(getTotalPackageQty(invoice.order)) : ""}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 9),
                                  )),
                                  Text('ชิ้น',
                                      style: const TextStyle(fontSize: 9))
                                ]))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                  Text('มูลค่าไม่รวมภาษี: ',
                                      style: const TextStyle(fontSize: 9)),
                                  Container(
                                      child: Text(
                                          '${Global.format(getPackageNoVat(invoice.order))}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 9))),
                                  Text(' บาท',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 9)),
                                ]))),
                        SizedBox(width: 10),
                        Expanded(flex: 3, child: Container(child: Text(''))),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 2, child: Container(child: Text(''))),
                        SizedBox(width: 10),
                        Expanded(flex: 2, child: Container(child: Text(''))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                  Text('ภาษีมูลค่าเพิ่ม 7%: ',
                                      style: const TextStyle(fontSize: 9)),
                                  Container(
                                      child: Text(
                                          '${Global.format(getVat(invoice.order))}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 9))),
                                  Text(' บาท',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 9)),
                                ]))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                  Text('มูลค่ารวมภาษี: ',
                                      style: const TextStyle(fontSize: 9)),
                                  Container(
                                      child: Text(
                                          '${Global.format(getCommission(invoice.order))}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 9))),
                                  Text(' บาท',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 9)),
                                ]))),
                      ]),
                ],
              ),
            ),
          ),
        ])),
  );
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
                        child: Text('ส่วนลด:',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, color: PdfColors.blue700)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            '${Global.format(invoice.order.discount ?? 0)} บาท',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, color: PdfColors.blue700)),
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
    await header(invoice.order, 'ใบรับทอง (Goods Receipe Note)', versionText: 'สำเนา'),
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
                  border: Border.all(width: 0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('อื่นๆ:', style: const TextStyle(fontSize: 9)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                                child: Row(children: [
                                  Text('['),
                                  if (getCommission(invoice.order) > 0)
                                    Icon(
                                      const IconData(0xe5ca),
                                      color: PdfColors.black,
                                      size: 18,
                                    ),
                                  if (getCommission(invoice.order) <= 0)
                                    SizedBox(width: 18),
                                  Text(']'),
                                  SizedBox(width: 5),
                                  Text('ค่าบล็อกทอง',
                                      style: const TextStyle(fontSize: 9)),
                                ]))),
                        SizedBox(width: 10),
                        Expanded(flex: 2, child: Container(child: Text(''))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('มูลค่าไม่รวมภาษี: ',
                                          style: const TextStyle(fontSize: 9)),
                                      Container(
                                          child: Text(
                                              '${Global.format(getCommissionNoVat(invoice.order))}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 9))),
                                      Text(' บาท',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 9)),
                                    ]))),
                        SizedBox(width: 10),
                        Expanded(flex: 3, child: Container(child: Text(''))),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                                child: Row(children: [
                                  Text('['),
                                  if (getPackageNoVat(invoice.order) > 0)
                                    Icon(
                                      const IconData(0xe5ca),
                                      color: PdfColors.black,
                                      size: 18,
                                    ),
                                  if (getPackageNoVat(invoice.order) <= 0)
                                    SizedBox(width: 18),
                                  Text(']'),
                                  SizedBox(width: 5),
                                  Text('ค่าบรรจุภัณฑ์',
                                      style: const TextStyle(fontSize: 9))
                                ]))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 2,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('จำนวน: ',
                                          style: const TextStyle(fontSize: 9)),
                                      Container(
                                          child: Text(
                                            '${getTotalPackageQty(invoice.order) > 0 ? Global.format(getTotalPackageQty(invoice.order)) : ""}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(fontSize: 9),
                                          )),
                                      Text('ชิ้น',
                                          style: const TextStyle(fontSize: 9))
                                    ]))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('มูลค่าไม่รวมภาษี: ',
                                          style: const TextStyle(fontSize: 9)),
                                      Container(
                                          child: Text(
                                              '${Global.format(getPackageNoVat(invoice.order))}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 9))),
                                      Text(' บาท',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 9)),
                                    ]))),
                        SizedBox(width: 10),
                        Expanded(flex: 3, child: Container(child: Text(''))),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 2, child: Container(child: Text(''))),
                        SizedBox(width: 10),
                        Expanded(flex: 2, child: Container(child: Text(''))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('ภาษีมูลค่าเพิ่ม 7%: ',
                                          style: const TextStyle(fontSize: 9)),
                                      Container(
                                          child: Text(
                                              '${Global.format(getVat(invoice.order))}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 9))),
                                      Text(' บาท',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 9)),
                                    ]))),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child: Container(
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('มูลค่ารวมภาษี: ',
                                          style: const TextStyle(fontSize: 9)),
                                      Container(
                                          child: Text(
                                              '${Global.format(getCommission(invoice.order))}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 9))),
                                      Text(' บาท',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 9)),
                                    ]))),
                      ]),
                ],
              ),
            ),
          ),
        ])),
  );
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
                        child: Text('ส่วนลด:',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, color: PdfColors.blue700)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            '${Global.format(invoice.order.discount ?? 0)} บาท',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, color: PdfColors.blue700)),
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
  double total = 0;
  double vat = 0;
  double com = 0;
  for (int i = 0; i < order.details!.length; i++) {
    total += order.details![i].packagePrice ?? 0;
    com += order.details![i].commission ?? 0;
    vat += total + com + order.details![i].taxAmount!;
  }
  return vat;
}

getVat(OrderModel order) {
  double vat = 0;
  for (int i = 0; i < order.details!.length; i++) {
    vat += order.details![i].taxAmount!;
  }
  return vat;
}

getPackageNoVat(OrderModel order) {
  double total = 0;
  for (int i = 0; i < order.details!.length; i++) {
    total += order.details![i].packagePrice ?? 0;
  }
  return total;
}

getCommissionNoVat(OrderModel order) {
  double total = 0;
  for (int i = 0; i < order.details!.length; i++) {
    total += order.details![i].commission ?? 0;
  }
  return total;
}

getTotalPackageQty(OrderModel order) {
  double total = 0;
  for (int i = 0; i < order.details!.length; i++) {
    total += order.details![i].packageQty ?? 0;
  }
  return total;
}

Widget sn(List<OrderModel>? orders) {
  for (int i = 0; i < orders!.length; i++) {
    if (orders[i].orderTypeId == 11) {
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
    if (orders[i].orderTypeId == 10) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('ซื้อทองแท่ง 96.5% : ',
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
