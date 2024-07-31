import 'dart:typed_data';

import 'package:motivegold/utils/helps/common_function.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/number_to_thai.dart';

Future<Uint8List> makeSellUsedGoldPdf(OrderModel sell) async {
  motivePrint(sell.toJson());
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
  int i = 0;
  pdf.addPage(
    MultiPage(
      maxPages: 100,
      margin: const EdgeInsets.all(20),
      pageFormat: const PdfPageFormat(600, 600),
      build: (context) {
        return [
          Column(
            children: [
              Center(
                  child: Column(children: [
                Text('${Global.company?.name} (${Global.branch!.name})',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                    '${Global.company?.address} ${Global.company?.village} ${Global.company?.district} ${Global.company?.province}',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
                Text(
                    ' โทร: ${Global.company?.phone}   เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber}',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
              ])),
              SizedBox(height: 10),
              Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'ใบส่งของ / ใบกำกับภาษี / ใบสำคัญรับเงิน',
                  style: const TextStyle(
                      decoration: TextDecoration.none, fontSize: 16),
                ),
              ),
              Container(height: 10),
              Container(
                  height: 20,
                  child: Row(children: [
                    Expanded(
                        child: Row(children: [
                      Expanded(flex: 1, child: Text('เลขที่')),
                      Expanded(
                          flex: 3,
                          child: Text(sell.orderId,
                              overflow: TextOverflow.visible)),
                    ])),
                    SizedBox(width: 10),
                    Expanded(
                        child: Row(children: [
                      Expanded(
                          flex: 6, child: Text('ราคาทองคำแท่งขายออกบาทละ')),
                      Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(Global.toNumber(Global.goldDataModel!.theng!.sell!))}',
                              textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text('บาท')),
                    ]))
                  ])),
              Container(
                  height: 20,
                  child: Row(children: [
                    Expanded(
                        child: Row(children: [
                      Expanded(flex: 1, child: Text('วันที่')),
                      Expanded(
                          flex: 3,
                          child: Text(Global.dateOnly(sell.orderDate.toString()),
                              overflow: TextOverflow.visible)),
                    ])),
                    SizedBox(width: 10),
                    Expanded(
                        child: Row(children: [
                      Expanded(flex: 6, child: Text('ทองคำแท่งซื้อเข้าบาทละ')),
                      Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(Global.toNumber(Global.goldDataModel!.theng!.buy!))}',
                              textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text('บาท')),
                    ]))
                  ])),
              Container(
                  height: 20,
                  child: Row(children: [
                    Expanded(
                        child: Row(children: [
                      Expanded(flex: 1, child: Text('ขายให้')),
                      Expanded(
                          flex: 3,
                          child: Text(
                              '${sell.customer!.firstName} ${sell.customer!.lastName}',
                              overflow: TextOverflow.visible)),
                    ])),
                    SizedBox(width: 10),
                    Expanded(
                        child: Row(children: [
                      Expanded(
                          flex: 6, child: Text('ทองรูปพรรณรับซื้อคืนบาทละ')),
                      Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(Global.toNumber(Global.goldDataModel!.paphun!.buy!))}',
                              textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text('บาท')),
                    ]))
                  ])),
              Container(
                  height: 20,
                  child: Row(children: [
                    Expanded(
                        child: Row(children: [
                      Expanded(flex: 1, child: Text('ที่อยู่')),
                      Expanded(
                          flex: 3,
                          child: Text(
                              '${sell.customer!.address} ${sell.customer!.district} ${sell.customer!.province}',
                              overflow: TextOverflow.visible)),
                    ])),
                    SizedBox(width: 10),
                    Expanded(
                        child: Row(children: [
                      Expanded(
                          flex: 6, child: Text('ทองรูปพรรณรับซื้อคืนกรัมละ')),
                      Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(Global.toNumber(Global.goldDataModel!.theng!.buy!) / 15.16)}',
                              textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text('บาท')),
                    ]))
                  ])),
              Container(
                  height: 20,
                  child: Row(children: [
                    Expanded(
                        child: Row(children: [
                      Expanded(flex: 1, child: Text(' ')),
                      Expanded(
                          flex: 3,
                          child: Text(' ', overflow: TextOverflow.visible)),
                    ])),
                    SizedBox(width: 10),
                    Expanded(
                        child: Row(children: [
                      Expanded(
                          flex: 6, child: Text('เลขที่ผู้เสียภาษีผู้รับซื้อ')),
                      Expanded(
                          flex: 3,
                          child: Text('${sell.customer!.taxNumber}',
                              textAlign: TextAlign.center)),
                    ]))
                  ])),
              Container(height: 10),
              Table(
                border: TableBorder.all(color: PdfColors.grey500, width: 0),
                children: [
                  TableRow(children: [
                    paddedText('ลำดับที่', align: TextAlign.center),
                    paddedText('รายการสินค้า', align: TextAlign.center),
                    paddedText('หน่วย (กรัม)', align: TextAlign.center),
                    paddedText('จำนวน (บาท)', align: TextAlign.center),
                  ]),
                  ...sell.details!.map((e) {
                    return TableRow(
                        decoration: const BoxDecoration(),
                        children: [
                          paddedText('${i + 1}', align: TextAlign.center),
                          paddedText(e.productName),
                          paddedText(
                            Global.format(e.weight ?? 0),
                            align: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          paddedText(
                            Global.format(e.priceIncludeTax ?? 0),
                            align: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                        ],
                      );}),
                  TableRow(children: [
                    paddedText(' ', align: TextAlign.center),
                    paddedText(' ', align: TextAlign.center),
                    paddedText('หักราคารับซื้อคืน', align: TextAlign.right),
                    paddedText('${Global.format(Global.getBuyPrice(sell.weight ?? 0))}', align: TextAlign.right),
                  ]),
                  TableRow(children: [
                    paddedText(' ', align: TextAlign.center),
                    paddedText(' ', align: TextAlign.center),
                    paddedText('ส่วนต่าง (ฐานภาษีมูลค่าเพิ่ม)', align: TextAlign.right),
                    paddedText('(${Global.format(sell.priceIncludeTax! - Global.getBuyPrice(sell.weight ?? 0))})', align: TextAlign.right, style: const TextStyle(color: PdfColors.red500)),
                  ]),
                  TableRow(children: [
                    paddedText(' ', align: TextAlign.center),
                    paddedText(' ', align: TextAlign.center),
                    paddedText('ภาษีมูลค่าเพิ่มร้อยละ 7', align: TextAlign.right),
                    paddedText('-', align: TextAlign.right),
                  ]),
                  TableRow(children: [
                    paddedText('', align: TextAlign.center),
                    paddedText(NumberToWordThai.convert(
                        sell.priceIncludeTax == null ? 0 : sell.priceIncludeTax!.toInt()), align: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    paddedText('รวมเป็นเงินสุทธิ', align: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    paddedText('${Global.format(sell.priceIncludeTax ?? 0)}', align: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
              Container(height: 10),
              Text("ข้าพเจ้ารับรองว่าข้าพเจ้าเป็นเจ้าของและมีกรรมสิทธิ์โดยชอบด้วยกฎหมายแต่เพียงผู้เดียวในทองคำที่นำมาขายให้กับบริษัท โดยปราศจากภาระผูกพันและการริดรอนสิทธิใดๆ ทั้งสิ้น ข้าพเจ้ายินยอมให้ผู้ซื้อ ซึ่งต่อไปนี้เรียกว่า “บริษัท” นำทองคำที่ส่ง มอบข้างต้นดำเนินการตรวจสอบคุณภาพตามวิธีการของผู้ซื้อ"),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("เงื่อนไขรับชำระเงิน"),
                  SizedBox(width: 20),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: PdfColors.grey500,
                        width: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text('เงืนสด'),
                  SizedBox(width: 5),
                  Text('/'),
                  SizedBox(width: 5),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: PdfColors.grey500,
                        width: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text('โอนเข้าบัญชีธนาคาร'),
                  SizedBox(width: 5),
                  Text('...................................................'),
                  SizedBox(width: 20),
                  Text('วันที่'),
                  Text('.......................'),
                ],
              ),
              Container(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("ลงชื่อ"),
                  SizedBox(width: 20),
                  Text('...................................................'),
                  SizedBox(width: 5),
                  Text('('),
                  SizedBox(width: 173),
                  Text(')'),
                  SizedBox(width: 20),
                  Text('ผู้ซื้อ/ผู้รับสินค้า'),
                ],
              ),
              Container(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("ลงชื่อ"),
                  SizedBox(width: 20),
                  Text('...................................................'),
                  SizedBox(width: 5),
                  Text('('),
                  SizedBox(width: 5),
                  Text('นายกฤษฎา โอสถาพงษ์กาญจน์'),
                  SizedBox(width: 5),
                  Text(')'),
                  SizedBox(width: 20),
                  Text('ผู้ซื้อ/ผู้รับสินค้า'),
                ],
              ),
              SizedBox(height: 10),
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
      padding: const EdgeInsets.all(6),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );
