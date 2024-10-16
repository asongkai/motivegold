import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/response.dart' as rs;
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/image/cached_image.dart';
import 'package:motivegold/widget/price_breakdown.dart';
import 'package:motivegold/widget/product_list_tile.dart';
import 'package:pattern_formatter/numeric_formatter.dart';

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
      rs.Response? result;
      rs.Response? payment;
      if (Global.pairId == null) {
        result = await ApiServices.post(
            '/order/order-list', encoder.convert(Global.orderIds));
      } else {
        result = await ApiServices.post(
            '/order/print-order-list/${Global.pairId}',
            Global.requestObj(null));
        payment = await ApiServices.post(
            '/order/payment/${Global.pairId}', Global.requestObj(null));
      }
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> dump = orderListModelFromJson(data);
        setState(() {
          orders = dump;
          orders = orders;
          customer = orders.first.customer;
          // motivePrint(payment?.data);
          Global.payment = PaymentModel.fromJson(payment?.data);
          Global.currentPaymentMethod = Global.payment?.paymentMethod;
          motivePrint(Global.currentPaymentMethod);
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
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: Text('เช็คเอาท์'.tr()),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: orders.isEmpty
              ? const Center(
                  child: EmptyContent(),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: getProportionateScreenWidth(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(.1),
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                      borderRadius: BorderRadius.circular(0),
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
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, right: 8.0),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              buildTextFieldBig(
                                                  labelText:
                                                      'วิธีการชำระเงิน'.tr(),
                                                  validator: null,
                                                  inputType: TextInputType.text,
                                                  controller: paymentMethodCtrl,
                                                  enabled: false),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (Global.currentPaymentMethod == 'TR')
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                buildTextFieldBig(
                                                    labelText:
                                                        'โอนเข้าบัญชีธนาคาร'
                                                            .tr(),
                                                    validator: null,
                                                    inputType:
                                                        TextInputType.text,
                                                    controller: Global.bankCtrl,
                                                    enabled: false),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                buildTextFieldBig(
                                                    labelText:
                                                        'เลขที่อ้างอิง'.tr(),
                                                    validator: null,
                                                    inputType:
                                                        TextInputType.text,
                                                    controller:
                                                        Global.refNoCtrl,
                                                    enabled: false),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (Global.currentPaymentMethod == 'CR')
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                buildTextFieldBig(
                                                    labelText:
                                                        'ชื่อบนบัตร'.tr(),
                                                    validator: null,
                                                    inputType:
                                                        TextInputType.text,
                                                    controller:
                                                        Global.cardNameCtrl,
                                                    enabled: false),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                top: 8.0),
                                            child: TextField(
                                              controller:
                                                  Global.cardExpireDateCtrl,
                                              //editing controller of this TextField
                                              style:
                                                  const TextStyle(fontSize: 35),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.calendar_today),
                                                //icon of text field
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior
                                                        .always,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3.0,
                                                        horizontal: 10.0),
                                                labelText:
                                                    "วันหมดอายุบัตร".tr(),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    getProportionateScreenWidth(
                                                        8),
                                                  ),
                                                  borderSide: const BorderSide(
                                                    color: kGreyShade3,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    getProportionateScreenWidth(
                                                        2),
                                                  ),
                                                  borderSide: const BorderSide(
                                                    color: kGreyShade3,
                                                  ),
                                                ),
                                              ),
                                              readOnly: true,
                                              enabled: false,
                                              //set it true, so that user will not able to edit text
                                              onTap: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(1990),
                                                        //DateTime.now() - not to allow to choose before today.
                                                        lastDate:
                                                            DateTime(2101));
                                                if (pickedDate != null) {
                                                  motivePrint(
                                                      pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                  String formattedDate =
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(pickedDate);
                                                  motivePrint(
                                                      formattedDate); //formatted date output using intl package =>  2021-03-16
                                                  //you can implement different kind of Date Format here according to your requirement
                                                  setState(() {
                                                    Global.cardExpireDateCtrl
                                                            .text =
                                                        formattedDate; //set output date to TextField value.
                                                  });
                                                } else {
                                                  motivePrint(
                                                      "Date is not selected");
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  if (Global.currentPaymentMethod != null)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: TextField(
                                              controller:
                                                  Global.paymentDateCtrl,
                                              //editing controller of this TextField
                                              style:
                                                  const TextStyle(fontSize: 38),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.calendar_today),
                                                //icon of text field
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior
                                                        .always,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                                labelText:
                                                    "วันที่จ่ายเงิน".tr(),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    getProportionateScreenWidth(
                                                        8),
                                                  ),
                                                  borderSide: const BorderSide(
                                                    color: kGreyShade3,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    getProportionateScreenWidth(
                                                        2),
                                                  ),
                                                  borderSide: const BorderSide(
                                                    color: kGreyShade3,
                                                  ),
                                                ),
                                              ),
                                              readOnly: true,
                                              enabled: false,
                                              //set it true, so that user will not able to edit text
                                              onTap: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(1990),
                                                        //DateTime.now() - not to allow to choose before today.
                                                        lastDate:
                                                            DateTime(2101));
                                                if (pickedDate != null) {
                                                  motivePrint(
                                                      pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                  String formattedDate =
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(pickedDate);
                                                  motivePrint(
                                                      formattedDate); //formatted date output using intl package =>  2021-03-16
                                                  //you can implement different kind of Date Format here according to your requirement
                                                  setState(() {
                                                    Global.paymentDateCtrl
                                                            .text =
                                                        formattedDate; //set output date to TextField value.
                                                  });
                                                } else {
                                                  motivePrint(
                                                      "Date is not selected");
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (Global.currentPaymentMethod == 'OTH')
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                buildTextFieldBig(
                                                    line: 2,
                                                    labelText:
                                                        'รายละเอียด'.tr(),
                                                    validator: null,
                                                    inputType:
                                                        TextInputType.text,
                                                    controller: Global
                                                        .paymentDetailCtrl,
                                                    enabled: false),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (Global.payment!.attachement != null)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'สลิปการชำระเงิน'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                    ),
                                  if (Global.payment!.attachement != null)
                                    CachedImage(
                                      '${Constants.DOMAIN_URL}/Uploads/${Global.payment!.attachement}',
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  Divider(
                                    height: getProportionateScreenHeight(56),
                                  ),
                                  Text(
                                    'ราคา',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  buildTextFieldBig(
                                      labelText: "ส่วนลด (บาทไทย)",
                                      textColor: Colors.orange,
                                      controller: discountCtrl,
                                      inputType: TextInputType.phone,
                                      enabled: false,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
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
                                        '${formatter.format(getPaymentTotal())} THB',
                                  ),
                                  const Divider(),
                                  PriceBreakdown(
                                    title: 'ใครจ่ายให้ใครเท่าไร'.tr(),
                                    price: '${payToCustomerOrShop()}',
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

  double getPaymentTotal() {
    if (orders.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < orders.length; i++) {
      for (int j = 0; j < orders[i].details!.length; j++) {
        double price = orders[i].details![j].priceIncludeTax!;
        int type = orders[i].orderTypeId!;
        if (type == 2) {
          price = -price;
        }
        amount += price;
      }
    }
    amount = discount != 0 ? amount - discount : amount;
    return amount < 0 ? -amount : amount;
  }

  dynamic payToCustomerOrShop() {
    if (orders.isEmpty) {
      return 0;
    }
    double amount = 0;
    double buy = 0;
    double sell = 0;
    for (int i = 0; i < orders.length; i++) {
      for (int j = 0; j < orders[i].details!.length; j++) {
        double price = orders[i].details![j].priceIncludeTax!;
        int type = orders[i].orderTypeId!;
        if (type == 2) {
          buy += -price;
        }
        if (type == 1) {
          sell += price;
        }
      }
    }
    amount = sell + buy;

    amount = discount != 0 ? amount - discount : amount;
    return amount > 0
        ? 'ลูกค้าจ่ายเงินให้กับเรา ${formatter.format(amount)} THB'
        : amount == 0
            ? '0'
            : 'เราจ่ายเงินให้กับลูกค้า ${formatter.format(-amount)} THB';
  }

  Widget _itemOrderList({required OrderModel order, required index}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 8,
              child: ListTile(
                title: ProductListTileData(
                  orderId: order.orderId,
                  weight:
                  Global.format(Global.getOrderTotalWeight(order.details!)),
                  showTotal: true,
                  totalPrice:
                  Global.format(Global.getOrderTotalAmount(order.details!)),
                  type: order.orderTypeName.toString(),
                ),
              ),
            ),
          ],
        ),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
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
            ...order.details!.map((e) => TableRow(
              decoration: const BoxDecoration(),
              children: [
                paddedTextBigL(e.productName,
                    style: TextStyle(fontSize: size?.getWidthPx(8))),
                paddedTextBigL(Global.format(e.weight!),
                    align: TextAlign.center,
                    style: TextStyle(fontSize: size?.getWidthPx(8))),
                paddedTextBigL(Global.format(e.priceIncludeTax!),
                    align: TextAlign.center,
                    style: TextStyle(fontSize: size?.getWidthPx(8))),
              ],
            )),
          ],
        ),
      ],
    );
  }
}