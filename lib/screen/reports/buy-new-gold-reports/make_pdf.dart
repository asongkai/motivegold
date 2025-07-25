import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeBuyNewGoldReportPdf(
    List<OrderModel?> orders, int type, String date) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  List<Widget> widgets = [];

  widgets.add(Center(
    child: Text(
      'รายงานซื้อทองรูปพรรณใหม่ 96.5%',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
    ),
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
          "ชื่อผู้ประกอบการ: ${Global.company!.name} (${Global.branch?.name}) เลขประจําตัวผู้เสียภาษี: ${Global.company?.taxNumber}"),
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
          "ที่อยู่: ${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}"),
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("ระหว่างวันที่: $date"),
      Text('วันที่พิมพ์: ${Global.formatDate(DateTime.now().toString())}'),
    ],
  ));

  widgets.add(height());

  // Apply modern design pattern
  widgets.add(Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: PdfColors.grey300, width: 1),
    ),
    child: Table(
      border: TableBorder(
        top: BorderSide.none,
        bottom: BorderSide.none,
        left: BorderSide.none,
        right: BorderSide.none,
        horizontalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
        verticalInside: BorderSide.none,
      ),
      children: [
        // Clean header row with rounded top corners
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.blue600,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            children: [
              paddedTextSmall('ลำดับ',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('เลขที่ใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('วันที่',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              // paddedTextSmall('เวลา',
              //     style: TextStyle(
              //         fontSize: 9,
              //         fontWeight: FontWeight.bold,
              //         color: PdfColors.white
              //     )
              // ),
              paddedTextSmall('ผู้ขาย',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('น้ําหนักรวม\n(กรัม)',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ยอดขายรวม\nภาษีมูลค่าเพิ่ม',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('มูลค่ายกเว้น',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ผลต่างรวม\nภาษีมูลค่าเพิ่ม',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ฐานภาษี\nมูลค่าเพิ่ม',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ภาษี\nมูลค่าเพิ่ม',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
              paddedTextSmall('ยอดขายที่ไม่รวม\nภาษีมูลค่าเพิ่ม',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.right
              ),
            ]
        ),
        // Data rows with color coding
        for (int i = 0; i < orders.length; i++)
          TableRow(
            decoration: const BoxDecoration(),
            children: [
              paddedTextSmall('${i + 1}', style: TextStyle(fontSize: 8)),
              paddedTextSmall(orders[i]!.orderId, style: TextStyle(fontSize: 8)),
              paddedTextSmall(Global.dateOnly(orders[i]!.createdDate.toString()),
                  style: TextStyle(fontSize: 8)),
              // paddedTextSmall(Global.timeOnlyF(orders[i]!.createdDate.toString()),
              //     style: TextStyle(fontSize: 8)),
              paddedTextSmall('${getCustomerName(orders[i]!.customer!)}',
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(orders[i]!.customer?.taxNumber != null
                  ? orders[i]!.customer?.taxNumber ?? ''
                  : '',
                  style: TextStyle(fontSize: 8)),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeight(orders[i]!))
                      : Global.format(orders[i]!.weight!),
                  style: TextStyle(fontSize: 8, color: PdfColors.blue600),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.priceIncludeTax ?? 0),
                  style: TextStyle(fontSize: 8, color: PdfColors.green600),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.purchasePrice ?? 0),
                  style: TextStyle(fontSize: 8, color: PdfColors.orange600),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.priceDiff ?? 0),
                  style: TextStyle(fontSize: 8, color: PdfColors.purple600),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.taxBase ?? 0),
                  style: TextStyle(fontSize: 8, color: PdfColors.teal600),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.taxAmount ?? 0),
                  style: TextStyle(fontSize: 8, color: PdfColors.red600),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.priceExcludeTax ?? 0),
                  style: TextStyle(fontSize: 8, color: PdfColors.indigo600),
                  align: TextAlign.right)
            ],
          ),
        // Summary row with clean styling
        TableRow(
            decoration: BoxDecoration(
              color: PdfColors.blue50,
              border: Border(
                top: BorderSide(color: PdfColors.blue200, width: 1),
              ),
            ),
            children: [
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              // paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('', style: const TextStyle(fontSize: 8)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800
                  )),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeightTotal(orders))
                      : Global.format(getWeightTotalB(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(purchasePriceTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.orange700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceDiffTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.purple700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxBaseTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.teal700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxAmountTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceExcludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.indigo700
                  ),
                  align: TextAlign.right),
            ]
        ),
      ],
    ),
  ));

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
        pageFormat: PdfPageFormat(
          PdfPageFormat.a4.height, // height becomes width
          PdfPageFormat.a4.width,  // width becomes height
        ),
        orientation: PageOrientation.landscape,
        build: (context) => widgets,
        footer: (context) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('* น้ําหนักจะเป็นน้ําหนักในหน่วยของทอง 96.5%'),
                Text('${context.pageNumber} / ${context.pagesCount}')
              ]);
        }),
  );
  return pdf.save();
}

Widget paddedTextSmall(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 9)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );