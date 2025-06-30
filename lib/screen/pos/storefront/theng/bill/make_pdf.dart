import 'dart:typed_data';

import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/utils/classes/number_to_thai_words.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> makeThengPdf(Invoice invoice) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);

  List<Widget> widgets = [];
  widgets.add(await header(invoice.order, ' ใบเสร็จรับเงิน / ใบส่งของ'),);
  widgets.add(height());
  widgets.add(buyerSellerInfo(invoice.customer, invoice.order),);
  widgets.add(height());
  widgets.add(divider());
  widgets.add(height());
  widgets.add(getThongThengTable(invoice.order),);
  widgets.add(height());
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        flex: 6,
        child: Center(
          child: Text(
            '( ${NumberToThaiWords.convertDouble(Global.getOrderTotal(invoice.order))} )',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      Expanded(
          flex: 4,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'รวมทั้งสิ้น',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 60),
                Text(
                  Global.format(
                    Global.getOrderTotal(invoice.order),
                  ),
                ),
                SizedBox(width: 10),
              ])),
    ],
  ),);
  widgets.add(height());
  widgets.add(divider());
  widgets.add(height(h: 1));
  widgets.add(divider());
  widgets.add(height());
  widgets.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text('เงื่อนไขการการชำระเงิน',
        style:
        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    Spacer(),
    Text(
        'ใบเสร็จรับเงินนี้จะสมบูรณ์ต่อเมื่อ  บริษัทฯได้รับเงินอย่างครบถ้วน')
  ]),);
  widgets.add(getThongThengPaymentInfo(invoice.order, invoice.payments ?? []),);
  widgets.add(height());
  widgets.add(getThongThengSignatureInfo(invoice.customer, invoice.order.orderTypeId!),);
  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(40),
      pageFormat: PdfPageFormat.a4,
      build: (context) => widgets,
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
