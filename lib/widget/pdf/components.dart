import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/number_to_thai.dart';
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

Widget header(OrderModel order, String? title) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(flex: 2, child: Center(child: Text('LOGO'))),
      Expanded(
          flex: 8,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${Global.company?.name} (${Global.branch!.name})',
                style: const TextStyle(fontSize: 16)),
            Text(
                '${Global.company?.address}, ${Global.company?.village}, ${Global.company?.district}, ${Global.company?.province}'),
            Text('โทรศัพท์/Phone : ${Global.company?.phone} โทรสาร/Fax : '),
            Text(
                'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber}'),
          ]))
    ]),
    SizedBox(
      height: 10,
    ),
    if (title != null)
      Center(
          child: Column(children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        Text('เลขรหัสประจําเครื่อง POS ID : A0120000000X000',
            style: const TextStyle(fontSize: 12))
      ])),
  ]);
}

Widget headerRefill(CustomerModel customer, OrderModel order, String? title) {
  return Center(
      child: Column(children: [
    Text('${customer.firstName} ${customer.lastName} (สำนักงานใหญ่)',
        style: const TextStyle(fontSize: 16)),
    Text('${customer.address} ${customer.amphureId} ${customer.provinceId}'),
    Text(
        'โทร: ${customer.phoneNumber}    เลขประจําตัวผู้เสียภาษี : ${customer.taxNumber}'),
    if (title != null) Text(title, style: const TextStyle(fontSize: 16)),
  ]));
}

Widget docNo(OrderModel order) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('เลขที่ : ${order.orderId}'),
        Text('วันที่ : ${Global.formatDate(DateTime.now().toString())} '),
      ]);
}

Widget buyerSellerInfo(CustomerModel customer, OrderModel order) {
  return Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
          '${getNameTitle(order)} : ${customer.firstName} ${customer.lastName}'),
      Text('เลขที่ : ${order.orderId}'),
    ]),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
          'โทร: ${customer.phoneNumber}    ${customer.isCustomer == 1 ? 'หมายเลขบัตรประชาชน' : 'เลขประจําตัวผู้เสียภาษี'} : ${customer.taxNumber}'),
      Text('วันที่ : ${Global.formatDate(DateTime.now().toString())} '),
    ]),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('ที่อยู่ : '),
      if (order.orderTypeId == 3 ||
          order.orderTypeId == 4 ||
          order.orderTypeId == 33 ||
          order.orderTypeId == 44 ||
          order.orderTypeId == 9)
        Text('อ้างถึงเอกสาร : ${order.orderId}'),
    ]),
    Row(children: [
      Expanded(
          flex: 8,
          child: Text(
              '${customer.address}, ${customer.amphureId}, ${customer.provinceId}')),
      SizedBox(width: 30),
      Expanded(flex: 3, child: Container())
    ])
  ]);
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

Widget getThongThengPaymentInfo(OrderModel order, PaymentModel payment) =>
    Table(children: [
      TableRow(
        children: [
          Text('1)  เงินสด',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text('${Global.format(Global.getOrderTotal(order))}'),
          Text('บาท'),
          Text(''),
          Text('วันที่'),
          Text(payment.paymentMethod == 'CA'
              ? Global.formatDateM(payment.paymentDate.toString())
              : ''),
        ],
      ),
      TableRow(children: [
        Container(
            child: Text('2)  โอนเข้าบัญชีธนาคาร',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        Container(child: Text('${payment.bankName}')),
        Container(child: Text('เลขที่ ')),
        Text('${payment.referenceNumber}'),
        Text('วันที่'),
        Container(
            child: Text(payment.paymentMethod == 'TR'
                ? Global.formatDateM(payment.paymentDate.toString())
                : ''))
      ]),
      TableRow(children: [
        Text('3)  อื่นๆ',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(payment.paymentMethod == 'OTH' ? '${payment.paymentDetail}' : ''),
        Text(''),
        Text(''),
        Text('วันที่'),
        Text(payment.paymentMethod == 'OTH'
            ? Global.formatDateM(payment.paymentDate.toString())
            : '')
      ])
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
