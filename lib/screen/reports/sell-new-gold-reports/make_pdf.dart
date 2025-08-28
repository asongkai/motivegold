import 'dart:typed_data';

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';

Future<Uint8List> makeNewGoldReportPdf(
    List<OrderModel?> orders, int type, String date) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  List<Widget> widgets = [];

  widgets.add(Center(
    child: Text(
      'รายงานขายทองรูปพรรณใหม่ 96.5%',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
    ),
  ));
  widgets.add(Center(
    child: Text(
      'ระหว่างวันที่ : $date',
      style: const TextStyle(decoration: TextDecoration.none, fontSize: 18),
    ),
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text("ชื่อผู้ประกอบการ : "),
            ),
            Expanded(
                flex: 6,
                child: Text('${Global.company!.name} (${Global.branch!.name})'))
          ],
        ),
      ),
      Expanded(
        child: Text(' ', textAlign: TextAlign.right),
      )
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text("ชชื่อสถานประกอบการ :"),
            ),
            Expanded(
                flex: 6,
                child: Text('${Global.company!.name} (${Global.branch!.name})'))
          ],
        ),
      ),
      Expanded(
        child: Text("เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber ?? ''}", textAlign: TextAlign.right),
      )
    ],
  ));
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text("ทีอยู่ : "),
            ),
            Expanded(
                flex: 6,
                child: Text(
                    '${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}'))
          ],
        ),
      ),
      Expanded(
        child: Text(
            'วันทีพิมพ์ ${Global.formatDate(DateTime.now().toString())} ',
            textAlign: TextAlign.right),
      )
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
        verticalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('เลขที่ใบกํากับภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('วันที่',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('เวลา',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('ชื่อผู้ซื้อ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  )
              ),
              paddedTextSmall('น้ําหนักรวม\n(กรัม)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ยอดขายรวม\nภาษีมูลค่าเพิม\nจำนวนเงิน (บาท)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('มูลค่าฐานภาษี\nยกเว้น\nจำนวนเงิน (บาท)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ผลต่าง\nรวมภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ฐานภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ภาษี\nมูลค่าเพิ่ม',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ยอดขายที่ไม่รวม\nภาษีมูลค่าเพิ่ม',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
            ]
        ),
        // Data rows with color coding
        for (int i = 0; i < orders.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: orders[i]!.status == "2" ? PdfColors.pink100 : PdfColors.white
            ),
            children: [
              paddedTextSmall('${i + 1}', style: TextStyle(
                  fontSize: 10,
                  color: orders[i]!.status == "2" ? PdfColors.red900 : null
              )),
              paddedTextSmall(orders[i]!.orderId, style: TextStyle(
                  fontSize: 10,
                  color: orders[i]!.status == "2" ? PdfColors.red900 : null
              )),
              paddedTextSmall(Global.dateOnly(orders[i]!.createdDate.toString()),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : null
                  )),
              paddedTextSmall(Global.timeOnlyF(orders[i]!.createdDate.toString()),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : null
                  )),
              paddedTextSmall('${getCustomerName(orders[i]!.customer!)}',
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : null
                  )),
              paddedTextSmall(orders[i]!.customer?.taxNumber != ''
                  ? orders[i]!.customer?.taxNumber ?? ''
                  : orders[i]!.customer?.idCard ?? '',
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : null
                  )),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeight(orders[i]!))
                      : Global.format(orders[i]!.weight!),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.blue600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.priceIncludeTax ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.green600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.purchasePrice ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.orange600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.priceDiff ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.purple600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.taxBase ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.teal600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.taxAmount ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.red600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(orders[i]!.priceExcludeTax ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.indigo600
                  ),
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
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('', style: const TextStyle(fontSize: 10)),
              paddedTextSmall('รวมท้ังหมด',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue800
                  )),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeightTotal(orders))
                      : Global.format(getWeightTotalB(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(purchasePriceTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.orange700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceDiffTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.purple700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxBaseTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.teal700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxAmountTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700
                  ),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceExcludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
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
      final TextStyle style = const TextStyle(fontSize: 11)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );