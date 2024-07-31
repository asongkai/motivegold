import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/model/stockmovement.dart';
import 'package:motivegold/utils/global.dart';

Future<Uint8List> makeStockMovementReportPdf(List<StockMovementModel> list,int type) async {
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
      pageFormat: const PdfPageFormat(1000, 1000),
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
                  'รายงานความเคลื่อนไหวสต๊อกสินค้า',
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
                    paddedTextBig('เลขที่ใบ\nกํากับภาษ'),
                    paddedTextBig('วัน/เดือน/ปี'),
                    paddedTextBig('สินค้า'),
                    paddedTextBig('คลังสินค้า'),
                    paddedTextBig('ประเภท\nการเคลื่อนไหว'),
                    paddedTextBig('ประเภท\nเอกสาร'),
                    paddedTextBig('น้ำหนักรวม'),
                    paddedTextBig('ราคา\nต่อหน่วย'),
                    paddedTextBig('ราคารวม'),
                  ]),
                  ...list.map((e) => TableRow(
                    decoration: const BoxDecoration(),
                    children: [
                      paddedTextBig(e.orderId!),
                      paddedTextBig(Global.dateOnly(e.createdDate.toString())),
                      paddedTextBig(
                          e.product == null ? "" : e.product!.name),
                      paddedTextBig(e.binLocation == null
                          ? ""
                          : e.binLocation!.name),
                      paddedTextBig('${e.type!} '),
                      paddedTextBig('${e.docType!} '),
                      paddedTextBig(' ${Global.format(e.weight ?? 0)}',
                          style: const TextStyle(fontSize: 16),
                          align: TextAlign.right),
                      paddedTextBig(' ${Global.format(
                          Global.getBuyPrice(e.weight ?? 0) /
                              e.weight!)}',
                          style: const TextStyle(fontSize: 16),
                          align: TextAlign.right),
                      paddedTextBig(' ${Global.format(
                          Global.getBuyPrice(e.weight ?? 0))}'
                          ,
                          style: const TextStyle(fontSize: 16),
                          align: TextAlign.right),
                    ],
                  )),
                  // TableRow(children: [
                  //   paddedTextBig('', style: const TextStyle(fontSize: 14)),
                  //   paddedTextBig(''),
                  //   paddedTextBig(''),
                  //   paddedTextBig('รวมท้ังหมด'),
                  //   paddedTextBig(Global.format(getWeightTotal(ods))),
                  //   paddedTextBig(''),
                  //   paddedTextBig(Global.format(priceIncludeTaxTotal(ods))),
                  //   paddedTextBig(Global.format(purchasePriceTotal(ods))),
                  //   paddedTextBig(Global.format(priceDiffTotal(ods))),
                  //   paddedTextBig(Global.format(taxBaseTotal(ods))),
                  //   paddedTextBig(Global.format(taxAmountTotal(ods))),
                  //   paddedTextBig(Global.format(priceExcludeTaxTotal(ods))),
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

Widget paddedTextBig(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 14)}) =>
    Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );