import 'dart:typed_data';

import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/number_to_thai.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;


Future<Uint8List> makePdf(Invoice invoice) async {
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
      pageFormat: const PdfPageFormat(600, 600),
      build: (context) {
        return [
          Column(
            children: [
              header(invoice.order, 'TAX : INVOICE [ABB]/RECEIPT VAT INCLUDED)'),
              SizedBox(height: 10),
              buyerSellerInfo(invoice.customer, invoice.order),
              SizedBox(height: 10),
              Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ราคาทองคําแท่งขายออก"),
                  Text('${Global.goldDataModel!.theng!.sell}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ราคาทองรูปพรรณรับซื้อคืนต่อกรัม"),
                  Text(Global.format(Global.bathPerGram())),
                ],
              ),
              Container(height: 10),
              Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
              Container(height: 10),
              Center(
                child: Text(
                  'รายการสินค้า',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ทองคํารูปพรรณ 96.5%'),
                  Spacer(),
                ],
              ),
              Container(height: 10),
              Table(
                border: TableBorder.all(color: PdfColors.grey500),
                children: [
                  ...invoice.items.map((e) => TableRow(
                    decoration: const BoxDecoration(),
                    children: [
                      paddedText(e.productName),
                      paddedText(Global.format(e.weight!),
                        align: TextAlign.center,),
                      paddedText(Global.format(e.priceIncludeTax!),
                        align: TextAlign.center,),
                    ],
                  )),
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
                  Text('รวมจํานวนเงิน'),
                  Text(Global.format(Global.getOrderTotal(invoice.order)))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ตัวอักษร'),
                  Text(NumberToWordThai.convert(
                      Global.getOrderTotal(invoice.order).toInt()))
                ],
              ),
              SizedBox(height: 10),
              Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
              if (invoice.order.orderTypeId == 1)
                SizedBox(height: 10),
              if (invoice.order.orderTypeId == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ราคาสินค้า (รวมภาษีมูลค่าเพิ่ม)'),
                    Text(Global.format(Global.getOrderTotal(invoice.order))),
                  ],
                ),
              if (invoice.order.orderTypeId == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('หักราคารับซื้อคืนทองรูปพรรณ'),
                    Text(Global.format(Global.getPapunTotal(invoice.order))),
                  ],
                ),
              if (invoice.order.orderTypeId == 4 || invoice.order.orderTypeId == 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('หักราคารับซื้อคืนทองคําแท่ง'),
                    Text(Global.format(Global.getThengTotal(invoice.order))),
                  ],
                ),
              if (invoice.order.orderTypeId == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ผลต่างราคา'),
                    Text(Global.format(Global.getOrderTotal(invoice.order) -
                        Global.getPapunTotal(invoice.order))),
                  ],
                ),
              if (invoice.order.orderTypeId == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('มูลค่าฐานภาษีมูลค่าเพิ่ม'),
                    Text(Global.format((Global.getOrderTotal(invoice.order) -
                        Global.getPapunTotal(invoice.order)) *
                        100 /
                        107)),
                  ],
                ),
              if (invoice.order.orderTypeId == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ภาษีมูลค่าเพิ่ม'),
                    Text(Global.format(((Global.getOrderTotal(invoice.order) -
                        Global.getPapunTotal(invoice.order)) *
                        100 /
                        107) *
                        0.07)),
                  ],
                ),
              if (invoice.order.orderTypeId == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('มูลค่าสินค้าไม่รวมภาษีมูลค่าเพิ่ม'),
                    Text(Global.format(Global.getOrderTotal(invoice.order) -
                        (((Global.getOrderTotal(invoice.order) -
                            Global.getPapunTotal(invoice.order)) *
                            100 /
                            107) *
                            0.07))),
                  ],
                ),
              if (invoice.order.orderTypeId == 1)
                SizedBox(height: 10),
              if (invoice.order.orderTypeId == 1)
                Divider(
                  height: 1,
                  borderStyle: BorderStyle.dashed,
                ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ส่วนลด',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(Global.format(invoice.order.discount!),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('จำนวนเงินที่ต้องชำระ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(Global.format(Global.getOrderTotal(invoice.order) - invoice.order.discount!),
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                  paddedText('ผู้รับสินค้า/Receiver',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  paddedText('ผู้ส่งสินค้า/Delivered By',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),
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
                  Text('วันที่ : ${Global.formatDate(DateTime.now().toString())}'),
                  Spacer(),
                  Text('วันที่ : ${Global.formatDate(DateTime.now().toString())}')
                ],
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
                  Text('วันที่ : ${Global.formatDate(DateTime.now().toString())}'),
                  Spacer(),
                  Text('วันที่ : ${Global.formatDate(DateTime.now().toString())}')
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
                  borderStyle: BorderStyle.dashed,),
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
