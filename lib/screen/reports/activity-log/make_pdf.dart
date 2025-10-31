import 'dart:typed_data';

import 'package:motivegold/model/activity_log.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:motivegold/utils/global.dart';

Future<Uint8List> makeActivityLogPdf(
    List<ActivityLogModel> activities, String dateRange) async {
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
            'รายงานกิจกรรมย้อนหลัง',
            style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        if (dateRange.isNotEmpty)
          Center(
            child: Text(
              dateRange,
              style: const TextStyle(
                  decoration: TextDecoration.none, fontSize: 18),
            ),
          ),
        height(),
        reportsHeader(),
        height(h: 2),
        // Table column headers
        Table(
          border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
          columnWidths: {
            0: const FixedColumnWidth(50), // วันที่
            1: const FixedColumnWidth(40), // เวลา
            2: const FixedColumnWidth(70), // ผู้ใช้
            3: const FixedColumnWidth(60), // ลักษณะ
            4: const FixedColumnWidth(200), // รายละเอียด
            5: const FixedColumnWidth(50), // ผลลัพธ์
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: PdfColors.blue600),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedText('วันที่',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                paddedText('เวลา',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                paddedText('ผู้ใช้',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                paddedText('ลักษณะ',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                paddedText('รายละเอียด',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
                paddedText('ผลลัพธ์',
                    align: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Create list for data rows
  List<Widget> dataRows = [];

  // Build data table
  dataRows.add(Container(
    decoration: BoxDecoration(
      border: Border.all(color: PdfColors.grey300, width: 1),
    ),
    child: Table(
      border: TableBorder(
        top: BorderSide.none,
        bottom: BorderSide.none,
        left: BorderSide.none,
        right: BorderSide.none,
        horizontalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
        verticalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
      ),
      columnWidths: {
        0: const FixedColumnWidth(50), // วันที่
        1: const FixedColumnWidth(40), // เวลา
        2: const FixedColumnWidth(70), // ผู้ใช้
        3: const FixedColumnWidth(60), // ลักษณะ
        4: const FixedColumnWidth(200), // รายละเอียด
        5: const FixedColumnWidth(50), // ผลลัพธ์
      },
      children: [
        // Data rows
        for (int i = 0; i < activities.length; i++)
          TableRow(
            verticalAlignment: TableCellVerticalAlignment.middle,
            decoration: const BoxDecoration(color: PdfColors.white),
            children: [
              paddedText(
                  activities[i].actionDate != null
                      ? Global.dateOnly(activities[i].actionDate.toString())
                      : '',
                  style: const TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedText(
                  activities[i].actionDate != null
                      ? Global.timeOnly(activities[i].actionDate.toString())
                      : '',
                  style: const TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedText(
                  activities[i].userDisplayName ?? activities[i].userId ?? '',
                  style: const TextStyle(fontSize: 10),
                  align: TextAlign.left),
              paddedText(activities[i].actionType ?? '',
                  style: const TextStyle(fontSize: 10),
                  align: TextAlign.center),
              paddedText(
                  '${activities[i].screenName ?? ''}\n${activities[i].description ?? ''}',
                  style: const TextStyle(fontSize: 9),
                  align: TextAlign.left),
              paddedText(activities[i].result ?? '',
                  style: TextStyle(
                      fontSize: 10,
                      color: activities[i].result == 'SUCCESS'
                          ? PdfColors.green700
                          : PdfColors.red700),
                  align: TextAlign.center),
            ],
          ),
      ],
    ),
  ));

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
