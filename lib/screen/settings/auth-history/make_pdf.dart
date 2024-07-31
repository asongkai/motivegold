import 'dart:typed_data';

import 'package:motivegold/model/auth_log.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';

Future<Uint8List> makeAuthLogPdf(List<AuthLogModel> invoice) async {
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

  // motivePrint(authLogListModelToJson(invoice));

  pdf.addPage(
    MultiPage(
        margin: const EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.portrait,
        maxPages: 100,
        build: (context) {
          return [
            Center(
                child: Column(children: [
              Text('${Global.company?.name} (${Global.branch!.name})',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(
                  '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(
                  'เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber} โทร ${Global.company?.phone}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ])),
            SizedBox(height: 10),
            Divider(
              height: 1,
              borderStyle: BorderStyle.dashed,
            ),
            Table(
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
                                  Text('Type: ${e.type!.toUpperCase()}', style: const TextStyle(fontSize: 9),),
                                  Text('User ID: ${e.user?.id!}', style: const TextStyle(fontSize: 9),),
                                  Text('Username: ${e.user?.username!}', style: const TextStyle(fontSize: 9),),
                                  Text(
                                    'Date: ${Global.formatDate(e.date.toString())}', style: const TextStyle(fontSize: 9),
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
            )
          ];
        },
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
        final TextStyle style = const TextStyle(fontSize: 9)}) =>
    Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );
