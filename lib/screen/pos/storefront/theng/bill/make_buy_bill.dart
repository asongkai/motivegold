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

Future<Uint8List> makeBuyUsedThengBill(Invoice invoice) async {
  motivePrint(invoice.payments?.length);
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
    await header(invoice.order, 'ใบรับซื้อทองเก่า / ใบสําคัญจ่าย', versionText: 'ต้นฉบับ'),
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
    // motivePrint(invoice.items[i].priceIncludeTax);
    // motivePrint(NumberToThaiWords.convertDouble(invoice.items[i].priceIncludeTax ?? 0));
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
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(),
                  ),
                  child: paddedText(
                      '- ${NumberToThaiWords.convertDouble(Global.getOrderTotal(invoice.order))} -',
                      align: TextAlign.center,
                      style: const TextStyle(fontSize: 8)),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(),
                  ),
                  child: paddedText('รวมน้ำหนักทอง',
                      align: TextAlign.right,
                      style: const TextStyle(fontSize: 9)),
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
      height: 70,
      padding: const EdgeInsets.all(4.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'ข้าพเจ้าขอรับรองว่า ข้าพเจ้าเป็นเจ้าของและมีกรรมสิทธิ์โดยชอบด้วยกฎหมายแต่เพียงผู้เดียวในทองคำที่นำมาขายให้กับบริษัทฯ',
                style: const TextStyle(fontSize: 9)),
            Text(
                'โดยปราศจากภาระผูกพันและการลิดรอนสิทธิใดๆ ทั้งสิ้น ข้าพเจ้ามีความยินยอมให้ทางบริษัทฯ นำทองคำที่ส่งมอบข้างต้น',
                style: const TextStyle(fontSize: 9)),
            Text(
                'ไปดำเนินการตรวจสอบคุณภาพตามวิธีการของบริษัทฯ หากไม่ผ่านการตรวจสอบ ข้าพเจ้ายอมให้บริษัทฯ มีสิทธิปฏิเสธการรับ',
                style: const TextStyle(fontSize: 9)),
            Text(
                'ทองคำและชดใช้ค่าเสียหายตามที่บริษัทฯ เรียกร้องโดยไม่มีข้อโต้แย้งในทุกกรณี',
                style: const TextStyle(fontSize: 9)),
          ]),
    ),
  );
  widgets.add(
    Padding(
      padding: const EdgeInsets.only(top: 8.0),
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
                  child: Text('${addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) < 0 ? "(${addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0)})" : addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 9, color: addDisValue(invoice.order.discount ?? 0,
                          invoice.order.addPrice ?? 0) <
                          0
                          ? PdfColors.red
                          : PdfColors.blue700)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 8,
                  child: Text(
                      '${Global.getPayTittle(Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))}:',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 9, color: PdfColors.blue700)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                      '${Global.format(Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) >= 0 ? Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) : -Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 9, color: PdfColors.blue700)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
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
  );

  widgets.add(
    Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  paddedText(
                    'ผู้รับมอบทองเก่า/ผู้จ่ายเงิน',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 9),
                  ),
                  paddedText(
                    'วันที่ ..... / ..... / .........',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 9),
                  ),
                ],
              ),
            ),
            Expanded(flex: 4, child: Container()),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  paddedText(
                    'ผู้ส่งมอบทองเก่า/ผู้รับเงิน',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 9),
                  ),
                  paddedText(
                    'วันที่ ..... / ..... / .........',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 9),
                  ),
                ],
              ),
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

Future<Uint8List> makeBuyThengBill(Invoice invoice) async {
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
                      '${Global.format(invoice.items[i].priceIncludeTax ?? 0)}',
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
                      '${Global.format(invoice.items[i].priceIncludeTax ?? 0)}',
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
Widget sn(List<OrderModel>? orders) {
  for (int i = 0; i < orders!.length; i++) {
    if (orders[i].orderTypeId == 4) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text('ขายทองคํารูปพรรณใหม่ : ',
                textAlign: TextAlign.left, style: const TextStyle(fontSize: 9)),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text('รับซื้อทองคําแท่งเก่า : ',
                textAlign: TextAlign.left, style: const TextStyle(fontSize: 9)),
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
