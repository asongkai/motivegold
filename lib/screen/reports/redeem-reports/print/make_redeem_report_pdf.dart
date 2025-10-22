import 'dart:typed_data';

import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:motivegold/utils/global.dart';

Widget _buildCheckbox(bool? isChecked) {
  motivePrint(isChecked);
  return Container(
    width: 15,
    height: 15,
    decoration: BoxDecoration(
      border: Border.all(
        color: PdfColors.black,
        width: 1,
      ),
    ),
    child: isChecked != null && isChecked
        ? CustomPaint(
            size: PdfPoint(15, 15),
            painter: (PdfGraphics canvas, PdfPoint size) {
// PDF coordinate system might be inverted
              canvas
                ..setColor(PdfColors.black)
                ..setLineWidth(1.5)
// Try with inverted Y coordinates
                ..moveTo(3, 8) // Left point
                ..lineTo(6, 5) // Bottom point (smaller Y = down in PDF)
                ..lineTo(12, 11) // Top-right point
                ..strokePath();
            },
          )
        : Container(),
  );
}

Future<Uint8List> makeRedeemReportPdf(List<RedeemModel?> orders, int type,
    String date, List<RedeemModel?> daily) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(await rootBundle.load("assets/fonts/thai/THSarabunNew.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/THSarabunNew-Bold.ttf")),
  );
  final pdf = Document(theme: myTheme);
  double totalRedeemVat = 0;
  double totalRedeemValue = 0;
  double totalDepositAmount = 0;
  double totalTaxBase = 0;
  double totalTaxAmount = 0;
  List<RedeemDetailModel> details = [];
  for (int i = 0; i < orders.length; i++) {
    for (int j = 0; j < orders[i]!.details!.length; j++) {
      orders[i]!.details![j].redeemDate = orders[i]?.redeemDate;
      orders[i]!.details![j].customerName = orders[i]!.customer != null
          ? '${getCustomerName(orders[i]!.customer!)}'
          : '';
      orders[i]!.details![j].taxNumber = orders[i]!.customer?.taxNumber != ''
          ? orders[i]!.customer?.taxNumber ?? ''
          : orders[i]!.customer?.idCard ?? '';
      totalRedeemVat += orders[i]!.details![j].redemptionVat ?? 0;
      totalRedeemValue += orders[i]!.details![j].redemptionValue ?? 0;
      totalDepositAmount += orders[i]!.details![j].depositAmount ?? 0;
      totalTaxBase += orders[i]!.details![j].taxBase ?? 0;
      totalTaxAmount += orders[i]!.details![j].taxAmount ?? 0;
    }
    details.addAll(orders[i]!.details!);
  }

  details.sort((a, b) => a.referenceNo!.compareTo(b.referenceNo!));

  List<Widget> widgets = [];
  widgets.add(
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                Global.branch!.isHeadquarter == true
                    ? '${Global.company!.name} (สำนักงานใหญ่)'
                    : '${Global.company!.name}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            // reportsCompanyTitle(),

            Text(
                'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber} โทรศัพท์/Phone : ${Global.branch?.phone}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
                'รายงานภาษีมูลค่าเพิ่มจากการไถ่ถอนตามสัญญาขายฝาก (${getOrderTypeTitle(type)})',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('รายงานภาษีขาย',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
  widgets.add(height());
  widgets.add(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Global.branch!.isHeadquarter == true
                ? "ชื่อสถานประกอบการ : ${Global.company!.name} "
                : "ชื่อสถานประกอบการ : ${Global.branch!.name}"),
            SizedBox(width: 30),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Custom checkbox using a container
                      _buildCheckbox(
                          Global.branch!.isHeadquarter == true ? true : false),
                      SizedBox(width: 5),
                      Text('สำนักงานใหญ่'),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      _buildCheckbox(
                          Global.branch!.isHeadquarter == false ? true : false),
                      SizedBox(width: 5),
                      Text('สาขา'),
                      SizedBox(width: 10),
                      Text('${Global.branch!.branchId}'),
                    ],
                  ),
                ],
              ),
            ),
            Text('สำหรับ : $date', style: const TextStyle()),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ที่อยู่ : ${getFullAddress()}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
            Text('ลำดับเลขที่สาขา : ${Global.branch?.branchId}',
                style: const TextStyle()),
          ],
        ),
      ]));
  widgets.add(height());

  if (type == 1) {
    widgets.add(Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: Table(
        border: TableBorder(
          top: BorderSide.none,
          bottom: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          horizontalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
          verticalInside: BorderSide.none,
        ),
        columnWidths: {
          0: const FixedColumnWidth(30),
          1: const FixedColumnWidth(30),
          2: const FixedColumnWidth(30),
          3: const FixedColumnWidth(30),
          4: const FixedColumnWidth(30),
          5: const FixedColumnWidth(30),
          6: const FixedColumnWidth(30),
          7: const FixedColumnWidth(30),
          8: const FixedColumnWidth(25),
          9: const FixedColumnWidth(25),
        },
        children: [
          TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue600,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              children: [
                paddedTextSmall('วัน/เดือน/ปี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่ตั๋ว',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่ใบกำกับภาษี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('ลูกค้า',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขประจำตัว\nผู้เสียภาษี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('ราคาตามจำนวน\nสินไถ่ รวมภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ราคาตาม\nจำนวนสินไถ่',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ราคาขายฝาก\nที่กำหนดใน\nสัญญา',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ฐานภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
              ]),
          for (int i = 0; i < details.length; i++)
            TableRow(
              decoration: const BoxDecoration(),
              children: [
                paddedTextSmall(
                    Global.dateOnly(details[i].redeemDate.toString()),
                    style: TextStyle(fontSize: 11),
                    align: TextAlign.center),
                paddedTextSmall(details[i].referenceNo ?? '',
                    style: TextStyle(fontSize: 11, color: PdfColors.purple600),
                    align: TextAlign.center),
                paddedTextSmall(
                    orders
                            .firstWhere(
                                (item) => item?.id == details[i].redeemId)
                            ?.redeemId ??
                        '',
                    style: TextStyle(fontSize: 11),
                    align: TextAlign.center),
                paddedTextSmall('${details[i].customerName}',
                    style: TextStyle(fontSize: 11)),
                paddedTextSmall(details[i].taxNumber ?? '',
                    style: TextStyle(fontSize: 11)),
                paddedTextSmall(
                    '${Global.format(details[i].redemptionVat ?? 0)}',
                    style: TextStyle(fontSize: 11, color: PdfColors.green600),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(details[i].redemptionValue ?? 0)}',
                    style: TextStyle(fontSize: 11, color: PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(details[i].depositAmount ?? 0),
                    style: TextStyle(fontSize: 11, color: PdfColors.orange600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(details[i].taxBase ?? 0),
                    style: TextStyle(fontSize: 11, color: PdfColors.teal600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(details[i].taxAmount ?? 0),
                    style: TextStyle(fontSize: 11, color: PdfColors.red600),
                    align: TextAlign.right),
              ],
            ),
          TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue50,
                border: Border(
                  top: BorderSide(color: PdfColors.blue200, width: 1),
                ),
              ),
              children: [
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('รวมทั้งหมด',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue800),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalRedeemVat)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalRedeemValue)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalDepositAmount)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.orange700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalTaxBase)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.teal700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalTaxAmount)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.red700),
                    align: TextAlign.right),
              ]),
        ],
      ),
    ));
  }

  if (type == 2 || type == 3 || type == 4) {
    orders.sort((a, b) => a!.redeemId!.compareTo(b!.redeemId!));
  }

  if (type == 2) {
    widgets.add(Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: Table(
        border: TableBorder(
          top: BorderSide.none,
          bottom: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          horizontalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
          verticalInside: BorderSide.none,
        ),
        columnWidths: {
          0: const FixedColumnWidth(30),
          1: const FixedColumnWidth(30),
          2: const FixedColumnWidth(30),
          3: const FixedColumnWidth(30),
          4: const FixedColumnWidth(30),
          5: const FixedColumnWidth(30),
          6: const FixedColumnWidth(30),
          7: const FixedColumnWidth(30),
          8: const FixedColumnWidth(25),
          9: const FixedColumnWidth(25),
        },
        children: [
          // Header Row
          TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue600,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedTextSmall('วัน/เดือน/ปี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่ใบกำกับภาษี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('ลูกค้า',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขประจำตัว\nผู้เสียภาษี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่ตั๋ว',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('ราคาตามจำนวน\nสินไถ่ รวมภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ราคาตาม\nจำนวนสินไถ่',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ราคาขายฝาก\nที่กำหนดใน\nสัญญา',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ฐานภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
              ]),

          // Data Rows
          for (int i = 0; i < orders.length; i++)
            for (int j = 0; j < orders[i]!.details!.length; j++)
              TableRow(
                decoration: const BoxDecoration(),
                children: [
                  // COLUMN 1: Date
                  paddedTextSmall(
                    isFirstRowForOrderId(orders[i]!.details!, j)
                        ? Global.dateOnly(orders[i]!.redeemDate.toString())
                        : '',
                    style: TextStyle(fontSize: 11),
                    align: TextAlign.center,
                  ),

                  // COLUMN 2: Redeem ID
                  paddedTextSmall(
                    isFirstRowForOrderId(orders[i]!.details!, j)
                        ? orders[i]!.redeemId ?? ''
                        : '',
                    style: TextStyle(fontSize: 11),
                    align: TextAlign.center,
                  ),

                  // COLUMN 3: Customer Name
                  paddedTextSmall(
                    isFirstRowForOrderId(orders[i]!.details!, j)
                        ? '${orders[i]?.customer?.firstName} ${orders[i]?.customer?.lastName}'
                        : '',
                    style: TextStyle(fontSize: 11),
                  ),

                  // COLUMN 4: Tax / ID Number
                  paddedTextSmall(
                    isFirstRowForOrderId(orders[i]!.details!, j)
                        ? (orders[i]?.customer?.taxNumber ?? '') != ''
                            ? orders[i]!.customer!.taxNumber!
                            : orders[i]?.customer?.idCard ?? ''
                        : '',
                    style: TextStyle(fontSize: 11),
                  ),

                  // COLUMN 5: Reference No
                  paddedTextSmall(
                    orders[i]!.details![j].referenceNo ?? '',
                    style: TextStyle(fontSize: 11, color: PdfColors.purple600),
                    align: TextAlign.center,
                  ),

                  // COLUMN 6: VAT
                  paddedTextSmall(
                    Global.format(orders[i]!.details![j].redemptionVat ?? 0),
                    style: TextStyle(fontSize: 11, color: PdfColors.green600),
                    align: TextAlign.right,
                  ),

                  // COLUMN 7: Redemption Value
                  paddedTextSmall(
                    Global.format(orders[i]!.details![j].redemptionValue ?? 0),
                    style: TextStyle(fontSize: 11, color: PdfColors.blue600),
                    align: TextAlign.right,
                  ),

                  // COLUMN 8: Deposit Amount
                  paddedTextSmall(
                    Global.format(orders[i]!.details![j].depositAmount ?? 0),
                    style: TextStyle(fontSize: 11, color: PdfColors.orange600),
                    align: TextAlign.right,
                  ),

                  // COLUMN 9: Tax Base
                  paddedTextSmall(
                    Global.format(orders[i]!.details![j].taxBase ?? 0),
                    style: TextStyle(fontSize: 11, color: PdfColors.teal600),
                    align: TextAlign.right,
                  ),

                  // COLUMN 10: Tax Amount
                  paddedTextSmall(
                    Global.format(orders[i]!.details![j].taxAmount ?? 0),
                    style: TextStyle(fontSize: 11, color: PdfColors.red600),
                    align: TextAlign.right,
                  ),
                ],
              ),

          // Summary Row
          TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue50,
                border: Border(
                  top: BorderSide(color: PdfColors.blue200, width: 1),
                ),
              ),
              children: [
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('รวมทั้งหมด',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue800),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalRedeemVat)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalRedeemValue)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalDepositAmount)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.orange700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalTaxBase)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.teal700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalTaxAmount)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.red700),
                    align: TextAlign.right),
              ]),
        ],
      ),
    ));
  }

  if (type == 3) {
    widgets.add(Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: Table(
        border: TableBorder(
          top: BorderSide.none,
          bottom: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          horizontalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
          verticalInside: BorderSide.none,
        ),
        columnWidths: {
          0: const FixedColumnWidth(30),
          1: const FixedColumnWidth(30),
          2: const FixedColumnWidth(30),
          3: const FixedColumnWidth(30),
          4: const FixedColumnWidth(30),
          5: const FixedColumnWidth(30),
          6: const FixedColumnWidth(30),
          7: const FixedColumnWidth(30),
          8: const FixedColumnWidth(25),
          9: const FixedColumnWidth(25),
        },
        children: [
          // Header Row
          TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue600,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedTextSmall('วัน/เดือน/ปี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่ใบกำกับภาษี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('ลูกค้า',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขประจำตัว\nผู้เสียภาษี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่ตั๋ว',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('ราคาตามจำนวน\nสินไถ่ รวมภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ราคาตาม\nจำนวนสินไถ่',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ราคาขายฝาก\nที่กำหนดใน\nสัญญา',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ฐานภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
              ]),

          // Data Rows
          for (int i = 0; i < orders.length; i++)
            TableRow(
              decoration: const BoxDecoration(),
              children: [
                // COLUMN 1: Date
                paddedTextSmall(
                  Global.dateOnly(orders[i]!.redeemDate.toString()),
                  style: TextStyle(fontSize: 11),
                  align: TextAlign.center,
                ),

                // COLUMN 2: Redeem ID
                paddedTextSmall(
                  orders[i]!.redeemId ?? '',
                  style: TextStyle(fontSize: 11),
                  align: TextAlign.center,
                ),

                // COLUMN 3: Customer Name
                paddedTextSmall(
                  '${orders[i]?.customer?.firstName} ${orders[i]?.customer?.lastName}',
                  style: TextStyle(fontSize: 11),
                ),

                // COLUMN 4: Tax / ID Number
                paddedTextSmall(
                  (orders[i]?.customer?.taxNumber ?? '') != ''
                      ? orders[i]!.customer!.taxNumber!
                      : orders[i]?.customer?.idCard ?? '',
                  style: TextStyle(fontSize: 11),
                ),

                // COLUMN 5: Reference No
                paddedTextSmall(
                  orders[i]!
                      .details!
                      .where((item) => item.redeemId == orders[i]!.id)
                      .map((item) => item.referenceNo)
                      .join(','),
                  style: TextStyle(fontSize: 11, color: PdfColors.purple600),
                  align: TextAlign.center,
                ),

                // COLUMN 6: VAT
                paddedTextSmall(
                  Global.format(getRedemptionVatTotal(orders[i]!.details!)),
                  style: TextStyle(fontSize: 11, color: PdfColors.green600),
                  align: TextAlign.right,
                ),

                // COLUMN 7: Redemption Value
                paddedTextSmall(
                  Global.format(getRedemptionValueTotal(orders[i]!.details!)),
                  style: TextStyle(fontSize: 11, color: PdfColors.blue600),
                  align: TextAlign.right,
                ),

                // COLUMN 8: Deposit Amount
                paddedTextSmall(
                  Global.format(getDepositAmountTotal(orders[i]!.details!)),
                  style: TextStyle(fontSize: 11, color: PdfColors.orange600),
                  align: TextAlign.right,
                ),

                // COLUMN 9: Tax Base
                paddedTextSmall(
                  Global.format(getTaxBaseTotal(orders[i]!.details!)),
                  style: TextStyle(fontSize: 11, color: PdfColors.teal600),
                  align: TextAlign.right,
                ),

                // COLUMN 10: Tax Amount
                paddedTextSmall(
                  Global.format(getTaxAmountTotal(orders[i]!.details!)),
                  style: TextStyle(fontSize: 11, color: PdfColors.red600),
                  align: TextAlign.right,
                ),
              ],
            ),

          // Summary Row
          TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue50,
                border: Border(
                  top: BorderSide(color: PdfColors.blue200, width: 1),
                ),
              ),
              children: [
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('รวมทั้งหมด',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue800),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalRedeemVat)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalRedeemValue)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalDepositAmount)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.orange700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalTaxBase)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.teal700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalTaxAmount)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.red700),
                    align: TextAlign.right),
              ]),
        ],
      ),
    ));
  }

  if (type == 4) {
    widgets.add(Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: Table(
        border: TableBorder(
          top: BorderSide.none,
          bottom: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          horizontalInside: BorderSide(color: PdfColors.grey200, width: 0.5),
          verticalInside: BorderSide.none,
        ),
        columnWidths: {
          0: const FixedColumnWidth(25),
          1: const FixedColumnWidth(50),
          2: const FixedColumnWidth(30),
          3: const FixedColumnWidth(30),
          4: const FixedColumnWidth(30),
          5: const FixedColumnWidth(25),
          6: const FixedColumnWidth(25),
          7: const FixedColumnWidth(25),
        },
        children: [
          // Header Row
          TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue600,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedTextSmall('วัน/เดือน/ปี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('เลขที่ใบกำกับภาษี',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('รายการ',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.center),
                paddedTextSmall('ราคาตามจำนวน\nสินไถ่ รวมภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ราคาตาม\nจำนวนสินไถ่',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ราคาขายฝาก\nที่กำหนดใน\nสัญญา',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ฐานภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
                paddedTextSmall('ภาษี\nมูลค่าเพิ่ม',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.white),
                    align: TextAlign.right),
              ]),

          // Data Rows
          for (int i = 0; i < daily.length; i++)
            TableRow(
              decoration: const BoxDecoration(),
              children: [
                // COLUMN 1: Date
                paddedTextSmall(
                  Global.dateOnly(daily[i]!.redeemDate.toString()),
                  style: TextStyle(fontSize: 11),
                  align: TextAlign.center,
                ),

                // COLUMN 2: Redeem ID
                paddedTextSmall(
                  daily[i]!.redeemId ?? '',
                  style: TextStyle(fontSize: 11),
                  align: TextAlign.center,
                ),

                // COLUMN 3: Reference No
                paddedTextSmall(
                  daily[i]?.referenceNo ?? "",
                  style: TextStyle(fontSize: 11, color: PdfColors.purple600),
                ),

                // COLUMN 4: VAT
                paddedTextSmall(
                  Global.format(daily[i]!.redemptionVat ?? 0),
                  style: TextStyle(fontSize: 11, color: PdfColors.green600),
                  align: TextAlign.right,
                ),

                // COLUMN 5: Redemption Value
                paddedTextSmall(
                  Global.format(daily[i]!.redemptionValue ?? 0),
                  style: TextStyle(fontSize: 11, color: PdfColors.blue600),
                  align: TextAlign.right,
                ),

                // COLUMN 6: Deposit Amount
                paddedTextSmall(
                  Global.format(daily[i]!.depositAmount ?? 0),
                  style: TextStyle(fontSize: 11, color: PdfColors.orange600),
                  align: TextAlign.right,
                ),

                // COLUMN 7: Tax Base
                paddedTextSmall(
                  Global.format(daily[i]!.taxBase ?? 0),
                  style: TextStyle(fontSize: 11, color: PdfColors.teal600),
                  align: TextAlign.right,
                ),

                // COLUMN 8: Tax Amount
                paddedTextSmall(
                  Global.format(daily[i]!.taxAmount ?? 0),
                  style: TextStyle(fontSize: 11, color: PdfColors.red600),
                  align: TextAlign.right,
                ),
              ],
            ),

          // Summary Row
          TableRow(
              decoration: BoxDecoration(
                color: PdfColors.blue50,
                border: Border(
                  top: BorderSide(color: PdfColors.blue200, width: 1),
                ),
              ),
              children: [
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('', style: const TextStyle(fontSize: 11)),
                paddedTextSmall('รวมทั้งหมด',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue800),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalRedeemVat)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalRedeemValue)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalDepositAmount)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.orange700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalTaxBase)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.teal700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(totalTaxAmount)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.red700),
                    align: TextAlign.right),
              ]),
        ],
      ),
    ));
  }

  pdf.addPage(
    MultiPage(
      margin: const EdgeInsets.all(20),
      pageFormat: PdfPageFormat(
        PdfPageFormat.a4.height, // height becomes width
        PdfPageFormat.a4.width, // width becomes height
      ),
      orientation: PageOrientation.landscape,
      build: (context) => widgets,
      footer: (context) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(' '),
              Text('${context.pageNumber} / ${context.pagesCount}')
            ]);
      },
    ),
  );
  return pdf.save();
}

Widget paddedTextSmall(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 11)}) =>
    Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );

bool isFirstRowForOrderId(List<RedeemDetailModel?> orders, int index) {
  if (index == 0) return true;
  return orders[index]?.redeemId != orders[index - 1]?.redeemId;
}

String getOrderTypeTitle(int type) {
  switch (type) {
    case 1:
      return 'เรียงตั๋ว';
    case 2:
      return 'เรียงเอกสารแบบรายตั๋ว';
    case 3:
      return 'เรียงเอกสาร';
    case 4:
      return 'สรุปรายวัน';
    default:
      return 'เรียงตั๋ว';
  }
}
