import 'dart:typed_data';

import 'package:motivegold/model/auth_log.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';

Future<Uint8List> makeAuthLogPdf(
    List<AuthLogModel> authLogs, String filterInfo) async {
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
            'ประวัติการเข้าใช้ระบบ',
            style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        if (filterInfo.isNotEmpty)
          Center(
            child: Text(
              filterInfo,
              style: const TextStyle(
                  decoration: TextDecoration.none, fontSize: 18),
            ),
          ),
        height(),
        reportsHeader(),
        height(h: 2),
        // Table column headers
        Table(
          border: TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            0: const FixedColumnWidth(60),  // วันที่
            1: const FixedColumnWidth(40),  // เวลา
            2: const FixedColumnWidth(50),  // ประเภท
            3: const FixedColumnWidth(60),  // User ID
            4: const FixedColumnWidth(80),  // Username
            5: const FixedColumnWidth(180), // รายละเอียดอุปกรณ์
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: PdfColors.white),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedText('วันที่',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black)),
                paddedText('เวลา',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black)),
                paddedText('ประเภท',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black)),
                paddedText('User ID',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black)),
                paddedText('Username',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black)),
                paddedText('รายละเอียดอุปกรณ์',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Create list for data rows
  List<Widget> dataRows = [];

  for (int i = 0; i < authLogs.length; i++) {
    dataRows.add(Container(
      child: Table(
        border: TableBorder.all(color: PdfColors.grey400, width: 0.5),
        columnWidths: {
          0: const FixedColumnWidth(60),  // วันที่
          1: const FixedColumnWidth(40),  // เวลา
          2: const FixedColumnWidth(50),  // ประเภท
          3: const FixedColumnWidth(60),  // User ID
          4: const FixedColumnWidth(80),  // Username
          5: const FixedColumnWidth(180), // รายละเอียดอุปกรณ์
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: i % 2 == 0 ? PdfColors.white : PdfColors.grey100),
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              paddedText(
                  authLogs[i].date != null
                      ? Global.formatDateDD(authLogs[i].date.toString())
                      : '',
                  style: const TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedText(
                  authLogs[i].date != null
                      ? Global.timeOnly(authLogs[i].date.toString())
                      : '',
                  style: const TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedText(authLogs[i].type?.toUpperCase() ?? '',
                  style: const TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedText('${authLogs[i].user?.id ?? ''}',
                  style: const TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedText(authLogs[i].user?.username ?? '',
                  style: const TextStyle(fontSize: 10),
                  align: TextAlign.left),
              paddedText(
                  authLogs[i].deviceDetail != null &&
                          authLogs[i].deviceDetail!.isNotEmpty
                      ? authLogs[i].deviceDetail!
                      : '-',
                  style: const TextStyle(fontSize: 8),
                  align: TextAlign.left),
            ],
          ),
        ],
      ),
    ));
  }

  pdf.addPage(
    MultiPage(
      maxPages: 10000,
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
            Container(),
            Text('${context.pageNumber} / ${context.pagesCount}')
          ],
        );
      },
    ),
  );
  return pdf.save();
}
