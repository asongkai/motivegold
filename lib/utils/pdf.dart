import 'dart:typed_data';

import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/utils/util.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

import '../model/invoice.dart';
import 'global.dart';
import 'number_to_thai.dart';

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
      build: (context) {
        return [
          Column(
            children: [
              Center(
                  child: Column(children: [
                Text('${Global.company?.name}'),
                Text('(สํานักงานใหม่)'),
                Text('${Global.company?.name}'),
                Text('${Global.company?.address}'),
                Text('${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
                Text('เลขประจําตัวผู้เสียภาษี: ${Global.company?.taxNumber}'),
                Text('TAX INVOCIE / Recept VAT INICLUDED)'),
                Text('Reg No :'),
                Text('ใบเสร็จรับเงิน/ใบกํากับภาษี/ใบส่งของ (สําเนา)'),
                Text(
                    'วันที่ : ${DateTime.now()} เลขที่: ${invoice.order.orderId}'),
                Text(
                    'ชื่อผู้ซื้อ: ${invoice.customer.firstName} ${invoice.customer.lastName}'),
                Text('เลขประจําตัวผู้เสียภาษี : 1234567890123'),
                Text(
                    'ที่อยู่ : ${invoice.customer.address}, ${invoice.customer.district}, ${invoice.customer.province}'),
              ])),
              SizedBox(height: 10),
              Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ราคาทองคําแห่งขายออก"),
                  Text('${Global.goldDataModel!.theng!.sell}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ราคารูบพรรมรับซื้อคืนต่อกรัม"),
                  Text(formatter.format(Global.bathPerGram().toPrecision(2))),
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
                  Text('ทองคํารูปพรรม 96.5%'),
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
                          paddedText(formatter.format(e.weight!),
                              align: TextAlign.center,
                              style: const TextStyle(fontSize: 18)),
                          paddedText(formatter.format(e.priceIncludeTax),
                              align: TextAlign.center,
                              style: const TextStyle(fontSize: 18)),
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
                  Text(formatter.format(Global.getOrderTotal(invoice.order)))
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
                  Text('ราคาสินค้า(รวมภาษีมูลค่าเพิ่ม)'),
                  Text(formatter.format(Global.getOrderTotal(invoice.order))),
                ],
              ),
              if (invoice.order.orderTypeId == 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('หัก ราคารับซื้อคืนทองรูปพรรณ'),
                  Text(formatter.format(Global.getPapunTotal(invoice.order))),
                ],
              ),
              if (invoice.order.orderTypeId == 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ผลต่างราคา'),
                  Text(formatter.format(Global.getOrderTotal(invoice.order) -
                      Global.getPapunTotal(invoice.order))),
                ],
              ),
              if (invoice.order.orderTypeId == 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('มูลค่าฐานภาษีมูลค่าเพิ่ม'),
                  Text(formatter.format((Global.getOrderTotal(invoice.order) -
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
                  Text(formatter.format(((Global.getOrderTotal(invoice.order) -
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
                  Text(formatter.format(Global.getOrderTotal(invoice.order) -
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
                  Text(formatter.format(invoice.order.discount!),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('จำนวนเงินที่ต้องชำระ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(formatter.format(Global.getOrderTotal(invoice.order) - invoice.order.discount!),
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
                  paddedText('ผู้ส่งสินค้า/DelIvered By',
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
                  Text('วันที่ : ${DateTime.now()}'),
                  Spacer(),
                  Text('วันที่ : ${DateTime.now()}')
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
