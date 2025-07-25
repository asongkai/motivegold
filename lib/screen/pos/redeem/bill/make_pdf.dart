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

Future<Uint8List> makeRedeemSingleBillPdf(InvoiceRedeem invoice) async {
  motivePrint(invoice.order?.toJson());
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
    await headerRedeem(invoice.order, 'ใบเสร็จรับเงิน / ใบกํากับภาษี'),
  );
  widgets.add(
    docNoRedeem(invoice.order),
  );
  widgets.add(height(h: 5));
  widgets.add(Table(
    border: TableBorder.all(color: PdfColors.grey500),
    children: [
      TableRow(children: [
        paddedText('ลำดับ', align: TextAlign.center),
        paddedText('เลขที่ตั๋ว\nขายฝาก', align: TextAlign.center),
        paddedText('หลักประกัน', align: TextAlign.center),
        paddedText('น้ำหนัก\n(กรัม)', align: TextAlign.center),
        paddedText('จำนวน\n(ชิ้น)', align: TextAlign.center),
        paddedText('ราคาตามจำนวนสินไถ่\nรวมภาษีมูลค่าเพิ่ม(บาท)',
            align: TextAlign.center),
        paddedText('ราคาตามจำนวน\nสินไถ่ (บาท)', align: TextAlign.center),
        paddedText('ราคาตามจำนวน\nขายฝาก (บาท)', align: TextAlign.center),
        paddedText('ฐานภาษี\n(บาท)', align: TextAlign.center),
        paddedText('ภาษีมูลค่าเพิ่ม\n(บาท)', align: TextAlign.center),
      ]),
      for (int i = 0; i < invoice.order.details!.length; i++)
        TableRow(
          decoration: const BoxDecoration(),
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
      TableRow(children: [
        paddedText('', style: const TextStyle(fontSize: 14)),
        paddedText(''),
        paddedText('รวมท้ังหมด'),
        paddedText(Global.format(getRedeemWeightTotal(invoice.items)),
            align: TextAlign.center),
        paddedText(Global.formatInt(getQtyTotalB(invoice.items)),
            align: TextAlign.center),
        paddedText(Global.format(getRedemptionVatTotal(invoice.items)),
            align: TextAlign.right),
        paddedText(Global.format(getRedemptionValueTotal(invoice.items)),
            align: TextAlign.right),
        paddedText(Global.format(getDepositAmountTotal(invoice.items)),
            align: TextAlign.right),
        paddedText(Global.format(getTaxBaseTotal(invoice.items)),
            align: TextAlign.right),
        paddedText(Global.format(getTaxAmountTotal(invoice.items)),
            align: TextAlign.right),
      ])
    ],
  ));
  widgets.add(height(h: 5));
  widgets.add(Row(children: [
    Text('เงื่อนไขการการชำระเงิน',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    SizedBox(width: 40),
    Text('ใบเสร็จรับเงินนี้จะสมบูรณ์ต่อเมื่อ บริษัทฯได้รับเงินอย่างครบถ้วน',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
  ]));
  widgets.add(Table(
    children: [
      TableRow(children: [
        paddedText('รวมราคาตามจำนวนสินไถ่', isPadding: false),
        paddedText('', isPadding: false),
        paddedText('', isPadding: false),
        paddedText('', isPadding: false),
        paddedText('${Global.format(getRedemptionValueTotal(invoice.items))}',
            isPadding: false, align: TextAlign.right),
        paddedText('บาท', isPadding: false, align: TextAlign.center),
        paddedText('รวมราคาตามจำนวนสินไถ่', isPadding: false),
        paddedText('${Global.format(getRedemptionValueTotal(invoice.items))}',
            isPadding: false, align: TextAlign.right),
        paddedText('บาท', isPadding: false, align: TextAlign.center),
      ]),
      TableRow(children: [
        paddedText('ภาษีมุลค่าเพิ่ม', isPadding: false),
        paddedText('ร้อยละ', isPadding: false),
        paddedText('7%', isPadding: false),
        paddedText('', isPadding: false),
        underlinedText(
            text: '${Global.format(getTaxAmountTotal(invoice.items))}',
            axis: CrossAxisAlignment.end,
            fontWeight: FontWeight.normal),
        // paddedText('${Global.format(getTaxAmountTotal(invoice.items))}',
        //     isPadding: false, align: TextAlign.right),
        paddedText('บาท', isPadding: false, align: TextAlign.center),
        paddedText('หัก รวมราคาตามราคาขายฝาก', isPadding: false),
        underlinedText(
            text: '${Global.format(getDepositAmountTotal(invoice.items))}',
            axis: CrossAxisAlignment.end,
            fontWeight: FontWeight.normal),
        // paddedText('${Global.format(getDepositAmountTotal(invoice.items))}',
        //     isPadding: false, align: TextAlign.right),
        paddedText('บาท', isPadding: false, align: TextAlign.center),
      ]),
      TableRow(children: [
        paddedText('ราคาตามจำนวนสินไถ่รวมภาษีมูลค่าเพิ่ม', isPadding: false),
        paddedText('', isPadding: false),
        paddedText('', isPadding: false),
        paddedText('', isPadding: false),
        underlinedText(
            text: '${Global.format(getRedemptionVatTotal(invoice.items))}',
            axis: CrossAxisAlignment.end,
            doubleLine: true,
            fontWeight: FontWeight.normal),
        // paddedText('${Global.format(getRedemptionVatTotal(invoice.items))}',
        //     isPadding: false, align: TextAlign.right),
        paddedText('บาท', isPadding: false, align: TextAlign.center),
        paddedText('รวมมูลค่าฐานภาษีมูลค่าเพิ่ม', isPadding: false),
        underlinedText(
            text: '${Global.format(getTaxBaseTotal(invoice.items))}',
            axis: CrossAxisAlignment.end,
            doubleLine: true,
            fontWeight: FontWeight.normal),
        // paddedText('${Global.format(getTaxBaseTotal(invoice.items))}',
        //     isPadding: false, align: TextAlign.right),
        paddedText('บาท', isPadding: false, align: TextAlign.center),
      ]),
    ],
  ));

  widgets.add(Row(children: [
    Text('ร้านทองรับ - ลูกค้าจ่าย (สุทธิ) :',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    SizedBox(width: 40),
  ]));

  widgets.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(
        child: Table(
      columnWidths: {
        0: const FixedColumnWidth(20),
        1: const FixedColumnWidth(120),
        2: const FixedColumnWidth(80),
        3: const FixedColumnWidth(20),
      },
      children: [
        TableRow(children: [
          paddedText('', isPadding: false),
          paddedText(
              'รับผลประโยชน์ครั้งสุดท้ายรวม (${Global.format(taxBaseTotal(invoice.items))} - ${Global.format(getTaxBaseTotal(invoice.items) - getBenefitAmountTotal(invoice.items))})',
              isPadding: false),
          paddedText(
              '${Global.format(getBenefitAmountTotal(invoice.items))} บาท',
              isPadding: false,
              align: TextAlign.right),
          paddedText('', isPadding: false),
        ]),
        TableRow(children: [
          paddedText('', isPadding: false),
          paddedText(
              'ร้านรับ - ลูกค้าจ่าย เงินรวม (${Global.format(getDepositAmountTotal(invoice.items))} + ${Global.format(getBenefitAmountTotal(invoice.items))})',
              isPadding: false),
          paddedText(
              '${Global.format(getDepositAmountTotal(invoice.items) + getBenefitAmountTotal(invoice.items))} บาท',
              isPadding: false,
              align: TextAlign.right),
          paddedText('', isPadding: false),
        ]),
      ],
    )),
    Expanded(
        child: Table(
      columnWidths: {
        0: const FixedColumnWidth(20),
        1: const FixedColumnWidth(120),
        2: const FixedColumnWidth(80),
        3: const FixedColumnWidth(20),
      },
      children: [
        TableRow(children: [
          paddedText('', isPadding: false),
          if (invoice.order.vatOption == 'Exclude')
            paddedText(
                'ส่วนลด : (${Global.format(getRedemptionVatTotal(invoice.items))} - ${Global.format(getRedemptionValueTotal(invoice.items))})',
                isPadding: false),
          if (invoice.order.vatOption == 'Include')
            paddedText('ส่วนลด : _', isPadding: false),
          if (invoice.order.vatOption == 'Exclude')
            paddedText(
                '(${Global.format(getTaxAmountTotal(invoice.items))}) บาท',
                isPadding: false,
                align: TextAlign.right,
                style: const TextStyle(fontSize: 9, color: PdfColors.red)),
          if (invoice.order.vatOption == 'Include')
            paddedText('_',
                isPadding: false,
                align: TextAlign.right,
                style: const TextStyle(fontSize: 9, color: PdfColors.red)),
          paddedText('', isPadding: false),
        ]),
        for (int i = 0; i < invoice.payments!.length; i++)
          TableRow(children: [
            paddedText('', isPadding: false),
            paddedText(
                '${getPaymentType(invoice.payments![i].paymentMethod)} : ',
                isPadding: false),
            paddedText('${Global.format(invoice.payments![i].amount ?? 0)} บาท',
                isPadding: false, align: TextAlign.right),
            paddedText('', isPadding: false),
          ]),
      ],
    )),
  ]));

  widgets.add(height());
  widgets.add(Row(children: [
    Text('ผู้ไถ่ถอนและรับคืนหลักประกัน',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    SizedBox(width: 40),
    underlinedText(
        text: '${invoice.customer.firstName} ${invoice.customer.lastName}',
        underlineWidth: 200,
        axis: CrossAxisAlignment.center),
    Spacer(),
    Text('วัน เดือน ปี',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    SizedBox(width: 40),
    underlinedText(
        text: Global.formatDateMF(invoice.order.redeemDate.toString()),
        underlineWidth: 200,
        axis: CrossAxisAlignment.center),
  ]));

  widgets.add(Row(children: [
    Text('ผู้รับไถ่ถอนและคืนหลักประกัน',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    SizedBox(width: 40),
    underlinedText(
        text: '${Global.company?.name}',
        underlineWidth: 200,
        axis: CrossAxisAlignment.center),
    Spacer(),
    Text('วัน เดือน ปี',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    SizedBox(width: 40),
    underlinedText(
        text: Global.formatDateMF(invoice.order.redeemDate.toString()),
        underlineWidth: 200,
        axis: CrossAxisAlignment.center),
  ]));

  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(20),
      pageFormat: PdfPageFormat(
        PdfPageFormat.a4.height, // height becomes width
        PdfPageFormat.a4.width, // width becomes height
      ),
      orientation: PageOrientation.landscape,
      build: (context) => widgets,
    ),
  );
  return pdf.save();
}

Widget paddedText(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 9),
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
