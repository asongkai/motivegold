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

Future<Uint8List> makeBuyUsedThengBill(Invoice invoice,
    {int option = 1}) async {
  motivePrint(invoice.payments?.length);
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
      await header(invoice.order, 'ใบรับซื้อทองเก่า / ใบสําคัญจ่าย',
          versionText: versionText),
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
                    child: paddedText('วันที่จองราคา', align: TextAlign.right),
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
                        invoice.items[i].bookDate != null
                            ? Global.formatDateNT(
                                invoice.items[i].bookDate.toString())
                            : "",
                        align: TextAlign.right),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                        left: BorderSide(width: 0.25),
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
                        '${Global.format(invoice.items[i].priceIncludeTax ?? 0)}',
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(),
                    ),
                    child: paddedText(
                        '(${NumberToThaiWords.convertDouble(Global.getOrderTotal(invoice.order))})',
                        align: TextAlign.center,
                        style: const TextStyle(fontSize: 12)),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 0.25),
                      ),
                    ),
                    child: paddedText('รวม',
                        align: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
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
                        '${Global.format(Global.getOrderTotalWeightBaht(invoice.items))}',
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
                        '${Global.format(Global.getOrderTotalAmount(invoice.items))}',
                        align: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
            ]),
      ),
    );

    widgets.add(
      Container(
        height: 20,
        decoration: const BoxDecoration(border: Border()),
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
                          Text(
                              'หมายเหตุ : สินค้าทองคำแท่ง บริษัทฯได้รับการยกเว้นภาษีมูลค่าเพิ่ม ${invoice.order.remark ?? ''}',
                              style: const TextStyle(fontSize: 12)),
                        ])),
              )),
            ]),
      ),
    );

    widgets.add(
      Container(
        height: 50,
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'ข้าพเจ้าขอรับรองว่า ข้าพเจ้าเป็นเจ้าของและมีกรรมสิทธิ์โดยชอบด้วยกฎหมายแต่เพียงผู้เดียวในทองคำที่นำมาขายให้กับบริษัทฯโดยปราศจากภาระผูกพัน ',
                  style: const TextStyle(fontSize: 12)),
              Text(
                  'และการลิดรอนสิทธิใดๆ ทั้งสิ้น ข้าพเจ้ามีความยินยอมให้ทางบริษัทฯ นำทองคำที่ส่งมอบข้างต้นไปดำเนินการตรวจสอบคุณภาพตามวิธีการของบริษัทฯ',
                  style: const TextStyle(fontSize: 12)),
              Text(
                  'หากไม่ผ่านการตรวจสอบ ข้าพเจ้ายอมให้บริษัทฯ มีสิทธิปฏิเสธการรับทองคำและชดใช้ค่าเสียหายตามที่บริษัทฯ เรียกร้องโดยไม่มีข้อโต้แย้งในทุกกรณี ',
                  style: const TextStyle(fontSize: 12)),
            ]),
      ),
    );
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Row(children: [
          Expanded(
              flex: 8,
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
                          child: Text('ร้านทองเพิ่ม(ลด)ให้ :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12, color: PdfColors.blue700)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              '${addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) < 0 ? "(${addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0)})" : addDisValue(invoice.order.discount ?? 0, invoice.order.addPrice ?? 0)} บาท',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: addDisValue(
                                              invoice.order.discount ?? 0,
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
                              '${Global.getPayTittle(Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} :',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12, color: PdfColors.blue700)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) >= 0 ? Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) : -Global.payToCustomerOrShopValue(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} บาท',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12, color: PdfColors.blue700)),
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
                                        fontSize: 12,
                                        color: PdfColors.blue700))),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    invoice.order.orderStatus == 'CANCEL'
                                        ? "0.00 บาท"
                                        : "${Global.format(invoice.payments![i].amount ?? 0)} บาท",
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: PdfColors.blue700)))
                          ])))
                      ],
                    ),
                  ],
                ),
              )),
          SizedBox(width: 5),
          Expanded(
            flex: 3,
            child: Container(
              height: 65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 15),
                  Text('                                ',
                      style: const TextStyle(fontSize: 11)),
                  Text('ผู้ขาย / ผู้รับเงิน / ผู้ส่งมอบทอง',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('${Global.company?.name} (${Global.branch?.name})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11)),
                  Text('ผู้รับซื้อ / ผู้จ่ายเงิน / รับทอง',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  // SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ]),
      ),
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
  combinedWidgets.add(SizedBox(height: 20));
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
  combinedWidgets.add(SizedBox(height: 20));

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

Future<Uint8List> makeBuyThengBill(Invoice invoice, {int option = 1}) async {
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
      await header(invoice.order, 'ใบรับทอง (Goods Receipe Note)',
          versionText: versionText),
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
                        bottom: BorderSide(width: 0.25),
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
                        bottom: BorderSide(width: 0.25),
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
                        bottom: BorderSide(width: 0.25),
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
                    child: paddedText('รวมน้ำหนักทอง', align: TextAlign.right),
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
        height: 45,
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
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('หมายเหตุ : ${invoice.order.remark ?? ''}',
                                  style: const TextStyle(fontSize: 12)),
                              Text(
                                  'บันทึกเข้าระบบ ${Global.formatDateNT(invoice.order.createdDate.toString())}',
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.span),
                              Spacer(),
                              Row(children: [
                                Text(
                                    '- ${NumberToThaiWords.convertDouble(invoice.order.priceIncludeTax ?? 0)} -',
                                    overflow: TextOverflow.visible,
                                    style: const TextStyle(fontSize: 12)),
                              ]),
                              SizedBox(height: 3),
                            ])),
                  )),
              Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 0.25)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 0.0, right: 4.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('ราคาทองคำแท่งรวม :',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12)),
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
                              fontSize: 12,
                            ),
                          ),
                        ]),
                  ),
                ),
              ),
            ]),
      ),
    );
    widgets.add(
      Container(
        height: 50,
        padding: const EdgeInsets.all(4.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'ข้าพเจ้าขอรับรองว่า ข้าพเจ้าเป็นเจ้าของและมีกรรมสิทธิ์โดยชอบด้วยกฎหมายแต่เพียงผู้เดียวในทองคำที่นำมาขายให้กับบริษัทฯ โดยปราศจากภาระผูกพัน',
                  style: const TextStyle(fontSize: 12)),
              Text(
                  'และการลิดรอนสิทธิใดๆ ทั้งสิ้น ข้าพเจ้ามีความยินยอมให้ทางบริษัทฯ นำทองคำที่ส่งมอบข้างต้นไปดำเนินการตรวจสอบคุณภาพตามวิธีการของบริษัทฯ ',
                  style: const TextStyle(fontSize: 12)),
              Text(
                  'หากไม่ผ่านการตรวจสอบ ข้าพเจ้ายอมให้บริษัทฯ มีสิทธิปฏิเสธการรับทองคำและชดใช้ค่าเสียหายตามที่บริษัทฯ เรียกร้องโดยไม่มีข้อโต้แย้งในทุกกรณี',
                  style: const TextStyle(fontSize: 12)),
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
                          child: Text('ส่วนลด:',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 11, color: PdfColors.blue700)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(invoice.order.discount ?? 0)} บาท',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 11, color: PdfColors.blue700)),
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
                                fontSize: 11, color: PdfColors.blue700),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) >= 0 ? Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0) : -Global.payToCustomerOrShopValueWholeSale(invoice.orders, invoice.order.discount ?? 0, invoice.order.addPrice ?? 0))} บาท',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 11, color: PdfColors.blue700)),
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
                                        fontSize: 11,
                                        color: PdfColors.blue700))),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    invoice.order.orderStatus == 'CANCEL'
                                        ? "0.00 บาท"
                                        : "${Global.format(invoice.payments![i].amount ?? 0)} บาท",
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: PdfColors.blue700)))
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
                        style: const TextStyle(fontSize: 11)),
                    SizedBox(height: 5),
                    Text('ผู้รับเงิน/ผู้ส่งมอบทอง',
                        style: const TextStyle(fontSize: 11)),
                    Spacer(),
                    Text('(                                )',
                        style: const TextStyle(fontSize: 11)),
                    SizedBox(height: 5),
                    Text('ผู้ซื้อ/ผู้รับมอบทอง',
                        style: const TextStyle(fontSize: 11)),
                    SizedBox(height: 5),
                  ],
                ),
              ),
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
  combinedWidgets.add(SizedBox(height: 10));
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
  combinedWidgets.add(SizedBox(height: 10));

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

Widget sn(List<OrderModel>? orders) {
  for (int i = 0; i < orders!.length; i++) {
    if (orders[i].orderTypeId == 4) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Text('ขายทองคำแท่ง : ${orders[i].orderId}',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
              flex: 3,
              child: Text(
                  'วันที่ :     ${Global.formatDateNT(orders[i].orderDate.toString())}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11))),
          Expanded(
              flex: 3,
              child: Text(
                  "มูลค่า :     ${Global.format(orders[i].priceIncludeTax ?? 0)} บาท",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11))),
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
            flex: 5,
            child: Text('รับซื้อทองคำแท่ง : ${orders[i].orderId}',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
              flex: 3,
              child: Text(
                  'วันที่ :     ${Global.formatDateNT(orders[i].orderDate.toString())}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11))),
          Expanded(
              flex: 3,
              child: Text(
                  "มูลค่า :     ${Global.format(orders[i].priceIncludeTax ?? 0)} บาท",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11))),
        ],
      );
    }
  }
  return Container();
}

Widget paddedText(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 11)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
