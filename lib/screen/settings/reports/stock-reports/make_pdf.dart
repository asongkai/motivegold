import 'dart:typed_data';

import 'package:motivegold/model/qty_location.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';

Future<Uint8List> makeStockReportPdf(List<QtyLocationModel> list,int type) async {
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
  pdf.addPage(
    MultiPage(
      maxPages: 100,
      margin: const EdgeInsets.all(20),
      pageFormat: const PdfPageFormat(700, 700),
      build: (context) {
        return [
          Column(
            children: [
              Center(
                  child: Column(children: [
                Text('${Global.company?.name}'),
                Text('(${Global.branch!.name})'),
                //   Text('(สํานักงานใหญ่)'),
                //   Text('${Global.company?.name}'),
                Text(
                    '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
                //   Text('${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
                Text('เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber}'),
                Text('TAX : INVOICE [ABB]/RECEIPT VAT INCLUDED)'),
                Text('POS Reg. No : '),
              ])),
              SizedBox(height: 10),
              Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
              Center(
                child: Text(
                  'รายงานสต็อก',
                  style: const TextStyle(
                      decoration: TextDecoration.none, fontSize: 20),
                ),
              ),
              Container(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ชื่อผู้ประกอบการ ${Global.branch!.name}"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ชื่อสถานประกอบการ ${Global.company!.name}"),
                  Text('ลําดับเลขที่สาขา ${Global.branch!.branchId}'),
                ],
              ),
              Container(height: 10),
              Table(
                border: TableBorder.all(color: PdfColors.grey500),
                children: [
                  TableRow(children: [
                    paddedTextBigXL('สินค้า'),
                    paddedTextBigXL('คลังสินค้า'),
                    paddedTextBigXL('น้ำหนักรวม'),
                    paddedTextBigXL('ราคาต่อหน่วย'),
                    paddedTextBigXL('ราคารวม'),
                  ]),
                  ...list.map((e) => TableRow(
                    decoration: const BoxDecoration(),
                    children: [
                      paddedTextBigXL(
                          e.product == null ? "" : e.product!.name),
                      paddedTextBigXL(e.binLocation == null
                          ? ""
                          : e.binLocation!.name),
                      paddedTextBigXL(Global.format(e.weight ?? 0),
                          style: const TextStyle(fontSize: 18),
                          align: TextAlign.right),
                      paddedTextBigXL(
                          Global.format(
                              Global.getBuyPrice(e.weight ?? 0) /
                                  e.weight!),
                          style: const TextStyle(fontSize: 18),
                          align: TextAlign.right),
                      paddedTextBigXL(
                          Global.format(
                              Global.getBuyPrice(e.weight ?? 0)),
                          style: const TextStyle(fontSize: 18),
                          align: TextAlign.right),
                    ],
                  )),
                  // TableRow(children: [
                  //   paddedTextBigXL('', style: const TextStyle(fontSize: 14)),
                  //   paddedTextBigXL(''),
                  //   paddedTextBigXL(''),
                  //   paddedTextBigXL('รวมท้ังหมด'),
                  //   paddedTextBigXL(Global.format(getWeightTotal(ods))),
                  //   paddedTextBigXL(''),
                  //   paddedTextBigXL(Global.format(priceIncludeTaxTotal(ods))),
                  //   paddedTextBigXL(Global.format(purchasePriceTotal(ods))),
                  //   paddedTextBigXL(Global.format(priceDiffTotal(ods))),
                  //   paddedTextBigXL(Global.format(taxBaseTotal(ods))),
                  //   paddedTextBigXL(Global.format(taxAmountTotal(ods))),
                  //   paddedTextBigXL(Global.format(priceExcludeTaxTotal(ods))),
                  // ])
                ],
              ),
              SizedBox(height: 10),
              Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  paddedText('ผู้ตรวจสอบ/Authorize',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  paddedText('ผู้อนุมัติ/Approve',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Divider(
                      height: 1,
                      borderStyle: BorderStyle.dashed,
                    ),
                  ),
                  SizedBox(width: 80),
                  Expanded(
                    child: Divider(
                      height: 1,
                      borderStyle: BorderStyle.dashed,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('('),
                  Expanded(
                    child: Divider(
                      height: 1,
                      borderStyle: BorderStyle.dashed,
                    ),
                  ),
                  Text(')'),
                  SizedBox(width: 80),
                  Text('('),
                  Expanded(
                    child: Divider(
                      height: 1,
                      borderStyle: BorderStyle.dashed,
                    ),
                  ),
                  Text(')'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('วันที่ : ${DateTime.now()}'),
                  Spacer(),
                  Text('วันที่ : ${DateTime.now()}')
                ],
              ),
              SizedBox(height: 10),
              Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
              SizedBox(height: 10),
              Text(
                "ตราประทับ",
                style: Theme.of(context).header2,
              ),
              SizedBox(height: 100),
              Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
            ],
          )
        ];
      },
    ),
  );
  return pdf.save();
}

Widget paddedText(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 12)}) =>
    Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );

Widget paddedTextBigXL(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 16)}) =>
    Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );