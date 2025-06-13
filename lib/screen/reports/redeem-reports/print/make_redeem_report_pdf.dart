import 'dart:typed_data';

import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/pdf/components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:motivegold/utils/global.dart';

Future<Uint8List> makeRedeemReportPdf(
    List<RedeemModel?> orders, int type, String date, List<RedeemModel?> daily) async {
  var myTheme = ThemeData.withFont(
    base: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
    bold: Font.ttf(
        await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
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
      orders[i]!.details![j].customerName =
          '${orders[i]?.customer?.firstName} ${orders[i]?.customer?.lastName}';
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
            Text('${Global.company?.name} (สาขา ${Global.branch?.name})',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
                'ที่อยู่ : ${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
                'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber} โทรศัพท์/Phone : ${Global.branch?.phone}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('รายงานภาษีมูลค่าเพิ่มจากการไถ่ถอนตามสัญญาขายฝาก (${getOrderTypeTitle(type)})',
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
            Text('ชื่อผู้ประกอบการ : ${Global.branch?.name}',
                style: const TextStyle()),
            Text('สำหรับ : $date', style: const TextStyle()),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ชื่อสถานประกอบการ : ${Global.company?.name} ',
                style: const TextStyle()),
            Text('ลำดับเลขที่สาขา : ${Global.branch?.branchId}',
                style: const TextStyle()),
          ],
        ),
      ]));
  widgets.add(height());
  if (type == 1) {
    widgets.add(
      Table(
        border: TableBorder.all(color: PdfColors.grey500),
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
          TableRow(children: [
            paddedText('วัน/เดือน/ปี', align: TextAlign.center),
            paddedText('เลขที่ตั๋ว', align: TextAlign.center),
            paddedText('เลขที่ใบกำกับภาษี', align: TextAlign.center),
            paddedText('ลูกค้า', align: TextAlign.center),
            paddedText('เลขประจำตัวผู้เสียภาษี', align: TextAlign.center),
            paddedText('ราคาตามจำ\nนวนสินไถ่ รวมภาษี\nมูลค่าเพิ่ม',
                align: TextAlign.center),
            paddedText('ราคาตาม\nจำนวนสินไถ่', align: TextAlign.right),
            paddedText('ราคาขายฝาก\nที่กำหนดใน\nสัญญา',
                align: TextAlign.center),
            paddedText('ฐานภาษีมูลค่าเพิ่ม', align: TextAlign.center),
            paddedText('ภาษีมูลค่าเพิ่ม', align: TextAlign.center),
          ]),
          for (int i = 0; i < details.length; i++)
            TableRow(
              decoration: const BoxDecoration(),
              children: [
                paddedText(Global.dateOnly(details[i].redeemDate.toString()),
                    align: TextAlign.center),
                paddedText(details[i].referenceNo ?? '',
                    align: TextAlign.center),
                paddedText(
                    orders
                            .firstWhere(
                                (item) => item?.id == details[i].redeemId)
                            ?.redeemId ??
                        '',
                    align: TextAlign.center),
                paddedText('${details[i].customerName}'),
                paddedText(details[i].taxNumber ?? ''),
                paddedText('${Global.format(details[i].redemptionVat ?? 0)}',
                    align: TextAlign.right),
                paddedText('${Global.format(details[i].redemptionValue ?? 0)}',
                    align: TextAlign.right),
                paddedText(Global.format(details[i].depositAmount ?? 0),
                    align: TextAlign.right),
                paddedText(Global.format(details[i].taxBase ?? 0),
                    align: TextAlign.right),
                paddedText(Global.format(details[i].taxAmount ?? 0),
                    align: TextAlign.right),
              ],
            ),
          TableRow(children: [
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText('รวมทั้งหมด', align: TextAlign.right),
            paddedText('${Global.format(totalRedeemVat)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalRedeemValue)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalDepositAmount)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalTaxBase)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalTaxAmount)}',
                align: TextAlign.right),
          ]),
        ],
      ),
    );
  }

  if (type == 2 || type == 3 || type == 4) {
    orders.sort((a, b) => a!.redeemId!.compareTo(b!.redeemId!));
  }

  if (type == 2) {
    widgets.add(
      Table(
        border: TableBorder.all(color: PdfColors.grey500),
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
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedText('วัน/เดือน/ปี', align: TextAlign.center),
                paddedText('เลขที่ใบกำกับภาษี', align: TextAlign.center),
                paddedText('ลูกค้า', align: TextAlign.center),
                paddedText('เลขประจำตัวผู้เสียภาษี', align: TextAlign.center),
                paddedText('เลขที่ตั๋ว', align: TextAlign.center),
                paddedText('ราคาตามจำ\nนวนสินไถ่ รวมภาษี\nมูลค่าเพิ่ม',
                    align: TextAlign.center),
                paddedText('ราคาตาม\nจำนวนสินไถ่', align: TextAlign.right),
                paddedText('ราคาขายฝาก\nที่กำหนดใน\nสัญญา',
                    align: TextAlign.center),
                paddedText('ฐานภาษีมูลค่าเพิ่ม', align: TextAlign.center),
                paddedText('ภาษีมูลค่าเพิ่ม', align: TextAlign.center),
              ]),

          // Data Rows
          for (int i = 0; i < orders.length; i++)
            for (int j = 0; j < orders[i]!.details!.length; j++)
              TableRow(
                decoration: const BoxDecoration(),
                children: [
                  // COLUMN 1: Date
                  paddedText(
                    isFirstRowForOrderId(orders[i]!.details!, j)
                        ? Global.dateOnly(orders[i]!.redeemDate.toString())
                        : '',
                    align: TextAlign.center,
                  ),

                  // COLUMN 2: Redeem ID
                  paddedText(
                    isFirstRowForOrderId(orders[i]!.details!, j)
                        ? orders[i]!.redeemId ?? ''
                        : '',
                    align: TextAlign.center,
                  ),

                  // COLUMN 3: Customer Name
                  paddedText(
                    isFirstRowForOrderId(orders[i]!.details!, j)
                        ? '${orders[i]?.customer?.firstName} ${orders[i]?.customer?.lastName}'
                        : '',
                  ),

                  // COLUMN 4: Tax / ID Number
                  paddedText(
                    isFirstRowForOrderId(orders[i]!.details!, j)
                        ? (orders[i]?.customer?.taxNumber ?? '') != ''
                            ? orders[i]!.customer!.taxNumber!
                            : orders[i]?.customer?.idCard ?? ''
                        : '',
                  ),

                  // COLUMN 5: Reference No
                  paddedText(
                    orders[i]!.details![j].referenceNo ?? '',
                    align: TextAlign.center,
                  ),

                  // COLUMN 6: VAT
                  paddedText(
                    Global.format(orders[i]!.details![j].redemptionVat ?? 0),
                    align: TextAlign.right,
                  ),

                  // COLUMN 7: Redemption Value
                  paddedText(
                    Global.format(orders[i]!.details![j].redemptionValue ?? 0),
                    align: TextAlign.right,
                  ),

                  // COLUMN 8: Deposit Amount
                  paddedText(
                    Global.format(orders[i]!.details![j].depositAmount ?? 0),
                    align: TextAlign.right,
                  ),

                  // COLUMN 9: Tax Base
                  paddedText(
                    Global.format(orders[i]!.details![j].taxBase ?? 0),
                    align: TextAlign.right,
                  ),

                  // COLUMN 10: Tax Amount
                  paddedText(
                    Global.format(orders[i]!.details![j].taxAmount ?? 0),
                    align: TextAlign.right,
                  ),
                ],
              ),

          // Summary Row
          TableRow(children: [
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText('รวมทั้งหมด', align: TextAlign.right),
            paddedText('${Global.format(totalRedeemVat)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalRedeemValue)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalDepositAmount)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalTaxBase)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalTaxAmount)}',
                align: TextAlign.right),
          ]),
        ],
      ),
    );
  }

  if (type == 3) {
    widgets.add(
      Table(
        border: TableBorder.all(color: PdfColors.grey500),
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
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedText('วัน/เดือน/ปี', align: TextAlign.center),
                paddedText('เลขที่ใบกำกับภาษี', align: TextAlign.center),
                paddedText('ลูกค้า', align: TextAlign.center),
                paddedText('เลขประจำตัวผู้เสียภาษี', align: TextAlign.center),
                paddedText('เลขที่ตั๋ว', align: TextAlign.center),
                paddedText('ราคาตามจำ\nนวนสินไถ่ รวมภาษี\nมูลค่าเพิ่ม',
                    align: TextAlign.center),
                paddedText('ราคาตาม\nจำนวนสินไถ่', align: TextAlign.right),
                paddedText('ราคาขายฝาก\nที่กำหนดใน\nสัญญา',
                    align: TextAlign.center),
                paddedText('ฐานภาษีมูลค่าเพิ่ม', align: TextAlign.center),
                paddedText('ภาษีมูลค่าเพิ่ม', align: TextAlign.center),
              ]),

          // Data Rows
          for (int i = 0; i < orders.length; i++)
              TableRow(
                decoration: const BoxDecoration(),
                children: [
                  // COLUMN 1: Date
                  paddedText(Global.dateOnly(orders[i]!.redeemDate.toString()),
                    align: TextAlign.center,
                  ),

                  // COLUMN 2: Redeem ID
                  paddedText(orders[i]!.redeemId ?? '',
                    align: TextAlign.center,
                  ),

                  // COLUMN 3: Customer Name
                  paddedText('${orders[i]?.customer?.firstName} ${orders[i]?.customer?.lastName}',
                  ),

                  // COLUMN 4: Tax / ID Number
                  paddedText((orders[i]?.customer?.taxNumber ?? '') != ''
                        ? orders[i]!.customer!.taxNumber!
                        : orders[i]?.customer?.idCard ?? '',
                  ),

                  // COLUMN 5: Reference No
                  paddedText(
                    orders[i]!.details!
                        .where((item) => item.redeemId == orders[i]!.id)
                        .map((item) => item.referenceNo)
                        .join(','),
                    align: TextAlign.center,
                  ),

                  // COLUMN 6: VAT
                  paddedText(
                    Global.format(getRedemptionVatTotal(orders[i]!.details!)),
                    align: TextAlign.right,
                  ),

                  // COLUMN 7: Redemption Value
                  paddedText(
                    Global.format(getRedemptionValueTotal(orders[i]!.details!)),
                    align: TextAlign.right,
                  ),

                  // COLUMN 8: Deposit Amount
                  paddedText(
                    Global.format(getDepositAmountTotal(orders[i]!.details!)),
                    align: TextAlign.right,
                  ),

                  // COLUMN 9: Tax Base
                  paddedText(
                    Global.format(getTaxBaseTotal(orders[i]!.details!)),
                    align: TextAlign.right,
                  ),

                  // COLUMN 10: Tax Amount
                  paddedText(
                    Global.format(getTaxAmountTotal(orders[i]!.details!)),
                    align: TextAlign.right,
                  ),
                ],
              ),

          // Summary Row
          TableRow(children: [
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText('รวมทั้งหมด', align: TextAlign.right),
            paddedText('${Global.format(totalRedeemVat)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalRedeemValue)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalDepositAmount)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalTaxBase)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalTaxAmount)}',
                align: TextAlign.right),
          ]),
        ],
      ),
    );
  }


  if (type == 4) {

    widgets.add(
      Table(
        border: TableBorder.all(color: PdfColors.grey500),
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
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                paddedText('วัน/เดือน/ปี', align: TextAlign.center),
                paddedText('เลขที่ใบกำกับภาษี', align: TextAlign.center),
                paddedText('รายการ', align: TextAlign.center),
                paddedText('ราคาตามจำ\nนวนสินไถ่ รวมภาษี\nมูลค่าเพิ่ม',
                    align: TextAlign.center),
                paddedText('ราคาตาม\nจำนวนสินไถ่', align: TextAlign.right),
                paddedText('ราคาขายฝาก\nที่กำหนดใน\nสัญญา',
                    align: TextAlign.center),
                paddedText('ฐานภาษีมูลค่าเพิ่ม', align: TextAlign.center),
                paddedText('ภาษีมูลค่าเพิ่ม', align: TextAlign.center),
              ]),

          // Data Rows
          for (int i = 0; i < daily.length; i++)
            TableRow(
              decoration: const BoxDecoration(),
              children: [
                // COLUMN 1: Date
                paddedText(Global.dateOnly(daily[i]!.redeemDate.toString()),
                  align: TextAlign.center,
                ),

                // COLUMN 2: Redeem ID
                paddedText(daily[i]!.redeemId ?? '',
                  align: TextAlign.center,
                ),

                // COLUMN 3: Customer Name
                paddedText(daily[i]?.referenceNo ?? "",
                ),

                // COLUMN 6: VAT
                paddedText(
                  Global.format(daily[i]!.redemptionVat ?? 0),
                  align: TextAlign.right,
                ),

                // COLUMN 7: Redemption Value
                paddedText(
                  Global.format(daily[i]!.redemptionValue ?? 0),
                  align: TextAlign.right,
                ),

                // COLUMN 8: Deposit Amount
                paddedText(
                  Global.format(daily[i]!.depositAmount ?? 0),
                  align: TextAlign.right,
                ),

                // COLUMN 9: Tax Base
                paddedText(
                  Global.format(daily[i]!.taxBase ?? 0),
                  align: TextAlign.right,
                ),

                // COLUMN 10: Tax Amount
                paddedText(
                  Global.format(daily[i]!.taxAmount ?? 0),
                  align: TextAlign.right,
                ),
              ],
            ),

          // Summary Row
          TableRow(children: [
            paddedText(' ', align: TextAlign.center),
            paddedText(' ', align: TextAlign.center),
            paddedText('รวมทั้งหมด', align: TextAlign.right),
            paddedText('${Global.format(totalRedeemVat)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalRedeemValue)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalDepositAmount)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalTaxBase)}',
                align: TextAlign.right),
            paddedText('${Global.format(totalTaxAmount)}',
                align: TextAlign.right),
          ]),
        ],
      ),
    );
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

Widget paddedText(final String text,
        {final TextAlign align = TextAlign.left,
        final TextStyle style = const TextStyle(fontSize: 12)}) =>
    Padding(
      padding: const EdgeInsets.all(5),
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
  switch(type) {
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