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
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  Widget buildHeader() {
    return Column(
      children: [
        reportsCompanyTitle(),
        Center(
          child: Text(
            'รายงานซื้อทองรูปพรรณใหม่ 96.5%',
            style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
          ),
        ),
        Center(
          child: Text(
            'ระหว่างวันที่ : $date',
            style: const TextStyle(decoration: TextDecoration.none, fontSize: 18),
          ),
        ),
        height(),
        reportsHeader(),
        height(h: 2),
      ],
    );
  }

  List<Widget> dataRows = [];
  // Apply modern design pattern
  dataRows.add(Container(
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
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              paddedTextSmall('ลำดับ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white), align: TextAlign.center),
              paddedTextSmall('เลขที่ใบกำกับภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ), align: TextAlign.center
              ),
              paddedTextSmall('เลขที่ใบรับทอง',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white), align: TextAlign.center),
              paddedTextSmall('วันที่',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white), align: TextAlign.center),

              paddedTextSmall('ชื่อผู้ขาย',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white), align: TextAlign.center),
              paddedTextSmall('เลขประจําตัว\nผู้เสียภาษี',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white), align: TextAlign.center),
              paddedTextSmall('น้ําหนักรวม\n(กรัม)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ราคาซื้อ\nไม่รวมภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
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
              paddedTextSmall('ผลต่างฐานภาษี\nจำนวนเงิน (บาท)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              // paddedTextSmall('ฐานภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
              //     style: TextStyle(
              //         fontSize: 11,
              //         fontWeight: FontWeight.bold,
              //         color: PdfColors.white
              //     ),
              //     align: TextAlign.center
              // ),
              paddedTextSmall('ภาษี\nมูลค่าเพิ่ม',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
              paddedTextSmall('ราคาซื้อ\nรวมภาษีมูลค่าเพิ่ม\nจำนวนเงิน (บาท)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.white
                  ),
                  align: TextAlign.center
              ),
            ]),
        // Data rows with color coding
        for (int i = 0; i < orders.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: orders[i]!.status == "2" ? PdfColors.red100 : PdfColors.white
            ),
            children: [
              paddedTextSmall('${i + 1}', style: TextStyle(
                  fontSize: 10,
                  color: orders[i]!.status == "2" ? PdfColors.red900 : null
              ), align: TextAlign.center),
              paddedTextSmall(orders[i]!.referenceNo ?? '',
                  style: TextStyle(fontSize: 10), align: TextAlign.center),
              paddedTextSmall(orders[i]!.orderId,
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : null
                  ), align: TextAlign.center),
              paddedTextSmall(
                  Global.dateOnly(orders[i]!.createdDate.toString()),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : null
                  ), align: TextAlign.center),

              paddedTextSmall('${orders[i]!.status == "2" ? "ยกเลิกเอกสาร" : getCustomerName(orders[i]!.customer!)}',
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : null
                  )),
              paddedTextSmall(orders[i]!.status == "2" ? "" :
                  orders[i]!.customer?.taxNumber != null
                      ? orders[i]!.customer?.taxNumber ?? ''
                      : '',
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : null
                  )),
              paddedTextSmall(orders[i]!.status == "2" ? "0.00" :
              type == 1
                      ? Global.format(getWeight(orders[i]!))
                      : Global.format(orders[i]!.weight!),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.blue600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format(orders[i]!.priceExcludeTax ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.green600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format(orders[i]!.purchasePrice ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.orange600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format(orders[i]!.taxBase ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.purple600
                  ),
                  align: TextAlign.right),
              // paddedTextSmall(Global.format(orders[i]!.taxBase ?? 0),
              //     style: TextStyle(
              //         fontSize: 10,
              //         color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.teal600
              //     ),
              //     align: TextAlign.right),
              paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format(orders[i]!.taxAmount ?? 0),
                  style: TextStyle(
                      fontSize: 10,
                      color: orders[i]!.status == "2" ? PdfColors.red900 : PdfColors.red600
                  ),
                  align: TextAlign.right),
              paddedTextSmall(orders[i]!.status == "2" ? "0.00" : Global.format(orders[i]!.priceIncludeTax ?? 0),
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
                      color: PdfColors.blue800)),
              paddedTextSmall(
                  type == 1
                      ? Global.format(getWeightTotal(orders))
                      : Global.format(getWeightTotalB(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.blue700),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceExcludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.green700),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(purchasePriceTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.orange700),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(taxBaseTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.purple700),
                  align: TextAlign.right),
              // paddedTextSmall(Global.format(taxBaseTotal(orders)),
              //     style: TextStyle(
              //         fontSize: 11,
              //         fontWeight: FontWeight.bold,
              //         color: PdfColors.teal700),
              //     align: TextAlign.right),
              paddedTextSmall(Global.format(taxAmountTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red700),
                  align: TextAlign.right),
              paddedTextSmall(Global.format(priceIncludeTaxTotal(orders)),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.indigo700),
                  align: TextAlign.right),
            ]),
      ],
    ),
  ));

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
        pageFormat: PdfPageFormat(
          PdfPageFormat.a4.height, // height becomes width
          PdfPageFormat.a4.width, // width becomes height
        ),
        orientation: PageOrientation.landscape,
        header: (context) => buildHeader(),
        build: (context) => dataRows,
        footer: (context) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('หมายเหตุ : น้ำหนักจะเป็นน้ำหนักในหน่วยของทอง 96.5% '),
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
