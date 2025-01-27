import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/number_to_thai.dart';
import 'package:motivegold/utils/util.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

Widget divider() {
  return Divider(
    height: 1,
    borderStyle: BorderStyle.dashed,
  );
}

Widget height({double h = 10}) {
  return SizedBox(height: h);
}

Widget header(OrderModel order, String? title, {bool? showPosId}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(flex: 1, child: Center(child: Text('LOGO'))),
      Expanded(
          flex: 9,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${Global.company?.name} (${Global.branch!.name})',
                style: const TextStyle(fontSize: 9)),
            Text(
                '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}',
                style: const TextStyle(fontSize: 9)),
            Text('โทรศัพท์/Phone : ${Global.company?.phone} โทรสาร/Fax : ',
                style: const TextStyle(fontSize: 9)),
            Text(
                'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber}',
                style: const TextStyle(fontSize: 9)),
          ]))
    ]),
    SizedBox(
      height: 0,
    ),
    if (title != null)
      Center(
          child: Column(children: [
        Text(title, style: const TextStyle(fontSize: 9)),
        if (showPosId != null)
          Text('เลขรหัสประจําเครื่อง POS ID : ${Global.posIdModel?.posId}',
              style: const TextStyle(fontSize: 9))
      ])),
  ]);
}

Widget headerRefill(OrderModel order, String? title) {
  return Center(
      child: Column(children: [
    Text('${Global.company?.name}  (${Global.branch?.name})',
        style: const TextStyle(fontSize: 10)),
    if (title != null)
      Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
            if (order.orderTypeId == 5 || order.orderTypeId == 6)
              Text('เลขที่อ้างอิง : ${order.referenceNo}',
                  style: const TextStyle(fontSize: 9)),
          ],
        ),
        Text('วันที่ : ${Global.formatDate(DateTime.now().toString())} ',
            style: const TextStyle(fontSize: 9)),
      ]);
}

Widget buyerSellerInfo(CustomerModel customer, OrderModel order) {
  return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(children: [
        Expanded(
            child: Column(children: [
          Table(children: [
            TableRow(children: [
              Text('${getNameTitle(order)} : ',
                  style: const TextStyle(fontSize: 9)),
              Text('${customer.firstName} ${customer.lastName}',
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ที่อยู่ : ', style: const TextStyle(fontSize: 9)),
              Text(
                  '${customer.address}, ${customer.amphureId}, ${customer.provinceId}',
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text(''),
              Text(
                  'โทร: ${customer.phoneNumber}    ${customer.isCustomer == 1 ? 'หมายเลขบัตรประชาชน' : 'เลขประจําตัวผู้เสียภาษี'} : ${customer.taxNumber}',
                  style: const TextStyle(fontSize: 9)),
            ]),
          ]),
        ])),
        Expanded(
            child: Column(children: [
          Table(children: [
            TableRow(children: [
              Text('ทองคําแท่งขายออกบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(order.details![0].sellTPrice ?? 0)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคํารูปพรรณรับซื้อบาทละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text('${Global.format(order.details![0].buyPrice ?? 0)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
            ]),
            TableRow(children: [
              Text('ทองคํารูปพรรณรับซื้อกรัมละ : ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9)),
              Text(
                  '${Global.format((order.details![0].buyPrice ?? 0) / 15.16)}',
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
              Global.format((e.priceIncludeTax! / e.weight!) * 15.16),
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
