import 'dart:typed_data';

import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/number_to_thai.dart';

Future<Uint8List> makeRefillGoldPdf(OrderModel sell) async {
  motivePrint(sell.toJson());
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);
  int i = 0;
  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(40),
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return [
          Column(
            children: [
              headerRefill(sell.customer!, sell,
                  'ใบกำกับภาษี / ใบ้แจ้งหนี้ / ใบส่งสินค้า'),
              height(),
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
                              '${Global.format(sell.sellTPrice ?? 0)}',
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
                          child: Text(
                              Global.dateOnly(sell.orderDate.toString()),
                              overflow: TextOverflow.visible)),
                    ])),
                    SizedBox(width: 10),
                    Expanded(
                        child: Row(children: [
                      Expanded(flex: 6, child: Text('ทองคำแท่งซื้อเข้าบาทละ')),
                      Expanded(
                          flex: 2,
                          child: Text(
                              '${Global.format(sell.buyTPrice ?? 0)}',
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
                              '${Global.format(sell.buyPrice ?? 0)}',
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
                              '${sell.customer!.address} ${sell.customer!.amphureId} ${sell.customer!.provinceId}',
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
                              '${Global.format((sell.buyPrice ?? 0) / 15.16)}',
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
                        paddedText(Global.format(e.weight ?? 0),
                            align: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        paddedText(Global.format(e.priceIncludeTax ?? 0),
                            align: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    );
                  }),
                  TableRow(children: [
                    paddedText(' ', align: TextAlign.center),
                    paddedText(' ', align: TextAlign.center),
                    paddedText('ราคาสินค้ารวมค่ากำเหน็ดก่อนภาษี',
                        align: TextAlign.right),
                    paddedText(
                        '${Global.format(sell.priceExcludeTax ?? 0)}',
                        align: TextAlign.right),
                  ]),
                  TableRow(children: [
                    paddedText(' ', align: TextAlign.center),
                    paddedText(' ', align: TextAlign.center),
                    paddedText('ส่วนลด', align: TextAlign.right),
                    paddedText('${Global.format(sell.discount ?? 0)}',
                        align: TextAlign.right),
                  ]),
                  TableRow(children: [
                    paddedText(' ', align: TextAlign.center),
                    paddedText(' ', align: TextAlign.center),
                    paddedText('หักราคารับซื้อทองประจำวัน',
                        align: TextAlign.right),
                    paddedText(
                        '${Global.format(sell.buyPrice! * sell.details![0].weight! / 15.16)}',
                        align: TextAlign.right),
                  ]),
                  TableRow(children: [
                    paddedText(' ', align: TextAlign.center),
                    paddedText(' ', align: TextAlign.center),
                    paddedText('จำนวนส่วนต่างฐานภาษี', align: TextAlign.right),
                    paddedText(
                        '(${Global.format(sell.priceDiff ?? 0)})',
                        align: TextAlign.right,
                        style: TextStyle(
                            color: sell.taxBase! <
                                    0
                                ? PdfColors.red500
                                : null)),
                  ]),
                  TableRow(children: [
                    paddedText(' ', align: TextAlign.center),
                    paddedText(' ', align: TextAlign.center),
                    paddedText('ภาษีมูลค่าเพิ่ม', align: TextAlign.right),
                    paddedText('${Global.format(sell.taxAmount ?? 0)}',
                        align: TextAlign.right),
                  ]),
                  TableRow(children: [
                    paddedText('', align: TextAlign.center),
                    paddedText(
                        '( ${NumberToWordThai.convert(sell.priceIncludeTax == null ? 0 : sell.priceIncludeTax!.toInt())} )',
                        align: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    paddedText('ราคาสินค้ารวมภาษีมูลค่าเพิ่ม',
                        align: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    paddedText('${Global.format(sell.priceIncludeTax ?? 0)}',
                        align: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
              Container(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('หมายเหตุ: ',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
              Text(
                  "สินค้าตามรายการข้างต้นนี้แม้จะได้รับส่งมอบแก่ผู้ซื้อแล้ว แต่ก็ยังคงเป็นทรัพย์สินของผู้ขายอยู่ จนกว่าผู้ขายจะได้เรียกเก็บเงินจากธนาคารได้เรียบร้อยแล้วเท่านั้น"),
              height(),
              divider(),
              height(),
              Row(children: [
                SizedBox(width: 30),
                Expanded(
                    child: Text(
                        'ได้รับสินค้าข้างต้นครบถ้วนถูกต้องเรียบร้อยแล้ว และได้รับต้นฉบับใบกำกับภาษี พร้อมยอมรับข้อตกลงตามใบกำกับสินค้านี้')),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Container()),
                  Text('วันที่'),
                  Text('.......................'),
                ],
              ),
              Container(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    child: Text("ลงชื่อ"),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                        '${sell.customer?.firstName} ${sell.customer?.lastName}'),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                      flex: 3,
                      child: Row(children: [
                        Text('('),
                        SizedBox(width: 5),
                        Expanded(child: Text(' ', textAlign: TextAlign.center)),
                        SizedBox(width: 5),
                        Text(')'),
                      ])),
                  SizedBox(width: 20),
                  Expanded(
                      flex: 2,
                      child: Text('ผู้ซื้อ/ผู้รับสินค้า',
                          textAlign: TextAlign.right)),
                ],
              ),
              Container(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    child: Text("ลงชื่อ"),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text('${Global.company?.name}'),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                      flex: 3,
                      child: Row(children: [
                        Text('('),
                        SizedBox(width: 5),
                        Expanded(
                            child: Text(
                                '${Global.user?.firstName} ${Global.user?.lastName}',
                                textAlign: TextAlign.center)),
                        SizedBox(width: 5),
                        Text(')'),
                      ])),
                  SizedBox(width: 20),
                  Expanded(
                      flex: 2,
                      child: Text('ผู้ส่ง', textAlign: TextAlign.right)),
                ],
              ),
              height(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    child: Text("ลงชื่อ"),
                  ),
                  Expanded(flex: 4,
                    child: Text(' '),
                  ),
                  SizedBox(width: 5),
                  Expanded(flex: 3,
                      child: Row(children: [
                    Text('('),
                    Expanded(child: SizedBox(width: 5)),
                    Text(' '),
                    SizedBox(width: 5),
                    Text(')'),
                  ])),
                  SizedBox(width: 20),
                  Expanded(flex: 2,
                      child:
                          Text('ผู้มีอำนาจลงนาม', textAlign: TextAlign.right)),
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
