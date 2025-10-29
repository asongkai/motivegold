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
  List<RedeemDetailModel> details = [];
  for (int i = 0; i < orders.length; i++) {
    // If order has no details, create a placeholder detail to show the order
    if (orders[i]!.details == null || orders[i]!.details!.isEmpty) {
      final placeholderDetail = RedeemDetailModel(
        redeemId: orders[i]!.id,
        redeemDate: orders[i]?.redeemDate,
        customerName: orders[i]!.redeemStatus == 'CANCEL'
            ? 'ยกเลิกเอกสาร'
            : (orders[i]!.customer != null
                ? '${getCustomerName(orders[i]!.customer!)}'
                : ''),
        taxNumber: orders[i]!.redeemStatus == 'CANCEL'
            ? ''
            : (orders[i]!.customer?.taxNumber != ''
                ? orders[i]!.customer?.taxNumber ?? ''
                : orders[i]!.customer?.idCard ?? ''),
        referenceNo: '', // No reference number for empty details
        redemptionVat: 0,
        redemptionValue: 0,
        depositAmount: 0,
        taxBase: 0,
        taxAmount: 0,
      );
      details.add(placeholderDetail);
    } else {
      for (int j = 0; j < orders[i]!.details!.length; j++) {
        orders[i]!.details![j].redeemDate = orders[i]?.redeemDate;
        orders[i]!.details![j].customerName = orders[i]!.redeemStatus == 'CANCEL'
            ? 'ยกเลิกเอกสาร'
            : (orders[i]!.customer != null
                ? '${getCustomerName(orders[i]!.customer!)}'
                : '');
        // Remove tax ID for cancelled redeems
        orders[i]!.details![j].taxNumber = orders[i]!.redeemStatus == 'CANCEL'
            ? ''
            : (orders[i]!.customer?.taxNumber != ''
                ? orders[i]!.customer?.taxNumber ?? ''
                : orders[i]!.customer?.idCard ?? '');
      }
      details.addAll(orders[i]!.details!);
    }
  }

  // Improved sorting that handles both numeric and alphanumeric references
  details.sort((a, b) {
    // Handle null values - put them at the end
    if (a.referenceNo == null && b.referenceNo == null) return 0;
    if (a.referenceNo == null) return 1;
    if (b.referenceNo == null) return -1;

    // Try to parse as numbers first
    final aNum = int.tryParse(a.referenceNo!);
    final bNum = int.tryParse(b.referenceNo!);

    // If both are numbers, compare numerically
    if (aNum != null && bNum != null) {
      return aNum.compareTo(bNum);
    }

    // If one is a number and one is not, put numbers first
    if (aNum != null && bNum == null) return -1;
    if (aNum == null && bNum != null) return 1;

    // If both are strings, compare alphabetically
    return a.referenceNo!.compareTo(b.referenceNo!);
  });

  Widget buildHeader() {
    return Column(children: [
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
      height(),
      Column(
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
      ]),
      height(),
    ]);
  }

  List<Widget> dataRows = [];

  if (type == 1) {
    dataRows.add(Container(
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
              decoration: BoxDecoration(
                color: orders
                            .firstWhere(
                                (item) => item?.id == details[i].redeemId)
                            ?.redeemStatus ==
                        'CANCEL'
                    ? PdfColors.red100
                    : PdfColors.white,
              ),
              children: [
                paddedTextSmall(
                    Global.dateOnly(details[i].redeemDate.toString()),
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : null),
                    align: TextAlign.center),
                paddedTextSmall(details[i].referenceNo ?? '',
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : PdfColors.purple600),
                    align: TextAlign.center),
                paddedTextSmall(
                    orders
                            .firstWhere(
                                (item) => item?.id == details[i].redeemId)
                            ?.redeemId ??
                        '',
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : null),
                    align: TextAlign.center),
                paddedTextSmall('${details[i].customerName}',
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : null)),
                paddedTextSmall(details[i].taxNumber ?? '',
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : null)),
                paddedTextSmall(
                    '${Global.format(details[i].redemptionVat ?? 0)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : PdfColors.green600),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(details[i].redemptionValue ?? 0)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(details[i].depositAmount ?? 0),
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : PdfColors.orange600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(details[i].taxBase ?? 0),
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : PdfColors.teal600),
                    align: TextAlign.right),
                paddedTextSmall(Global.format(details[i].taxAmount ?? 0),
                    style: TextStyle(
                        fontSize: 11,
                        color: orders
                                    .firstWhere((item) =>
                                        item?.id == details[i].redeemId)
                                    ?.redeemStatus ==
                                'CANCEL'
                            ? PdfColors.red900
                            : PdfColors.red600),
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
                paddedTextSmall(
                    '${Global.format(getRedemptionVatTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getRedemptionValueTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getDepositAmountTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.orange700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(getTaxBaseTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.teal700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(getTaxAmountTotal(details))}',
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
    // Sort orders by redeemId for Type 2 and Type 3
    if (type == 2 || type == 3) {
      orders.sort((a, b) {
        final redeemIdA = a?.redeemId ?? '';
        final redeemIdB = b?.redeemId ?? '';
        return redeemIdA.compareTo(redeemIdB);
      });
    }

    for (int i = 0; i < orders.length; i++) {
      // Check if details exist and sort them
      if (orders[i]?.details != null) {
        orders[i]!.details!.sort((a, b) {
          // Handle null referenceNo gracefully, assuming null comes first or last
          // Here, nulls are treated as smaller, so they come first.
          // If you want nulls last, swap -1 and 1 in the null checks.
          final refA = a.referenceNo;
          final refB = b.referenceNo;

          if (refA == null && refB == null) return 0;
          if (refA == null) return -1; // a is null, b is not, a comes first
          if (refB == null) return 1; // b is null, a is not, b comes first

          return refA.compareTo(refB);
        });
      }
    }
  }

  if (type == 2) {
    dataRows.add(Container(
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
            // If order has no details, show one row with order info and zeros
            if (orders[i]!.details == null || orders[i]!.details!.isEmpty)
              TableRow(
                decoration: BoxDecoration(
                    color: orders[i]!.status == 2
                        ? PdfColors.red100
                        : PdfColors.white),
                children: [
                  // COLUMN 1: Date
                  paddedTextSmall(
                    Global.dateOnly(orders[i]!.redeemDate.toString()),
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            orders[i]!.status == 2 ? PdfColors.red900 : null),
                    align: TextAlign.center,
                  ),

                  // COLUMN 2: Redeem ID
                  paddedTextSmall(
                    orders[i]!.redeemId ?? '',
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            orders[i]!.status == 2 ? PdfColors.red900 : null),
                    align: TextAlign.center,
                  ),

                  // COLUMN 3: Customer Name
                  paddedTextSmall(
                    orders[i]!.redeemStatus == 'CANCEL'
                        ? 'ยกเลิกเอกสาร'
                        : '${orders[i]?.customer?.firstName} ${orders[i]?.customer?.lastName}',
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            orders[i]!.status == 2 ? PdfColors.red900 : null),
                  ),

                  // COLUMN 4: Tax / ID Number
                  paddedTextSmall(
                    orders[i]!.redeemStatus == 'CANCEL'
                        ? ''
                        : ((orders[i]?.customer?.taxNumber ?? '') != ''
                            ? orders[i]!.customer!.taxNumber!
                            : orders[i]?.customer?.idCard ?? ''),
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            orders[i]!.status == 2 ? PdfColors.red900 : null),
                  ),

                  // COLUMN 5: Reference No - empty for orders with no details
                  paddedTextSmall(
                    '',
                    style: TextStyle(
                        fontSize: 11,
                        color: orders[i]!.status == 2
                            ? PdfColors.red900
                            : PdfColors.purple600),
                    align: TextAlign.center,
                  ),

                  // COLUMN 6-10: All zeros for orders with no details
                  paddedTextSmall(
                    Global.format(0),
                    style: TextStyle(
                        fontSize: 11,
                        color: orders[i]!.status == 2
                            ? PdfColors.red900
                            : PdfColors.green600),
                    align: TextAlign.right,
                  ),
                  paddedTextSmall(
                    Global.format(0),
                    style: TextStyle(
                        fontSize: 11,
                        color: orders[i]!.status == 2
                            ? PdfColors.red900
                            : PdfColors.blue600),
                    align: TextAlign.right,
                  ),
                  paddedTextSmall(
                    Global.format(0),
                    style: TextStyle(
                        fontSize: 11,
                        color: orders[i]!.status == 2
                            ? PdfColors.red900
                            : PdfColors.orange600),
                    align: TextAlign.right,
                  ),
                  paddedTextSmall(
                    Global.format(0),
                    style: TextStyle(
                        fontSize: 11,
                        color: orders[i]!.status == 2
                            ? PdfColors.red900
                            : PdfColors.teal600),
                    align: TextAlign.right,
                  ),
                  paddedTextSmall(
                    Global.format(0),
                    style: TextStyle(
                        fontSize: 11,
                        color: orders[i]!.status == 2
                            ? PdfColors.red900
                            : PdfColors.red600),
                    align: TextAlign.right,
                  ),
                ],
              )
            else
              // If order has details, loop through them
              for (int j = 0; j < orders[i]!.details!.length; j++)
                TableRow(
                  decoration: BoxDecoration(
                      color: orders[i]!.status == 2
                          ? PdfColors.red100
                          : PdfColors.white),
                  children: [
                    // COLUMN 1: Date
                    paddedTextSmall(
                      isFirstRowForOrderId(orders[i]!.details!, j)
                          ? Global.dateOnly(orders[i]!.redeemDate.toString())
                          : '',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              orders[i]!.status == 2 ? PdfColors.red900 : null),
                      align: TextAlign.center,
                    ),

                    // COLUMN 2: Redeem ID
                    paddedTextSmall(
                      isFirstRowForOrderId(orders[i]!.details!, j)
                          ? orders[i]!.redeemId ?? ''
                          : '',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              orders[i]!.status == 2 ? PdfColors.red900 : null),
                      align: TextAlign.center,
                    ),

                    // COLUMN 3: Customer Name
                    paddedTextSmall(
                      isFirstRowForOrderId(orders[i]!.details!, j)
                          ? (orders[i]!.redeemStatus == 'CANCEL'
                              ? 'ยกเลิกเอกสาร'
                              : '${orders[i]?.customer?.firstName} ${orders[i]?.customer?.lastName}')
                          : '',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              orders[i]!.status == 2 ? PdfColors.red900 : null),
                    ),

                    // COLUMN 4: Tax / ID Number
                    paddedTextSmall(
                      isFirstRowForOrderId(orders[i]!.details!, j)
                          ? (orders[i]!.redeemStatus == 'CANCEL'
                              ? ''
                              : ((orders[i]?.customer?.taxNumber ?? '') != ''
                                  ? orders[i]!.customer!.taxNumber!
                                  : orders[i]?.customer?.idCard ?? ''))
                          : '',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              orders[i]!.status == 2 ? PdfColors.red900 : null),
                    ),

                    // COLUMN 5: Reference No
                    paddedTextSmall(
                      orders[i]!.details![j].referenceNo ?? '',
                      style: TextStyle(
                          fontSize: 11,
                          color: orders[i]!.status == 2
                              ? PdfColors.red900
                              : PdfColors.purple600),
                      align: TextAlign.center,
                    ),

                    // COLUMN 6: VAT
                    paddedTextSmall(
                      Global.format(orders[i]!.details![j].redemptionVat ?? 0),
                      style: TextStyle(
                          fontSize: 11,
                          color: orders[i]!.status == 2
                              ? PdfColors.red900
                              : PdfColors.green600),
                      align: TextAlign.right,
                    ),

                    // COLUMN 7: Redemption Value
                    paddedTextSmall(
                      Global.format(orders[i]!.details![j].redemptionValue ?? 0),
                      style: TextStyle(
                          fontSize: 11,
                          color: orders[i]!.status == 2
                              ? PdfColors.red900
                              : PdfColors.blue600),
                      align: TextAlign.right,
                    ),

                    // COLUMN 8: Deposit Amount
                    paddedTextSmall(
                      Global.format(orders[i]!.details![j].depositAmount ?? 0),
                      style: TextStyle(
                          fontSize: 11,
                          color: orders[i]!.status == 2
                              ? PdfColors.red900
                              : PdfColors.orange600),
                      align: TextAlign.right,
                    ),

                    // COLUMN 9: Tax Base
                    paddedTextSmall(
                      Global.format(orders[i]!.details![j].taxBase ?? 0),
                      style: TextStyle(
                          fontSize: 11,
                          color: orders[i]!.status == 2
                              ? PdfColors.red900
                              : PdfColors.teal600),
                      align: TextAlign.right,
                    ),

                    // COLUMN 10: Tax Amount
                    paddedTextSmall(
                      Global.format(orders[i]!.details![j].taxAmount ?? 0),
                      style: TextStyle(
                          fontSize: 11,
                          color: orders[i]!.status == 2
                              ? PdfColors.red900
                              : PdfColors.red600),
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
                paddedTextSmall(
                    '${Global.format(getRedemptionVatTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getRedemptionValueTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getDepositAmountTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.orange700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(getTaxBaseTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.teal700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(getTaxAmountTotal(details))}',
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
    dataRows.add(Container(
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
              decoration: BoxDecoration(
                  color: orders[i]!.status == 2
                      ? PdfColors.red100
                      : PdfColors.white),
              children: [
                // COLUMN 1: Date
                paddedTextSmall(
                  Global.dateOnly(orders[i]!.redeemDate.toString()),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2 ? PdfColors.red900 : null),
                  align: TextAlign.center,
                ),

                // COLUMN 2: Redeem ID
                paddedTextSmall(
                  orders[i]!.redeemId ?? '',
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2 ? PdfColors.red900 : null),
                  align: TextAlign.center,
                ),

                // COLUMN 3: Customer Name
                paddedTextSmall(
                  orders[i]!.redeemStatus == 'CANCEL'
                      ? 'ยกเลิกเอกสาร'
                      : '${orders[i]?.customer?.firstName} ${orders[i]?.customer?.lastName}',
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2 ? PdfColors.red900 : null),
                ),

                // COLUMN 4: Tax / ID Number
                paddedTextSmall(
                  orders[i]!.redeemStatus == 'CANCEL'
                      ? ''
                      : ((orders[i]?.customer?.taxNumber ?? '') != ''
                          ? orders[i]!.customer!.taxNumber!
                          : orders[i]?.customer?.idCard ?? ''),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2 ? PdfColors.red900 : null),
                ),

                // COLUMN 5: Reference No
                paddedTextSmall(
                  orders[i]!
                      .details!
                      .where((item) => item.redeemId == orders[i]!.id)
                      .map((item) => item.referenceNo)
                      .join(','),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2
                          ? PdfColors.red900
                          : PdfColors.purple600),
                  align: TextAlign.center,
                ),

                // COLUMN 6: VAT
                paddedTextSmall(
                  Global.format(getRedemptionVatTotal(orders[i]!.details!)),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2
                          ? PdfColors.red900
                          : PdfColors.green600),
                  align: TextAlign.right,
                ),

                // COLUMN 7: Redemption Value
                paddedTextSmall(
                  Global.format(getRedemptionValueTotal(orders[i]!.details!)),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2
                          ? PdfColors.red900
                          : PdfColors.blue600),
                  align: TextAlign.right,
                ),

                // COLUMN 8: Deposit Amount
                paddedTextSmall(
                  Global.format(getDepositAmountTotal(orders[i]!.details!)),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2
                          ? PdfColors.red900
                          : PdfColors.orange600),
                  align: TextAlign.right,
                ),

                // COLUMN 9: Tax Base
                paddedTextSmall(
                  Global.format(getTaxBaseTotal(orders[i]!.details!)),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2
                          ? PdfColors.red900
                          : PdfColors.teal600),
                  align: TextAlign.right,
                ),

                // COLUMN 10: Tax Amount
                paddedTextSmall(
                  Global.format(getTaxAmountTotal(orders[i]!.details!)),
                  style: TextStyle(
                      fontSize: 11,
                      color: orders[i]!.status == 2
                          ? PdfColors.red900
                          : PdfColors.red600),
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
                paddedTextSmall(
                    '${Global.format(getRedemptionVatTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getRedemptionValueTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getDepositAmountTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.orange700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(getTaxBaseTotal(details))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.teal700),
                    align: TextAlign.right),
                paddedTextSmall('${Global.format(getTaxAmountTotal(details))}',
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
    dataRows.add(Container(
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
              decoration: BoxDecoration(color: PdfColors.white),
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
                paddedTextSmall(
                    '${Global.format(getRedemptionVatTotalFromRedeems(daily))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getRedemptionValueTotalFromRedeems(daily))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.blue700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getDepositAmountTotalFromRedeems(daily))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.orange700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getTaxBaseTotalFromRedeems(daily))}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.teal700),
                    align: TextAlign.right),
                paddedTextSmall(
                    '${Global.format(getTaxAmountTotalFromRedeems(daily))}',
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
      header: (context) => buildHeader(),
      build: (context) => dataRows,
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

// Helper functions to calculate accurate sums from detail rows
// Round each value to 2 decimals before summing to fix precision errors in stored data
double getRedemptionVatTotal(List<RedeemDetailModel> details) {
  return details.fold(0.0, (sum, detail) {
    double value = detail.redemptionVat ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}

double getRedemptionValueTotal(List<RedeemDetailModel> details) {
  return details.fold(0.0, (sum, detail) {
    double value = detail.redemptionValue ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}

double getDepositAmountTotal(List<RedeemDetailModel> details) {
  return details.fold(0.0, (sum, detail) {
    double value = detail.depositAmount ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}

double getTaxBaseTotal(List<RedeemDetailModel> details) {
  return details.fold(0.0, (sum, detail) {
    double value = detail.taxBase ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}

double getTaxAmountTotal(List<RedeemDetailModel> details) {
  return details.fold(0.0, (sum, detail) {
    double value = detail.taxAmount ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}

// Helper functions to calculate accurate sums from RedeemModel list (for Type 4 - Daily Report)
// Round each value to 2 decimals before summing to fix precision errors in stored data
double getRedemptionVatTotalFromRedeems(List<RedeemModel?> redeems) {
  return redeems.fold(0.0, (sum, redeem) {
    double value = redeem?.redemptionVat ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}

double getRedemptionValueTotalFromRedeems(List<RedeemModel?> redeems) {
  return redeems.fold(0.0, (sum, redeem) {
    double value = redeem?.redemptionValue ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}

double getDepositAmountTotalFromRedeems(List<RedeemModel?> redeems) {
  return redeems.fold(0.0, (sum, redeem) {
    double value = redeem?.depositAmount ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}

double getTaxBaseTotalFromRedeems(List<RedeemModel?> redeems) {
  return redeems.fold(0.0, (sum, redeem) {
    double value = redeem?.taxBase ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}

double getTaxAmountTotalFromRedeems(List<RedeemModel?> redeems) {
  return redeems.fold(0.0, (sum, redeem) {
    double value = redeem?.taxAmount ?? 0;
    double rounded = (value * 100).round() / 100;
    return sum + rounded;
  });
}
