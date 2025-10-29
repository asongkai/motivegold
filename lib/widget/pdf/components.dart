import 'dart:typed_data';

import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

Widget divider() {
  return Divider(
    height: 1,
    borderStyle: BorderStyle.dashed,
  );
}

Widget height({double h = 10}) {
  return SizedBox(height: h);
}

Future<Uint8List?> loadNetworkImage(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    return null;
  }
}

Future<Widget> header(OrderModel order, String? title,
    {bool? showPosId, String? versionText, bool full = true}) async {
  // Load network image
  final Uint8List? imageData = await loadNetworkImage(
      '${Constants.DOMAIN_URL}/images/${Global.company?.logo}');

  final image = imageData != null ? MemoryImage(imageData) : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Container(
          width: 70,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: image == null
                ? Container()
                : Image(image, fit: BoxFit.fitWidth, width: 60, height: 60),
          ),
        ),
        Expanded(
            flex: 6,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(getCompanyName(full: full),
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(getBillAddressLine1(),
                      style: const TextStyle(fontSize: 10)),
                  Text(getBillAddressLine2(),
                      style: const TextStyle(fontSize: 10)),
                  Text('โทรศัพท์ : ${Global.branch?.phone}',
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber}',
                      style: const TextStyle(fontSize: 11)),
                ])),
        Expanded(
          flex: 2,
          child: Container(
            width: 100,
            // Adjust the width as needed
            height: 50,
            // Adjust the height as needed
            margin: EdgeInsets.only(bottom: -30),
            decoration: BoxDecoration(
              color: PdfColors.grey200, // Light gray background
              borderRadius: BorderRadius.circular(8), // Rounded corners
              border: Border.all(
                color: PdfColors.black, // Black border
                width: 1.0, // Border width
              ),
            ),
            child: Center(
              child: Text(
                '$versionText', // Thai text
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: PdfColors.black, // Text color
                ),
              ),
            ),
          ),
        ),
      ]),
      if (title != null)
        Center(
          child: Column(
            children: [
              Row(children: [
                Expanded(flex: 2, child: Container()),
                Expanded(
                  flex: 6,
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                Expanded(flex: 2, child: Container()),
              ]),
              if (showPosId != null)
                Text('Tax Invoice (ABB) (Vat Include)',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
              if (showPosId != null)
                Text(
                    'เลขรหัสประจําเครื่อง ${Global.posIdModel?.posId != null && Global.posIdModel?.posId != "" ? Global.posIdModel?.posId : ""}',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
            ],
          ),
        ),
    ],
  );
}

String getCompanyName({bool full = true}) {
  if (Global.branch == null) {
    return Global.company?.name ?? "";
  }

  if (Global.branch!.isHeadquarter == true) {
    return '${Global.company?.name} (สำนักงานใหญ่)';
  } else {
    if (Global.branch!.showAbbreviatedName == true && full == false) {
      return '${Global.branch?.name} สาขาที่ (${Global.branch!.branchId})';
    } else {
      return '${Global.company?.name} สาขาที่ (${Global.branch!.branchId}) "${Global.branch!.name}"';
    }
  }
}

Future<Widget> headerRedeem(RedeemModel order, String? title,
    {bool? showPosId, String? versionText}) async {
  // Load network image
  final Uint8List? imageData = await loadNetworkImage(
      '${Constants.DOMAIN_URL}/images/${Global.company?.logo}');

  final image = imageData != null ? MemoryImage(imageData) : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(children: [
        Container(
          width: 70,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: image == null
                ? Container()
                : Image(image, fit: BoxFit.fitWidth, width: 60, height: 60),
          ),
        ),
        Expanded(
            flex: 6,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(getCompanyName(full: true),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(getBillAddressLine1(), style: const TextStyle(fontSize: 10)),
              Text(getBillAddressLine2(), style: const TextStyle(fontSize: 10)),
              Text('โทรศัพท์ : ${Global.branch?.phone}',
                  style: const TextStyle(fontSize: 11)),
              Text(
                  'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber}',
                  style: const TextStyle(fontSize: 11)),
            ])),
        Expanded(
          flex: 2,
          child: Container(
            width: 100,
            // Adjust the width as needed
            height: 50,
            // Adjust the height as needed
            margin: EdgeInsets.only(bottom: -30),
            decoration: BoxDecoration(
              color: PdfColors.grey200, // Light gray background
              borderRadius: BorderRadius.circular(8), // Rounded corners
              border: Border.all(
                color: PdfColors.black, // Black border
                width: 1.0, // Border width
              ),
            ),
            child: Center(
              child: Text(
                '$versionText', // Thai text
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: PdfColors.black, // Text color
                ),
              ),
            ),
          ),
        ),
      ]),
      if (title != null)
        Center(
          child: Column(
            children: [
              height(),
              Row(
                children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                    flex: 6,
                    child: Text(title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
                ],
              ),
            ],
          ),
        ),
    ],
  );
}

Widget headerRefill(OrderModel order, String? title) {
  return Center(
      child: Column(children: [
    Text('${Global.company?.name}  (${Global.branch?.name})',
        style: const TextStyle(fontSize: 11)),
    if (title != null)
      Row(children: [
        Expanded(flex: 2, child: Container()),
        Expanded(
          flex: 6,
          child: Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11)),
        ),
        Expanded(
            flex: 2,
            child: Container(
              width: 100,
              // Adjust the width as needed
              height: 50,
              // Adjust the height as needed
              margin: EdgeInsets.only(bottom: -30),
              decoration: BoxDecoration(
                color: PdfColors.grey200, // Light gray background
                borderRadius: BorderRadius.circular(8), // Rounded corners
                border: Border.all(
                  color: PdfColors.black, // Black border
                  width: 1.0, // Border width
                ),
              ),
              child: Center(
                child: Text(
                  'ต้นฉบับ', // Thai text
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: PdfColors.black, // Text color
                  ),
                ),
              ),
            )),
      ]),
  ]));
}

Widget docNo(OrderModel order) {
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          if (order.orderTypeId == 5 ||
              order.orderTypeId == 6 ||
              order.orderTypeId == 10 ||
              order.orderTypeId == 11)
            Container(height: 14),
          Text('วันที่ : ${Global.formatDateNT(order.orderDate.toString())} ',
              style: const TextStyle(fontSize: 11)),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('เลขที่ :', style: const TextStyle(fontSize: 11)),
              SizedBox(width: 10),
              Text(' ${order.orderId}', style: const TextStyle(fontSize: 11)),
            ]),
            if (order.orderTypeId == 5 ||
                order.orderTypeId == 6 ||
                order.orderTypeId == 10 ||
                order.orderTypeId == 11)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('เลขที่อ้างอิง :', style: const TextStyle(fontSize: 11)),
                SizedBox(width: 10),
                Text(' ${order.referenceNo}',
                    style: const TextStyle(fontSize: 11)),
              ]),
          ],
        ),
      ]);
}

Widget docNoRefill(OrderModel order) {
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Text('วันที่ : ${Global.formatDateNT(order.orderDate.toString())} ',
              style: const TextStyle(fontSize: 11)),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (order.orderTypeId == 5 || order.orderTypeId == 10)
                Text('เลขที่ใบรับทอง :', style: const TextStyle(fontSize: 11)),
              if (order.orderTypeId == 6 || order.orderTypeId == 11)
                Text('เลขที่ใบกำกับภาษี :',
                    style: const TextStyle(fontSize: 11)),
              SizedBox(width: 5),
              Text(' ${order.orderId}', style: const TextStyle(fontSize: 11)),
            ]),
          ],
        ),
      ]);
}

Widget docNoRedeem(RedeemModel order) {
  return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            flex: 7,
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(50),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    Text('ชื่อ-สกุลผู้ไถ่ถอน : ${getCustomerName(order.customer!)}',
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
                if (getCustomerBillAddressLine1(order.customer!).isNotEmpty)
                  TableRow(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ที่อยู่ : ',
                              style: const TextStyle(fontSize: 11)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getCustomerBillAddressLine1(order.customer!),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                if (getCustomerBillAddressLine2(order.customer!)
                                    .isNotEmpty)
                                  Text(
                                    getCustomerBillAddressLine2(order.customer!),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            )),
        if (order.status == "2" || order.redeemStatus == 'CANCEL')
          Container(
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: PdfColors.black,
                width: 1.0,
              ),
              color: PdfColors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 0.0,
              ),
              child: Text(
                'ยกเลิก',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PdfColors.red,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Expanded(
            flex: 4,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('เลขที่ : ${order.redeemId}',
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      'วันที่ : ${Global.formatDateNT(order.redeemDate.toString())}',
                      style: const TextStyle(fontSize: 11)),
                ])),
      ]);
}

Widget buyerSellerInfo(CustomerModel customer, OrderModel order) {
  // motivePrint(customer?.toJson());
  return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0, top: 4.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(24),
                },
                children: [
                  TableRow(
                    children: [
                      Text(
                          '${getNameTitle(order)} : ${getCustomerName(customer)}',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  if (getCustomerBillAddressLine1(customer).isNotEmpty)
                    TableRow(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ที่อยู่ : ',
                                style: const TextStyle(fontSize: 11)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getCustomerBillAddressLine1(customer),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  if (getCustomerBillAddressLine2(customer)
                                      .isNotEmpty)
                                    Text(
                                      getCustomerBillAddressLine2(customer),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              if (shouldShowWorkId(customer))
                Text(
                  getWorkId(customer),
                  style: const TextStyle(fontSize: 11),
                ),
            ],
          ),
        ),
        if (order.status == "2" || order.orderStatus == 'CANCEL')
          Container(
            width: 90,
            decoration: BoxDecoration(
              border: Border.all(
                color: PdfColors.black,
                width: 1.0,
              ),
              color: PdfColors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 0.0,
              ),
              child: Text(
                'ยกเลิก',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PdfColors.red,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Expanded(
            flex: 5,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Table(children: [
                TableRow(children: [
                  Text('ทองคําแท่งขายออกบาทละ : ',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      '${Global.format(order.details![0].sellTPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองคำแท่งรับซื้อบาทละ : ',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 11)),
                  Text('${Global.format(order.details![0].buyTPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองรูปพรรณฐานภาษีบาทละ : ',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 11)),
                  Text('${Global.format(order.details![0].buyPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองรูปพรรณฐานภาษีกรัมละ : ',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      '${Global.format((order.details![0].buyPrice ?? 0) / getUnitWeightValue(order.details![0].productId))} บาท',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 11)),
                ]),
              ]),
            ])),
      ]));
}

Widget buyerSellerInfoRedeem(
    CustomerModel customer, RedeemModel order, int productId) {
  return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    children: [
                      Text('ชื่อ-สกุลผู้ไถ่ถอน : ${getCustomerName(customer)}',
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  if (getCustomerBillAddressLine1(customer).isNotEmpty)
                    TableRow(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ที่อยู่ : ',
                                style: const TextStyle(fontSize: 11)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getCustomerBillAddressLine1(customer),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  if (getCustomerBillAddressLine2(customer)
                                      .isNotEmpty)
                                    Text(
                                      getCustomerBillAddressLine2(customer),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (shouldShowWorkId(customer))
                    TableRow(
                      children: [
                        Text(
                          getWorkId(customer),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        if (order.status == 2 || order.redeemStatus == 'CANCEL')
          Container(
            width: 90,
            decoration: BoxDecoration(
              border: Border.all(
                color: PdfColors.black,
                width: 1.0,
              ),
              color: PdfColors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 0.0,
              ),
              child: Text(
                'ยกเลิก',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PdfColors.red,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Expanded(
            flex: 5,
            child: Column(children: [
              Table(children: [
                TableRow(children: [
                  Text('ทองคําแท่งขายออกบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text('${Global.format(0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองคํารูปพรรณรับซื้อบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text('${Global.format(0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองคํารูปพรรณรับซื้อกรัมละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      '${Global.format((0) / getUnitWeightValue(productId))} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
              ]),
            ])),
      ]));
}

Widget buyerSellerInfoRefill(
    CustomerModel customer, OrderModel order, int productId) {
  // motivePrint(customer.toJson());
  return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    children: [
                      Text(
                          '${getNameTitle(order)} : ${getCustomerName(customer)}',
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  if (getCustomerBillAddressLine1(customer).isNotEmpty)
                    TableRow(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ที่อยู่ : ',
                                style: const TextStyle(fontSize: 11)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getCustomerBillAddressLine1(customer),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  if (getCustomerBillAddressLine2(customer)
                                      .isNotEmpty)
                                    Text(
                                      getCustomerBillAddressLine2(customer),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (shouldShowWorkId(customer))
                  Text(
                    getWorkId(customer),
                    style: const TextStyle(fontSize: 12),
                  ),
                if (order.orderTypeId == 5 || order.orderTypeId == 10)
                  Text('อ้างอิงเลขที่ใบกำกับภาษี : ${order.referenceNo}',
                      style: const TextStyle(fontSize: 11)),
                if (order.orderTypeId == 6 || order.orderTypeId == 11)
                  Text(
                      'อ้างอิงเลขที่ใบรับซื้อจากร้านค้าส่ง : ${order.referenceNo}',
                      style: const TextStyle(fontSize: 11)),
              ]),
            ],
          ),
        ),
        if (order.status == "2" || order.orderStatus == 'CANCEL')
          Container(
            width: 90,
            decoration: BoxDecoration(
              border: Border.all(
                color: PdfColors.black,
                width: 1.0,
              ),
              color: PdfColors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 0.0,
              ),
              child: Text(
                'ยกเลิก',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PdfColors.red,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Expanded(
            flex: 5,
            child: Column(children: [
              Table(children: [
                TableRow(children: [
                  Text('ทองคําแท่งขายออกบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text('${Global.format(order.sellTPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองคำแท่งรับซื้อบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      '${Global.format((order.sellTPrice ?? 0) > 0 ? (order.sellTPrice ?? 0) - 100 : 0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองรูปพรรณฐานภาษีบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text('${Global.format(order.buyPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองรูปพรรณฐานภาษีกรัมละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      '${Global.format((order.buyPrice ?? 0) / getUnitWeightValue(productId))} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
              ]),
            ])),
      ]));
}

Widget buyerSellerInfoSellUsedWholeSale(
    CustomerModel customer, OrderModel order, int productId) {
  return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 2.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    children: [
                      Text(
                          '${getNameTitle(order)} : ${getCustomerName(customer)}',
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  if (getCustomerBillAddressLine1(customer).isNotEmpty)
                    TableRow(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ที่อยู่ : ',
                                style: const TextStyle(fontSize: 11)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getCustomerBillAddressLine1(customer),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  if (getCustomerBillAddressLine2(customer)
                                      .isNotEmpty)
                                    Text(
                                      getCustomerBillAddressLine2(customer),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (shouldShowWorkId(customer))
                  Text(
                    getWorkId(customer),
                    style: const TextStyle(fontSize: 12),
                  ),
                if (order.orderTypeId == 5 || order.orderTypeId == 10)
                  Text('อ้างอิงเลขที่ใบกำกับภาษี : ${order.referenceNo}',
                      style: const TextStyle(fontSize: 11)),
                if (order.orderTypeId == 6 || order.orderTypeId == 11)
                  Text(
                      'อ้างอิงเลขที่ใบรับซื้อจากร้านค้าส่ง : ${order.referenceNo}',
                      style: const TextStyle(fontSize: 11)),
              ]),
            ],
          ),
        ),
        if (order.status == "2" || order.orderStatus == 'CANCEL')
          Container(
            width: 90,
            decoration: BoxDecoration(
              border: Border.all(
                color: PdfColors.black,
                width: 1.0,
              ),
              color: PdfColors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 0.0,
              ),
              child: Text(
                'ยกเลิก',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PdfColors.red,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Expanded(
            flex: 5,
            child: Column(children: [
              Table(children: [
                TableRow(children: [
                  Text('ทองคําแท่งขายออกบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text('${Global.format(order.sellTPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองคำแท่งรับซื้อบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      '${Global.format(order.sellTPrice! > 0 ? order.sellTPrice! - 100 : 0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองรูปพรรณฐานภาษีบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text('${Global.format(order.buyPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
                TableRow(children: [
                  Text('ทองรูปพรรณฐานภาษีกรัมละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      '${Global.format((order.buyPrice ?? 0) / getUnitWeightValue(productId))} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11)),
                ]),
              ]),
            ])),
      ]));
}

Widget buyerSellerInfoBuySellTheng(CustomerModel customer, OrderModel order) {
  // motivePrint(customer.toJson());
  return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    children: [
                      Text(
                          '${getNameTitle(order)} : ${getCustomerName(customer)}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  if (getCustomerBillAddressLine1(customer).isNotEmpty)
                    TableRow(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ที่อยู่ : ',
                                style: const TextStyle(fontSize: 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getCustomerBillAddressLine1(customer),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (getCustomerBillAddressLine2(customer)
                                      .isNotEmpty)
                                    Text(
                                      getCustomerBillAddressLine2(customer),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (shouldShowWorkId(customer))
                  Text(
                    getWorkId(customer),
                    style: const TextStyle(fontSize: 12),
                  ),
                if (order.orderTypeId == 5 || order.orderTypeId == 10)
                  Text('อ้างอิงเลขที่ใบกำกับภาษี : ${order.referenceNo}',
                      style: const TextStyle(fontSize: 12)),
                if (order.orderTypeId == 6 || order.orderTypeId == 11)
                  Text(
                      'อ้างอิงเลขที่ใบรับซื้อจากร้านค้าส่ง : ${order.referenceNo}',
                      style: const TextStyle(fontSize: 12)),
              ]),
            ],
          ),
        ),
        if (order.status == "2" || order.orderStatus == 'CANCEL')
          Container(
            width: 90,
            decoration: BoxDecoration(
              border: Border.all(
                color: PdfColors.black,
                width: 1.0,
              ),
              color: PdfColors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 0.0,
              ),
              child: Text(
                'ยกเลิก',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PdfColors.red,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Expanded(
            flex: 5,
            child: Column(children: [
              Table(children: [
                TableRow(children: [
                  Text('ทองคําแท่งขายออกบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12)),
                  Text(
                      '${Global.format(order.details![0].sellTPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12)),
                ]),
                TableRow(children: [
                  Text('ทองคำแท่งรับซื้อบาทละ : ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12)),
                  Text('${Global.format(order.details![0].buyTPrice ?? 0)} บาท',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12)),
                ]),
              ]),
            ])),
      ]));
}

String getNameTitle(OrderModel order) {
  switch (order.orderTypeId) {
    case 1:
    case 3:
    case 4:
    case 6:
    case 8:
      return "ชื่อผู้ซื้อ";
    case 2:
    case 5:
    case 9:
    case 33:
    case 44:
      return "ชื่อผู้ขาย";
    default:
      return "ชื่อ";
  }
}

Widget getThongThengTable(OrderModel order) {
  return Column(children: [
    Table(border: TableBorder.all(color: PdfColors.grey500), children: [
      TableRow(children: [
        if (order.orderTypeId == 3 || order.orderTypeId == 33)
          paddedText('วันที่จองราคา', align: TextAlign.center),
        paddedText('รายการสินค้า', align: TextAlign.center),
        paddedText('ราคาบาทต่อทอง', align: TextAlign.center),
        paddedText('หน่วย(บาททอง)', align: TextAlign.center),
        paddedText('จำนวนเงิน (บาท)', align: TextAlign.center),
      ]),
      ...order.details!.map((e) => TableRow(children: [
            if (order.orderTypeId == 3 || order.orderTypeId == 33)
              paddedText(e.bookDate != null
                  ? Global.formatDate(e.bookDate.toString())
                  : ""),
            paddedText(
              e.productName,
              align: TextAlign.center,
            ),
            paddedText(
              Global.format((e.priceIncludeTax! / e.weight!) *
                  getUnitWeightValue(e.productId)),
              align: TextAlign.right,
            ),
            paddedText(
              Global.format(e.weight!),
              align: TextAlign.right,
            ),
            paddedText(
              Global.format(e.priceIncludeTax!),
              align: TextAlign.right,
            ),
          ])),
    ]),
  ]);
}

Widget getThongThengPaymentInfo(
        OrderModel order, List<PaymentModel> payments) =>
    Table(children: [
      for (int i = 0; i < payments.length; i++)
        TableRow(
          children: [
            Text('${i + 1})  ${getPaymentType(payments[i].paymentMethod)}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            Text('${Global.format(payments[i].amount ?? 0)} บาท'),
            Text('วันที่'),
            Text(Global.formatDateNT(payments[i].paymentDate.toString())),
          ],
        ),
    ]);

Widget getThongThengSignatureInfo(CustomerModel customer, int orderTypeId) =>
    Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          paddedText('ผู้รับซื้อทอง/รับทอง',
              style: TextStyle(fontWeight: FontWeight.bold)),
          paddedText('ผู้ขายทอง/ส่งมอบทอง',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (orderTypeId == 33 || orderTypeId == 44)
            Expanded(
              child: Center(
                child: Text('${Global.company?.name}'),
              ),
            ),
          if (orderTypeId == 3 || orderTypeId == 4)
            Expanded(
              child: Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
            ),
          SizedBox(width: 80),
          if (orderTypeId == 33 || orderTypeId == 44)
            Expanded(
              child: Divider(
                height: 1,
                borderStyle: BorderStyle.dashed,
              ),
            ),
          if (orderTypeId == 3 || orderTypeId == 4)
            Expanded(
              child: Center(
                child: Text('${Global.company?.name}'),
              ),
            )
        ],
      ),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(children: [
              Text('('),
              Expanded(
                child: Divider(
                  height: 1,
                  borderStyle: BorderStyle.dashed,
                ),
              ),
              if (orderTypeId == 33 || orderTypeId == 44)
                Text('${Global.user?.firstName} ${Global.user?.lastName}'),
              Expanded(
                child: Divider(
                  height: 1,
                  borderStyle: BorderStyle.dashed,
                ),
              ),
              Text(')'),
            ]),
          ),
          SizedBox(width: 80),
          Expanded(
            child: Row(children: [
              Text('('),
              Expanded(
                child: Divider(
                  height: 1,
                  borderStyle: BorderStyle.dashed,
                ),
              ),
              if (orderTypeId == 3 || orderTypeId == 4)
                Text('${Global.user?.firstName} ${Global.user?.lastName}'),
              Expanded(
                child: Divider(
                  height: 1,
                  borderStyle: BorderStyle.dashed,
                ),
              ),
              Text(')'),
            ]),
          ),
        ],
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(children: [Text('วันที่ : '), Text('')]),
          ),
          Spacer(),
          Expanded(
            child: Row(children: [Text('วันที่ : '), Text('')]),
          ),
        ],
      ),
      SizedBox(height: 10),
    ]);

Widget reportsHeader() => Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ที่อยู่ : "),
                Expanded(
                  child: Text(getFullAddress()),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
                "เลขประจําตัวผู้เสียภาษี : ${Global.company?.taxNumber ?? ''}",
                textAlign: TextAlign.right),
          )
        ],
      ),
    ]);

Widget reportsCompanyTitle() => Center(
      child: Text(
        Global.branch!.isHeadquarter == true
            ? '${Global.company!.name} (สำนักงานใหญ่)'
            : Global.company!.name,
        style: const TextStyle(decoration: TextDecoration.none, fontSize: 20),
      ),
    );

String getFullAddress() {
  // Return empty string if branch is null
  if (Global.branch == null) {
    return "";
  }

  String address = "";
  if (Global.branch?.address != null && Global.branch!.address!.isNotEmpty) {
    address += 'เลขที่${Global.branch!.address} ';
  }
  if (Global.branch?.building != null && Global.branch!.building!.isNotEmpty) {
    address += 'อาคาร${Global.branch!.building} ';
  }
  if (Global.branch?.room != null && Global.branch!.room!.isNotEmpty) {
    address += 'ห้องเลขที่${Global.branch!.room} ';
  }
  if (Global.branch?.floor != null && Global.branch!.floor!.isNotEmpty) {
    address += 'ชั้นที่${Global.branch!.floor} ';
  }

  if (Global.branch?.village != null && Global.branch!.village!.isNotEmpty) {
    address += 'หมู่บ้าน${Global.branch!.village} ';
  }
  if (Global.branch?.villageNo != null &&
      Global.branch!.villageNo!.isNotEmpty) {
    address += 'หมู่ที่${Global.branch!.villageNo} ';
  }

  if (Global.branch?.alley != null && Global.branch!.alley!.isNotEmpty) {
    address += 'ตรอก/ซอย${Global.branch!.alley} ';
  }
  if (Global.branch?.road != null && Global.branch!.road!.isNotEmpty) {
    address += 'ถนน${Global.branch!.road} ';
  }
  if (Global.branch?.provinceId == 1) {
    if (Global.branch?.tambonNavigation != null) {
      address += 'แขวง${Global.branch!.tambonNavigation?.nameTh} ';
    }
    if (Global.branch?.amphureNavigation != null) {
      address += '${Global.branch!.amphureNavigation?.nameTh} ';
    }
    if (Global.branch?.provinceNavigation != null) {
      address += '${Global.branch!.provinceNavigation?.nameTh} ';
    }
    return '$address ${Global.branch?.postalCode ?? ""}'; //'${Global.branch?.address} ${Global.branch?.village} ${Global.branch?.district} ${Global.branch?.province}';
  } else {
    if (Global.branch?.tambonNavigation != null) {
      address += 'ตำบล${Global.branch!.tambonNavigation?.nameTh} ';
    }
    if (Global.branch?.amphureNavigation != null) {
      address += 'อำเภอ${Global.branch!.amphureNavigation?.nameTh} ';
    }
    if (Global.branch?.provinceNavigation != null) {
      address += 'จังหวัด${Global.branch!.provinceNavigation?.nameTh} ';
    }
    return '$address ${Global.branch?.postalCode ?? ""}';
  }
}

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
