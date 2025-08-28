import 'dart:typed_data';

import 'package:motivegold/model/auth_log.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';

Future<Uint8List> makeAuthLogPdf(List<AuthLogModel> invoice) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);
  // final imageLogo = MemoryImage(
  //     (await rootBundle.load('assets/images/logo.png'))
  //         .buffer
  //         .asUint8List());
  // var data =
  //     await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf");
  // var font = Font.ttf(data);

  // motivePrint(authLogListModelToJson(invoice));
  List<Widget> widgets = [];

  widgets.add(Center(
      child: Column(children: [
    Text('${Global.company?.name} (${Global.branch!.name})',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    Text(
        '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    Text(
        'เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber} โทร ${Global.company?.phone}',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  ])));
  widgets.add(height());
  widgets.add(divider());
  widgets.add(Table(
    border: TableBorder.all(color: PdfColors.grey500),
    children: [
      ...invoice.map((e) => TableRow(
            decoration: const BoxDecoration(),
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type: ${e.type!.toUpperCase()}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          'User ID: ${e.user?.id!}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Username: ${e.user?.username!}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Date: ${Global.formatDate(e.date.toString())}',
                          style: const TextStyle(fontSize: 11),
                        )
                      ]),
                  padding: const EdgeInsets.all(10),
                ),
              ),
              Expanded(
                flex: 6,
                child: paddedText(
                  e.deviceDetail == null ? '' : e.deviceDetail!.toString(),
                  align: TextAlign.center,
                  style: const TextStyle(fontSize: 7),
                ),
              ),
            ],
          )),
    ],
  ));
  widgets.add(height());
  widgets.add(divider());
  widgets.add(height());
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      paddedText('ผู้ตรวจสอบ/Authorize',
          style: TextStyle(fontWeight: FontWeight.bold)),
      paddedText('ผู้อนุมัติ/Approve',
          style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  ));
  widgets.add(Row(
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
  ));
  widgets.add(height());
  widgets.add(Row(
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
  ));
  widgets.add(height());
  widgets.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('วันที่ : ${DateTime.now()}'),
      Spacer(),
      Text('วันที่ : ${DateTime.now()}')
    ],
  ));
  widgets.add(height());
  widgets.add(divider());
  widgets.add(height());
  widgets.add(Center(
      child: Text(
    "ตราประทับ",
    style: const TextStyle(fontSize: 30),
  )));
  widgets.add(height(h: 100));
  widgets.add(divider());

  pdf.addPage(
    MultiPage(
        maxPages: 10000,
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
                Container(),
                Text('${context.pageNumber} / ${context.pagesCount}')
              ]);
        }),
  );
  return pdf.save();
}

Widget paddedText(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 11)}) =>
    Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );
