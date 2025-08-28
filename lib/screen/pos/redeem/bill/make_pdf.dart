import 'dart:typed_data';

import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/classes/number_to_thai_words.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:motivegold/widget/ui/line.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

Future<Uint8List> makeRedeemSingleBillPdf(InvoiceRedeem invoice,
    {int option = 1}) async {
  motivePrint(invoice.order?.toJson());

  // Apply same font pattern as makeRefillThengBill
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
    icons: await PdfGoogleFonts.materialIcons(),
  );
  final pdf = Document(theme: myTheme);

  // Function to create bill content with version text (following makeRefillThengBill pattern)
  Future<List<Widget>> createBillContent(String versionText) async {
    List<Widget> widgets = [];

    widgets.add(
      await headerRedeem(invoice.order, 'ใบเสร็จรับเงิน / ใบกํากับภาษี',
          versionText: versionText),
    );
    widgets.add(
      docNoRedeem(invoice.order),
    );
    widgets.add(height(h: 5));

    // Apply border pattern similar to makeRefillThengBill
    widgets.add(Container(
      decoration: BoxDecoration(
          // border: Border.all(width: 0.25),
          ),
      child: Table(
        border: TableBorder(
          left: BorderSide.none,
          // Remove left border
          right: BorderSide.none,
          // Remove right border
          top: BorderSide(width: 0.25),
          // Keep top border
          bottom: BorderSide(width: 0.25),
          // Keep bottom border
          // horizontalInside: BorderSide(width: 0.25), // Keep horizontal dividers
          verticalInside: BorderSide(
              width: 0.25), //BorderSide.none, // Remove vertical dividers
        ),
        // border: TableBorder.all(color: PdfColors.black, width: 0.0),
        children: [
          TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(width: 0.25),
                  right: BorderSide(width: 0.25),
                  top: BorderSide(width: 0.25),
                ),
              ),
              children: [
                paddedText('ลำดับ', align: TextAlign.center),
                paddedText('เลขที่ตั๋ว\nขายฝาก', align: TextAlign.center),
                paddedText('หลักประกัน', align: TextAlign.center),
                paddedText('น้ำหนัก\n(กรัม)', align: TextAlign.center),
                paddedText('จำนวน\n(ชิ้น)', align: TextAlign.center),
                paddedText('ราคาตามจำนวนสินไถ่\nรวมภาษีมูลค่าเพิ่ม(บาท)',
                    align: TextAlign.center),
                paddedText('ราคาตามจำนวน\nสินไถ่ (บาท)',
                    align: TextAlign.center),
                paddedText('ราคาตามจำนวน\nขายฝาก (บาท)',
                    align: TextAlign.center),
                paddedText('ฐานภาษี\n(บาท)', align: TextAlign.center),
                paddedText('ภาษีมูลค่าเพิ่ม\n(บาท)', align: TextAlign.center),
              ]),
          for (int i = 0; i < invoice.order.details!.length; i++)
            TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(width: 0.25),
                  right: BorderSide(width: 0.25),
                  top: BorderSide(width: 0.25),
                ),
              ),
              children: [
                paddedText('${i + 1}'),
                paddedText(invoice.order.details![i].referenceNo ?? ''),
                paddedText('ทองคำรูปพรรณ 96.5%'),
                paddedText(
                    '${Global.format(invoice.order.details![i].weight ?? 0)}',
                    align: TextAlign.center),
                paddedText(
                    '${Global.formatInt(invoice.order.details![i].qty ?? 0)}',
                    align: TextAlign.center),
                paddedText(
                    '${Global.format(invoice.order.details![i].redemptionVat ?? 0)}',
                    align: TextAlign.right),
                paddedText(
                    '${Global.format(invoice.order.details![i].redemptionValue ?? 0)}',
                    align: TextAlign.right),
                paddedText(
                    '${Global.format(invoice.order.details![i].depositAmount ?? 0)}',
                    align: TextAlign.right),
                paddedText(
                    '${Global.format(invoice.order.details![i].taxBase ?? 0)}',
                    align: TextAlign.right),
                paddedText(
                    '${Global.format(invoice.order.details![i].taxAmount ?? 0)}',
                    align: TextAlign.right),
              ],
            ),
          TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(width: 0.25),
                  right: BorderSide(width: 0.25),
                  bottom: BorderSide(width: 0.25),
                ),
              ),
              children: [
                paddedText(''),
                paddedText(''),
                paddedText(''),
                paddedText(''),
                paddedText(''),
                paddedText(''),
                paddedText(''),
                paddedText(''),
              ]),
          TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(width: 0.25),
                  right: BorderSide(width: 0.25),
                  bottom: BorderSide(width: 0.25),
                ),
              ),
              children: [
                paddedText('', style: const TextStyle(fontSize: 10)),
                paddedText(''),
                paddedText('รวม',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                paddedText(Global.format(getRedeemWeightTotal(invoice.items)),
                    align: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                paddedText(Global.formatInt(getQtyTotalB(invoice.items)),
                    align: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                paddedText(Global.format(getRedemptionVatTotal(invoice.items)),
                    align: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                paddedText(
                    Global.format(getRedemptionValueTotal(invoice.items)),
                    align: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                paddedText(Global.format(getDepositAmountTotal(invoice.items)),
                    align: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                paddedText(Global.format(getTaxBaseTotal(invoice.items)),
                    align: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                paddedText(Global.format(getTaxAmountTotal(invoice.items)),
                    align: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ])
        ],
      ),
    ));

    widgets.add(height(h: 5));
    widgets.add(Row(children: [
      Text('ใบเสร็จรับเงินนี้จะสมบูรณ์ต่อเมื่อ บริษัทฯได้รับเงินอย่างครบถ้วน',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    ]));

    widgets.add(
      Row(children: [
        Expanded(
          flex: 8,
          child: Container(
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
                border: Border.all(width: 0.25),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 5),
                    Expanded(
                        flex: 6,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 3),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text('ผลประโยชน์ครั้งสุดท้าย :',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: PdfColors.black))),
                                    SizedBox(width: 20),
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${Global.format(invoice.order.benefitAmount ?? 0)} บาท',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: PdfColors.black))),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text('มูลค่าขายฝาก :',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: PdfColors.black))),
                                    SizedBox(width: 20),
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${Global.format(invoice.order.depositAmount ?? 0)} บาท',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: PdfColors.black))),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text('ชำระเงินสุทธิ :',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: PdfColors.black))),
                                    SizedBox(width: 20),
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${Global.format(invoice.order.paymentAmount ?? 0)} บาท',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: PdfColors.black))),
                                  ]),
                            ])),
                    Expanded(
                        flex: 6,
                        child: Column(children: [
                          SizedBox(height: 3),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text('มูลค่าสินไถ่ :',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: PdfColors.black))),
                                SizedBox(width: 20),
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                        '${(invoice.order.vatOption == 'Include') ? Global.format(invoice.order.redemptionVat ?? 0) : Global.format(invoice.order.redemptionValue ?? 0)} บาท',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: PdfColors.black))),
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text('ผลประโยชน์ชำระแล้ว :',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: PdfColors.black))),
                                SizedBox(width: 20),
                                if (invoice.order.vatOption == 'Exclude')
                                  Expanded(
                                      flex: 6,
                                      child: Text(
                                          '${(invoice.order.benefitAmount ?? 0) - (invoice.order.taxBase ?? 0) < 0 ? '(${Global.format(-((invoice.order.benefitAmount ?? 0) - (invoice.order.taxBase ?? 0)))})' : Global.format((invoice.order.benefitAmount ?? 0) - (invoice.order.taxBase ?? 0))} บาท',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  (invoice.order.benefitAmount ??
                                                                  0) -
                                                              (invoice.order
                                                                      .taxBase ??
                                                                  0) <
                                                          0
                                                      ? PdfColors.red
                                                      : PdfColors.black))),
                                if (invoice.order.vatOption == 'Include')
                                  Expanded(
                                      flex: 6,
                                      child: Text(
                                          '${(invoice.order.benefitAmount ?? 0) - ((invoice.order.taxBase ?? 0) + (invoice.order.taxAmount ?? 0)) < 0 ? '(${Global.format(-((invoice.order.benefitAmount ?? 0) - ((invoice.order.taxBase ?? 0) + (invoice.order.taxAmount ?? 0))))})' : Global.format((invoice.order.benefitAmount ?? 0) - ((invoice.order.taxBase ?? 0) + (invoice.order.taxAmount ?? 0)))} บาท',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: (invoice.order
                                                                  .benefitAmount ??
                                                              0) -
                                                          ((invoice.order
                                                                      .taxBase ??
                                                                  0) +
                                                              (invoice.order
                                                                      .taxAmount ??
                                                                  0)) <
                                                      0
                                                  ? PdfColors.red
                                                  : PdfColors.black))),
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text('ชำระเงินสุทธิ :',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: PdfColors.black))),
                                SizedBox(width: 20),
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                        '${Global.format(invoice.order.paymentAmount ?? 0)} บาท',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: PdfColors.black))),
                              ]),
                        ])),
                    SizedBox(width: 10),
                  ],
                ),
                Divider(
                  height: 0.25,
                  thickness: 0.25,
                ),
                height(h: 4),
                Row(
                  children: [
                    SizedBox(width: 5),
                    Expanded(
                      flex: 6,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Text(
                              'ร้านทองรับ - ลูกค้าจ่าย (สุทธิ) :',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 10, color: PdfColors.blue700),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 6,
                            child: Text(
                                '${Global.format(invoice.order.paymentAmount)} บาท',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 10, color: PdfColors.blue700)),
                          ),
                        ],
                      ),
                    ),
                    for (int i = 0; i < invoice.payments!.length; i++)
                      Expanded(
                          flex: 6,
                          child: Container(
                              child: Row(children: [
                            Expanded(
                                flex: invoice.payments!.length > 1 ? 3 : 6,
                                child: Text(
                                    "${getPaymentType(invoice.payments![i].paymentMethod)} :",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: PdfColors.blue700))),
                            SizedBox(width: 20),
                            Expanded(
                                flex: 6,
                                child: Text(
                                    "${Global.format(invoice.payments![i].amount ?? 0)} บาท",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: PdfColors.blue700)))
                          ]))),
                    SizedBox(width: 5),
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
            height: 65,
            child: Column(
              children: [
                Text('                                ',
                    style: const TextStyle(fontSize: 10)),
                Text('${getCustomerName(invoice.customer)})',
                    style: const TextStyle(fontSize: 10)),
                Text('ผู้ไถ่ถอนและรับคืนหลักประกัน',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Spacer(),
                Text('${Global.company?.name} (${Global.branch?.name})',
                    style: const TextStyle(fontSize: 10)),
                Text('ผู้รับไถ่ถอนและคืนหลักประกัน',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ]),
    );

    return widgets;
  }

  // Create original and copy versions (following makeRefillThengBill pattern)
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

  // Create single page with both versions (following makeRefillThengBill pattern)
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

// Keep the paddedText function consistent with makeRefillThengBill
Widget paddedText(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 10),
        final isPadding = true}) =>
    Padding(
      padding: !isPadding ? const EdgeInsets.all(1) : const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
