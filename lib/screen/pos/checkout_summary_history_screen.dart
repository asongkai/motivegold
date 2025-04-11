import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/price_breakdown.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';

class CheckOutSummaryHistoryScreen extends StatefulWidget {
  const CheckOutSummaryHistoryScreen({super.key});

  @override
  State<CheckOutSummaryHistoryScreen> createState() =>
      _CheckOutSummaryHistoryScreenState();
}

class _CheckOutSummaryHistoryScreenState
    extends State<CheckOutSummaryHistoryScreen> {
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  TextEditingController paymentMethodCtrl = TextEditingController();
  bool loading = false;
  List<OrderModel> orders = [];
  double discount = 0;
  CustomerModel? customer;
  Screen? size;

  @override
  void initState() {
    // implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
      orders = [];
      customer = null;
      discount = 0;
    });
    try {
      var resultO = await ApiServices.post(
          '/order/print-order-list/${Global.pairId}', Global.requestObj(null));

      var data = jsonEncode(resultO?.data);
      orders = orderListModelFromJson(data);

      var payment = await ApiServices.post(
          '/order/payment/${Global.pairId}', Global.requestObj(null));

      if (resultO?.status == "success") {
        setState(() {
          customer = orders.first.customer;
          Global.paymentList =
              paymentListModelFromJson(jsonEncode(payment?.data));
          Global.currentPaymentMethod = Global.payment?.paymentMethod;

          paymentMethodCtrl.text = paymentTypes()
              .where((element) => element.code == Global.currentPaymentMethod)
              .first
              .name!;
          Global.paymentDateCtrl.text =
              Global.formatDateD(Global.payment!.paymentDate.toString());
          if (Global.currentPaymentMethod == 'TR') {
            Global.bankCtrl.text = Global.payment!.bankName ?? '';
            Global.refNoCtrl.text = Global.payment!.referenceNumber ?? '';
          } else if (Global.currentPaymentMethod == 'CR') {
            Global.cardNameCtrl.text = Global.payment!.cardName ?? '';
            Global.cardExpireDateCtrl.text =
                Global.formatDateD(Global.payment!.cardExpiryDate.toString());
          } else {
            Global.paymentDetailCtrl.text = Global.payment!.paymentDetail ?? '';
          }
          discountCtrl.text = Global.format(orders.first.discount ?? 0);
          discount = orders.first.discount ?? 0;
        });
      } else {
        orders = [];
      }
    } catch (e) {
      motivePrint(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายละเอียดบิล",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: loading
              ? const Center(child: LoadingProgress())
              : orders.isEmpty
                  ? const Center(
                      child: NoDataFoundWidget(),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        getProportionateScreenWidth(8.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ลูกค้า',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 25),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.grey.withOpacity(.1),
                                                blurRadius: 1,
                                                spreadRadius: 1,
                                                offset: const Offset(2, 2),
                                              ),
                                            ]),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "${customer!.firstName} ${customer!.lastName}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        size!.getWidthPx(6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "${customer!.phoneNumber}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                                fontSize: size!.getWidthPx(6),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "${customer!.email}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                                fontSize: size!.getWidthPx(6),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "${customer!.address}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: size!.getWidthPx(6),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "${getIdTitleCustomer(customer)}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: size!.getWidthPx(6),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "${customer?.customerType == 'company' ? customer?.taxNumber : customer?.idCard}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: size!.getWidthPx(6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'รายการสั่งซื้อ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                          color: bgColor,
                                        ),
                                        child: Column(
                                          children: [
                                            ...orders.map((e) {
                                              return _itemOrderList(
                                                  order: e, index: 0);
                                            }),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'ราคา',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      buildTextFieldBig(
                                          labelText: "ส่วนลด (บาทไทย)",
                                          labelColor: Colors.orange,
                                          controller: discountCtrl,
                                          inputType: TextInputType.phone,
                                          enabled: false,
                                          inputFormat: [
                                            ThousandsFormatter(
                                                allowFraction: true)
                                          ],
                                          onChanged: (value) {
                                            discount = value.isNotEmpty
                                                ? Global.toNumber(value)
                                                : 0;
                                            setState(() {});
                                          }),
                                      PriceBreakdown(
                                        title: 'จำนวนเงินที่ชำระ'.tr(),
                                        price:
                                            '${Global.format(Global.getPaymentTotal(orders))} THB',
                                      ),
                                      const Divider(),
                                      PriceBreakdown(
                                        title: 'ใครจ่ายให้ใครเท่าไร'.tr(),
                                        price:
                                            '${Global.getPayTittle(Global.getPaymentTotal(orders))} ${Global.payToCustomerOrShop(orders, orders[0].discount ?? 0)}',
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'วิธีการชำระเงิน'.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      if (Global.paymentList!.isNotEmpty)
                                        SizedBox(
                                          height: 300,
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                    left: BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                    right: BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                    top: BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text('ลำดับ',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: size
                                                                ?.getWidthPx(8),
                                                            color:
                                                                kPrimaryGreen,
                                                          )),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          'วิธีการชำระเงิน',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: size
                                                                ?.getWidthPx(8),
                                                            color:
                                                                kPrimaryGreen,
                                                          )),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          'วันที่ชำระเงิน',
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                            fontSize: size
                                                                ?.getWidthPx(8),
                                                            color:
                                                                kPrimaryGreen,
                                                          )),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text('จำนวนเงิน',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                              fontSize: size
                                                                  ?.getWidthPx(
                                                                      8),
                                                              color:
                                                                  kPrimaryGreen,
                                                            )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: ListView.builder(
                                                    itemCount: Global
                                                        .paymentList!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return _paymentItemList(
                                                          order: Global
                                                                  .paymentList![
                                                              index],
                                                          index: index);
                                                    }),
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: bgColor,
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                    left: BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                    right: BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                    top: BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text('',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: size
                                                                  ?.getWidthPx(
                                                                      8),
                                                              color:
                                                                  kPrimaryGreen,
                                                            )),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text('',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: size
                                                                  ?.getWidthPx(
                                                                      8),
                                                              color:
                                                                  kPrimaryGreen,
                                                            )),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text('ทั้งหมด',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                              fontSize: size
                                                                  ?.getWidthPx(
                                                                      12),
                                                              color:
                                                                  kPrimaryGreen,
                                                            )),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              '${Global.format(Global.getPaymentTotal(orders))}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: size
                                                                    ?.getWidthPx(
                                                                        12),
                                                                color:
                                                                    kPrimaryGreen,
                                                              )),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text('',
                                                            style: TextStyle(
                                                              fontSize: size
                                                                  ?.getWidthPx(
                                                                      8),
                                                              color:
                                                                  kPrimaryGreen,
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      SizedBox(
                                        height: Global.paymentAttachment == null
                                            ? 100
                                            : 0,
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _paymentItemList({required PaymentModel order, required index}) {
    // motivePrint(Global.formatDateNT(order.paymentDate.toString()));
    // motivePrint(order.paymentDate.toString());
    return Container(
      decoration: const BoxDecoration(
        color: snBgColorLight,
        border: Border(
          bottom: BorderSide(
            color: Colors.white,
            width: 2,
          ),
          left: BorderSide(
            color: Colors.white,
            width: 2,
          ),
          right: BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text('${index + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size?.getWidthPx(8),
                    color: kPrimaryGreen,
                  )),
            ),
            Expanded(
              flex: 3,
              child: Text(order.paymentMethod ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size?.getWidthPx(8),
                    color: kPrimaryGreen,
                  )),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(Global.formatDateNT(order.paymentDate.toString()),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: size?.getWidthPx(8),
                      color: kPrimaryGreen,
                    )),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(Global.format(order.amount ?? 0),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: size?.getWidthPx(8),
                      color: kPrimaryGreen,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemOrderList({required OrderModel order, required index}) {
    // motivePrint(index);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 8,
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        '${getOrderListTitle(order)}',
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      )),
                      Expanded(
                          child: Text(
                        '${Global.format(Global.getOrderTotalAmount(order.details!))} บาท',
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ))
                    ],
                  )),
            ],
          ),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(4),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(3),
              4: FlexColumnWidth(4),
            },
            children: [
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('น้ำหนัก',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: size?.getWidthPx(8))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('ราคา',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: size?.getWidthPx(8))),
                  ),
                ],
              ),
              for (int j = 0; j < order.details!.length; j++)
                TableRow(
                  decoration: const BoxDecoration(),
                  children: [
                    paddedTextBigL('${j + 1}',
                        style: TextStyle(fontSize: size?.getWidthPx(8)),
                        align: TextAlign.center),
                    paddedTextBigL(order.details![j].productName,
                        style: TextStyle(fontSize: size?.getWidthPx(8))),
                    paddedTextBigL(Global.format(order.details![j].weight!),
                        align: TextAlign.right,
                        style: TextStyle(fontSize: size?.getWidthPx(8))),
                    paddedTextBigL(
                        Global.format(order.details![j].priceIncludeTax!) +
                            '  บาท',
                        align: TextAlign.right,
                        style: TextStyle(
                          fontSize: size?.getWidthPx(8),
                        )),
                  ],
                ),
            ],
          ),
          if (index < Global.ordersPapun!.length - 1)
            Container(
              height: 10,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
