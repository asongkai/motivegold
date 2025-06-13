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
    {bool? showPosId}) async {
  // Load network image
  final Uint8List? imageData = await loadNetworkImage(
      '${Constants.DOMAIN_URL}/images/${Global.company?.logo}');

  final image = imageData != null ? MemoryImage(imageData) : null;

  // motivePrint(image?.bytes);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(
            flex: 2,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: image == null
                    ? Container()
                    : Image(image, fit: BoxFit.fitWidth, width: 60, height: 60),
              ),
            )),
        Expanded(
            flex: 9,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${Global.company?.name} (สาขา  ${Global.branch!.name})',
                  style: const TextStyle(fontSize: 9)),
              Text(
                  '${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}',
                  style: const TextStyle(fontSize: 9)),
              Text('โทรศัพท์/Phone : ${Global.branch?.phone}',
                  style: const TextStyle(fontSize: 9)),
              Text(
                  'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber} (สาขาที่ ${Global.branch?.branchId})',
                  style: const TextStyle(fontSize: 9)),
            ]))
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
                      style: const TextStyle(fontSize: 12)),
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                      width: 100, // Adjust the width as needed
                      height: 50, // Adjust the height as needed
                      decoration: BoxDecoration(
                        color: PdfColors.grey200, // Light gray background
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
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
              if (showPosId != null)
                Text(
                    'เลขรหัสประจําเครื่อง POS ID : ${Global.posIdModel?.posId}',
                    style: const TextStyle(fontSize: 9))
            ],
          ),
        ),
    ],
  );
}

Future<Widget> headerRedeem(RedeemModel order, String? title,
    {bool? showPosId}) async {
  // Load network image
  final Uint8List? imageData = await loadNetworkImage(
      '${Constants.DOMAIN_URL}/images/${Global.company?.logo}');

  final image = imageData != null ? MemoryImage(imageData) : null;

  // motivePrint(image?.bytes);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(children: [
        Expanded(
            flex: 2,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: image == null
                    ? Container()
                    : Image(image, fit: BoxFit.fitWidth, width: 60, height: 60),
              ),
            )),
        Expanded(
            flex: 9,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${Global.company?.name} (สาขา  ${Global.branch!.name})',
                  style: const TextStyle(fontSize: 12)),
              Text(
                  '${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}',
                  style: const TextStyle(fontSize: 9)),
              Text('โทรศัพท์/Phone : ${Global.branch?.phone}',
                  style: const TextStyle(fontSize: 9)),
              Text(
                  'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber} (สาขาที่ ${Global.branch?.branchId})',
                  style: const TextStyle(fontSize: 9)),
            ]))
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
                    flex: 5,
                    child: Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  Expanded(
                      flex: 3,
                      child: Container(
                          child: Text('เลขที่ : ${order.redeemId} '), alignment: Alignment.centerRight)),
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
    Text('${Global.company?.name}  (สาขา ${Global.branch?.name})',
        style: const TextStyle(fontSize: 10)),
    if (title != null)
      Row(children: [
        Expanded(flex: 2, child: Container()),
        Expanded(
          flex: 6,
          child: Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
            flex: 2,
            child: Container(
              width: 100, // Adjust the width as needed
              height: 50, // Adjust the height as needed
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
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('เลขที่ : ${order.orderId}',
                style: const TextStyle(fontSize: 9)),
            if (order.orderTypeId == 5 ||
                order.orderTypeId == 6 ||
                order.orderTypeId == 10 ||
                order.orderTypeId == 11)
              Text('เลขที่อ้างอิง : ${order.referenceNo}',
                  style: const TextStyle(fontSize: 9)),
          ],
        ),
        Text('วันที่ : ${Global.formatDateNT(order.orderDate.toString())} ',
            style: const TextStyle(fontSize: 9)),
      ]);
}

Widget docNoRedeem(RedeemModel order) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                'ชื่อ-สกุลผู้ไถ่ถอน : ${order.customer?.firstName} ${order.customer?.lastName}',
                style: const TextStyle(fontSize: 9)),
            Text('วันที่ : ${Global.formatDateNT(order.redeemDate.toString())}',
                style: const TextStyle(fontSize: 9)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ที่อยู่ : ${order.customer?.address} ',
                style: const TextStyle(fontSize: 9)),
            Text('เลขประจำตัว ผู้เสียภาษี : ${order.customer?.taxNumber}',
                style: const TextStyle(fontSize: 9)),
          ],
        ),

      ]);
}

Widget buyerSellerInfo(CustomerModel customer, OrderModel order) {
  return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(children: [
        Expanded(
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    children: [
                      Text('${getNameTitle(order)} : ',
                          style: const TextStyle(fontSize: 9)),
                      Text('${customer.firstName} ${customer.lastName}',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text('ที่อยู่ : ', style: const TextStyle(fontSize: 9)),
                      Text(
                          '${customer.address} รหัสไปรษณีย์: ${customer.postalCode}',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(''),
                      Text(
                          'โทร: ${customer.phoneNumber} ${getWorkId(customer)} ',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
            child: Column(children: [
          Table(children: [
            TableRow(children: [
              Text('ทองคําแท่งขายออกบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(order.details![0].sellTPrice ?? 0)} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคํารูปพรรณรับซื้อบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(order.details![0].buyPrice ?? 0)} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคํารูปพรรณรับซื้อกรัมละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text(
                  '${Global.format((order.details![0].buyPrice ?? 0) / getUnitWeightValue())} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
          ]),
        ])),
      ]));
}

Widget buyerSellerInfoRedeem(CustomerModel customer, RedeemModel order) {
  return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(children: [
        Expanded(
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    children: [
                      Text('ชื่อ-สกุลผู้ไถ่ถอน : ',
                          style: const TextStyle(fontSize: 9)),
                      Text('${customer.firstName} ${customer.lastName}',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text('ที่อยู่ : ', style: const TextStyle(fontSize: 9)),
                      Text(
                          '${customer.address} รหัสไปรษณีย์: ${customer.postalCode}',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(''),
                      Text(
                          'โทร: ${customer.phoneNumber} ${getWorkId(customer)} ',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
            child: Column(children: [
          Table(children: [
            TableRow(children: [
              Text('ทองคําแท่งขายออกบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(0)} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคํารูปพรรณรับซื้อบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(0)} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคํารูปพรรณรับซื้อกรัมละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format((0) / getUnitWeightValue())} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
          ]),
        ])),
      ]));
}

Widget buyerSellerInfoRefill(CustomerModel customer, OrderModel order) {
  // motivePrint(customer.toJson());
  return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(children: [
        Expanded(
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    children: [
                      Text('${getNameTitle(order)} : ',
                          style: const TextStyle(fontSize: 9)),
                      Text('${customer.firstName} ${customer.lastName}',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text('ที่อยู่ : ', style: const TextStyle(fontSize: 9)),
                      Text(
                          '${customer.address} รหัสไปรษณีย์: ${customer.postalCode}',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(''),
                      Text(
                          'โทร: ${customer.phoneNumber} ${getWorkId(customer)} ',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
            child: Column(children: [
          Table(children: [
            TableRow(children: [
              Text('ทองคําแท่งขายออกบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(order.sellTPrice ?? 0)} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคํารูปพรรณรับซื้อบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(order.buyPrice ?? 0)} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคํารูปพรรณรับซื้อกรัมละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text(
                  '${Global.format((order.buyPrice ?? 0) / getUnitWeightValue())} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
          ]),
        ])),
      ]));
}

Widget buyerSellerInfoBuySellTheng(CustomerModel customer, OrderModel order) {
  // motivePrint(customer.toJson());
  return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(children: [
        Expanded(
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    children: [
                      Text('${getNameTitle(order)} : ',
                          style: const TextStyle(fontSize: 9)),
                      Text('${customer.firstName} ${customer.lastName}',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text('ที่อยู่ : ', style: const TextStyle(fontSize: 9)),
                      Text(
                          '${customer.address} รหัสไปรษณีย์: ${customer.postalCode}',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(''),
                      Text(
                          'โทร: ${customer.phoneNumber} ${getWorkId(customer)} ',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
            child: Column(children: [
          Table(children: [
            TableRow(children: [
              Text('ทองคําแท่งขายออกบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(order.details![0].sellTPrice ?? 0)} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคำแท่งรับซื้อบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(order.details![0].buyPrice ?? 0)} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคำแท่งรับซื้อกรัมละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text(
                  '${Global.format((order.details![0].buyPrice ?? 0) / getUnitWeightValue())} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
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
      return "ขายให้";
    case 2:
    case 5:
    case 9:
    case 33:
    case 44:
      return "รับซื้อจาก";
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
              Global.format(
                  (e.priceIncludeTax! / e.weight!) * getUnitWeightValue()),
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
