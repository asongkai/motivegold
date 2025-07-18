import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/default/default_payment.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/screen/customer/add_customer_screen.dart';
import 'package:motivegold/screen/customer/customer_screen.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/refill/edit_refill_gold_stock_screen.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/used/edit_sell_used_gold_screen.dart';
import 'package:motivegold/screen/pos/wholesale/theng/refill/edit_refill_theng_gold_stock_screen.dart';
import 'package:motivegold/screen/pos/wholesale/theng/used/edit_sell_used_theng_gold_screen.dart';
import 'package:motivegold/screen/pos/wholesale/wholesale_print_bill_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/payment/payment_method.dart';
import 'package:motivegold/widget/price_breakdown.dart';

import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sizer/sizer.dart';

class WholeSaleCheckOutScreen extends StatefulWidget {
  const WholeSaleCheckOutScreen({super.key});

  @override
  State<WholeSaleCheckOutScreen> createState() =>
      _WholeSaleCheckOutScreenState();
}

class _WholeSaleCheckOutScreenState extends State<WholeSaleCheckOutScreen> {
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  TextEditingController addPriceCtrl = TextEditingController();
  Screen? size;

  bool loading = false;
  DefaultPaymentModel? defaultPayment;

  @override
  void initState() {
    // implement initState
    super.initState();
    Global.discount = 0;
    Global.addPrice = 0;
    Global.customer = null;
    Global.selectedPayment = null;
    Global.currentPaymentMethod = null;
    Global.paymentAttachment = null;
    Global.cardNameCtrl.text = "";
    Global.cardExpireDateCtrl.text = "";
    Global.bankCtrl.text = "";
    Global.refNoCtrl.text = "";
    Global.paymentDateCtrl.text = Global.dateOnlyT(DateTime.now().toString());
    Global.paymentDetailCtrl.text = "";
    Global.paymentList?.clear();
    Global.checkOutMode = "O";
    loadDefaultPayment();
  }

  loadDefaultPayment() async {
    int orderTypeId = 0;
    if (Global.currentOrderType == 1) {
      if (Global.payToCustomerOrShopValue(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)) < 0) {
        orderTypeId = 2;
      } else {
        orderTypeId = 1;
      }
    }

    if (Global.currentOrderType == 2) {
      if (Global.payToCustomerOrShopValue(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)) < 0) {
        orderTypeId = 33;
      } else {
        orderTypeId = 3;
      }
    }

    if (Global.currentOrderType == 3) {
      if (Global.payToCustomerOrShopValue(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)) < 0) {
        orderTypeId = 44;
      } else {
        orderTypeId = 4;
      }
    }

    if (Global.currentOrderType == 4) {
      if (Global.payToCustomerOrShopValue(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)) < 0) {
        orderTypeId = 9;
      } else {
        orderTypeId = 8;
      }
    }

    if (Global.currentOrderType == 5) {
      if (Global.payToCustomerOrShopValue(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)) < 0) {
        orderTypeId = 5;
      } else {
        orderTypeId = 6;
      }
    }

    if (Global.currentOrderType == 6) {
      if (Global.payToCustomerOrShopValue(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)) < 0) {
        orderTypeId = 10;
      } else {
        orderTypeId = 11;
      }
    }

    var payment = await ApiServices.post(
        '/defaultpayment/by-order-type/$orderTypeId', Global.requestObj(null));
    motivePrint(payment?.toJson());
    if (payment?.status == "success") {
      var data = DefaultPaymentModel.fromJson(payment?.data);
      setState(() {
        defaultPayment = data;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Global.discount = 0;
    Global.addPrice = 0;
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("ชำระเงิน [ค้าส่ง]",
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
          child: Global.orders.isEmpty
              ? const Center(
                  child: NoDataFoundWidget(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ค้าส่ง',
                          style: Theme.of(context).textTheme.headlineMedium,
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
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 1,
                                  spreadRadius: 1,
                                  offset: const Offset(2, 2),
                                ),
                              ]),
                          child: Global.customer == null
                              ? Row(
                                  children: [
                                    Expanded(flex: 5, child: Container()),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: [
                                          KclButton(
                                            onTap: () {
                                              Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const AddCustomerScreen(),
                                                          fullscreenDialog:
                                                              true))
                                                  .whenComplete(() {
                                                setState(() {});
                                              });
                                            },
                                            text: 'เพิ่ม',
                                            fullWidth: true,
                                            icon: Icons.add,
                                          ),
                                          KclButton(
                                            onTap: () {
                                              Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const CustomerScreen(
                                                                selected: true,
                                                                type: "WS",
                                                              ),
                                                          fullscreenDialog:
                                                              true))
                                                  .whenComplete(() {
                                                setState(() {});
                                              });
                                            },
                                            text: 'ค้นหา',
                                            icon: Icons.search,
                                            fullWidth: true,
                                            color: Colors.teal,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${Global.customer!.firstName} ${Global.customer!.lastName}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                "${Global.customer!.phoneNumber}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                "${Global.customer!.email}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                "${Global.customer!.address}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                "${getIdTitleCustomer(Global.customer)}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                "${Global.customer?.customerType == 'company' ? Global.customer?.taxNumber : Global.customer?.idCard}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              KclButton(
                                                onTap: () {
                                                  Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const AddCustomerScreen(),
                                                              fullscreenDialog:
                                                                  true))
                                                      .whenComplete(() {
                                                    setState(() {});
                                                  });
                                                },
                                                text: 'เพิ่ม',
                                                fullWidth: true,
                                                icon: Icons.add,
                                              ),
                                              KclButton(
                                                onTap: () {
                                                  Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const CustomerScreen(
                                                                    selected:
                                                                        true,
                                                                    type: "WS",
                                                                  ),
                                                              fullscreenDialog:
                                                                  true))
                                                      .whenComplete(() {
                                                    setState(() {});
                                                  });
                                                },
                                                text: 'ค้นหา',
                                                icon: Icons.search,
                                                fullWidth: true,
                                                color: Colors.teal,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'รายการสั่งซื้อ',
                          style: Theme.of(context).textTheme.headlineMedium,
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
                              for (int i = 0; i < Global.orders.length; i++)
                                _itemOrderList(
                                    order: Global.orders[i], index: i)
                            ],
                          ),
                        ),
                        Text(
                          'ราคา',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        buildTextFieldBig(
                            labelText: "ส่วนลด (บาทไทย)",
                            labelColor: Colors.orange,
                            controller: discountCtrl,
                            inputType: TextInputType.phone,
                            inputFormat: [
                              ThousandsFormatter(allowFraction: true)
                            ],
                            onChanged: (value) {
                              Global.discount =
                                  value.isNotEmpty ? Global.toNumber(value) : 0;
                              setState(() {});
                            }),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            color: bgColor,
                          ),
                          child: Column(
                            children: [
                              PriceBreakdown(
                                title: 'จำนวนเงินที่ต้องชำระ'.tr(),
                                price:
                                    '${Global.format(Global.getPaymentTotalWholeSale(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)))} บาท',
                              ),
                              PriceBreakdown(
                                title: '${Global.getRefillPayTittle(Global.payToCustomerOrShopValueWholeSale(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)))}',
                                price:
                                    '${Global.payToCustomerOrShopWholeSale(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text))}',
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                            // height: getProportionateScreenHeight(5),
                            ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'วิธีการชำระเงิน'.tr(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: snBgColor,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                resetPaymentData();
                              });
                              paymentDialog();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 32),
                                SizedBox(width: 6),
                                Text(
                                  'เพิ่ม',
                                  style: TextStyle(fontSize: 32),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (Global.paymentList!.isNotEmpty)
                          SizedBox(
                            // height: 300,
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
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: kPrimaryGreen,
                                            )),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text('วิธีการชำระเงิน',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: kPrimaryGreen,
                                            )),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text('วันที่ชำระเงิน',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: kPrimaryGreen,
                                            )),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('จำนวนเงิน',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: kPrimaryGreen,
                                              )),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text('',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: kPrimaryGreen,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: Global.paymentList!.length,
                                    itemBuilder: (context, index) {
                                      return _paymentItemList(
                                          order: Global.paymentList![index],
                                          index: index);
                                    }),
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text('',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: kPrimaryGreen,
                                              )),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text('',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: kPrimaryGreen,
                                              )),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('ทั้งหมด',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                color: kPrimaryGreen,
                                              )),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                '${Global.format(getPaymentTotal())}',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize:
                                                      18.sp,
                                                  color: kPrimaryGreen,
                                                )),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: kPrimaryGreen,
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
                          height: Global.paymentAttachment == null ? 100 : 0,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
            height: 70,
            width: 150,
            child: ElevatedButton(
              style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.teal[700]!),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.teal[700]!)))),
              onPressed: () async {
                if (Global.customer == null) {
                  if (mounted) {
                    Alert.warning(
                        context, 'Warning'.tr(), 'กรุณากรอกลูกค้า', 'OK'.tr(),
                        action: () {});
                    return;
                  }
                }

                if (Global.paymentList!.isEmpty) {
                  if (mounted) {
                    Alert.warning(context, 'Warning'.tr(),
                        'กรุณาเพิ่มการชำระเงินก่อน', 'OK'.tr(),
                        action: () {});
                    return;
                  }
                }
                var amount = Global.payToCustomerOrShopValueWholeSale(
                    Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text));
                // // motivePrint(selectedOption);
                // if (amount > getMaxKycValue()) {
                //   if (selectedOption == 0 && Global.customer == null) {
                //     Alert.warning(
                //         context,
                //         'Warning'.tr(),
                //         'จำนวนเงินมากกว่า ${Global.format(getMaxKycValue())} กรุณาสำแดงตนข้อมูลลูกค้า',
                //         'OK'.tr(),
                //         action: () {});
                //     return;
                //   }
                //   if (selectedOption == 1) {
                //     Alert.warning(
                //         context,
                //         'Warning'.tr(),
                //         'จำนวนเงินมากกว่า ${Global.format(getMaxKycValue())} กรุณาสำแดงตนข้อมูลลูกค้า',
                //         'OK'.tr(),
                //         action: () {});
                //     return;
                //   }
                // }
                // motivePrint(Global.getPaymentTotalWholeSale(Global.orders));
                // motivePrint(getPaymentTotal());
                // return;
                if (getPaymentTotal() >
                    Global.toNumber(Global.format(
                        Global.getPaymentTotalWholeSale(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text))))) {
                  if (mounted) {
                    Alert.warning(
                        context,
                        'Warning'.tr(),
                        amount >= 0
                            ? 'ยอดชำระมากกว่าจำนวนเงินรวม'
                            : 'ยอดจ่ายมากกว่าจำนวนเงินรวม',
                        'OK'.tr(),
                        action: () {});
                    return;
                  }
                }

                if (getPaymentTotal() <
                    Global.toNumber(Global.format(
                        Global.getPaymentTotalWholeSale(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text))))) {
                  if (mounted) {
                    Alert.warning(
                        context,
                        'Warning'.tr(),
                        amount >= 0
                            ? 'ยอดชำระน้อยกว่าจำนวนเงินรวม'
                            : 'ยอดจ่ายน้อยกว่าจำนวนเงินรวม',
                        'OK'.tr(),
                        action: () {});
                    return;
                  }
                }

                for (var i = 0; i < Global.orders.length; i++) {
                  Global.orders[i].id = 0;
                  Global.orders[i].createdDate = DateTime.now();
                  Global.orders[i].updatedDate = DateTime.now();
                  Global.orders[i].customerId = Global.customer!.id!;
                  Global.orders[i].status = "0";
                  Global.orders[i].discount = Global.toNumber(discountCtrl.text);
                  Global.orders[i].addPrice = Global.toNumber(addPriceCtrl.text);
                  Global.orders[i].paymentMethod = Global.currentPaymentMethod;
                  // Global.orders[i].attachement = null;
                  for (var j = 0; j < Global.orders[i].details!.length; j++) {
                    Global.orders[i].details![j].id = 0;
                    Global.orders[i].details![j].orderId = Global.orders[i].id;
                    Global.orders[i].details![j].unitCost =
                        Global.orders[i].orderTypeId == 6
                            ? Global.orders[i].details![j].priceIncludeTax!
                            : Global.orders[i].details![j].priceExcludeTax! /
                                Global.orders[i].details![j].weight!;
                    Global.orders[i].details![j].createdDate = DateTime.now();
                    Global.orders[i].details![j].updatedDate = DateTime.now();
                  }
                }

                // Global.printLongString(Global.orders[0].toJson().toString());
                // return;

                Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                    action: () async {
                  final ProgressDialog pr = ProgressDialog(context,
                      type: ProgressDialogType.normal,
                      isDismissible: true,
                      showLogs: true);
                  await pr.show();
                  pr.update(message: 'processing'.tr());
                  try {
                    if (Global.posOrder != null) {
                      await reserveOrder(Global.posOrder!);
                    }
                    // Gen pair ID before submit
                    var pair = await ApiServices.post(
                        '/order/gen-pair/${Global.orders.first.orderTypeId}',
                        Global.requestObj(null));

                    // print(pair?.toJson());
                    // return;
                    if (pair?.status == "success") {
                      await postPayment(pair?.data);
                      await postOrder(pair?.data);
                      Global.orderIds =
                          Global.orders.map((e) => e.orderId).toList();
                      Global.pairId = pair?.data;
                      await pr.hide();
                      if (mounted) {
                        Global.orders.clear();
                        Global.discount = 0;
                        Global.addPrice = 0;
                        Global.customer = null;
                        Global.posOrder = null;
                        Global.paymentList?.clear();
                        Global.refillAttach = null;
                        Global.sellUsedAttach = null;
                        writeCart();
                        setState(() {});
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const WholeSalePrintBillScreen()));
                      }
                    } else {
                      if (mounted) {
                        Alert.warning(context, 'Warning'.tr(),
                            'Unable to generate pairing ID', 'OK'.tr(),
                            action: () {});
                      }
                    }
                  } catch (e) {
                    await pr.hide();
                    if (mounted) {
                      Alert.warning(
                          context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
                          action: () {});
                    }
                    return;
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "บันทึก".tr(),
                    style: TextStyle(
                        color: Colors.white, fontSize: 18.sp),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  const Icon(
                    Icons.save_alt_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            )),
      ],
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
                    fontSize: 16.sp,
                    color: kPrimaryGreen,
                  )),
            ),
            Expanded(
              flex: 3,
              child: Text(order.paymentMethod ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
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
                      fontSize: 16.sp,
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
                      fontSize: 16.sp,
                      color: kPrimaryGreen,
                    )),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          editPayment(index);
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                              color: Colors.blue[700],
                              borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              Text(
                                'แก้ไข',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          removePayment(index);
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              Text(
                                'ลบ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future postPayment(int pairId) async {
    if (Global.paymentList!.isNotEmpty) {
      var payment = await ApiServices.post(
          '/order/gen-payment/${Global.orders.first.orderTypeId}',
          Global.requestObj(null));

      if (payment?.status == "success") {
        for (int i = 0; i < Global.paymentList!.length; i++) {
          var result = await ApiServices.post(
              '/order/payment',
              Global.requestObj(
                PaymentModel(
                    id: 0,
                    pairId: pairId,
                    paymentId: payment?.data,
                    paymentMethod: Global.paymentList![i].paymentMethod,
                    paymentDate: Global.paymentList![i].paymentDate!,
                    bankId: Global.paymentList![i].bankId,
                    bankName: Global.paymentList![i].bankName,
                    accountName: Global.paymentList![i].accountName,
                    accountNo: Global.paymentList![i].accountNo,
                    amount: Global.paymentList![i].amount,
                    referenceNumber: Global.paymentList![i].referenceNumber,
                    cardName: Global.paymentList![i].cardName,
                    cardNo: Global.paymentList![i].cardNo,
                    cardExpiryDate: Global.paymentList![i].cardExpiryDate,
                    paymentDetail: Global.paymentList![i].paymentDetail,
                    attachement: Global.paymentList![i].attachement,
                    createdDate: DateTime.now(),
                    updatedDate: DateTime.now()),
              ));
          // motivePrint(result?.toJson());
          if (result?.status == "success") {
            motivePrint("Payment completed");
          }
        }
      }
    }
  }

  Future postOrder(int pairId) async {
    await Future.forEach<OrderModel>(Global.orders, (e) async {
      e.pairId = pairId;
      // Global.printLongString(e.toJson().toString());
      var result =
          await ApiServices.post('/order/create', Global.requestObj(e));
      motivePrint(result?.toJson());
      if (result?.status == "success") {
        var order = orderModelFromJson(jsonEncode(result?.data));
        int? id = order.id;
        await Future.forEach<OrderDetailModel>(e.details!, (f) async {
          f.orderId = id;
          // motivePrint(Global.requestObj(f));
          var detail =
              await ApiServices.post('/orderdetail', Global.requestObj(f));
          // motivePrint(detail?.toJson());
          if (detail?.status == "success") {
            motivePrint("Order completed");
          }
        });
      }
    });
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
                      // Expanded(
                      //     child: Text(
                      //   '${Global.format(Global.getOrderTotalAmountWholeSale(order.orderTypeId!, order.details!))} บาท',
                      //   style: const TextStyle(
                      //       fontSize: 30, fontWeight: FontWeight.bold),
                      // )),
                      Expanded(
                          child: Text(
                        '${Global.format(order.priceIncludeTax ?? 0)} บาท',
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
                        style: TextStyle(fontSize: 16.sp)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('ราคา',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.sp)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
              for (int j = 0; j < order.details!.length; j++)
                TableRow(
                  decoration: const BoxDecoration(),
                  children: [
                    paddedTextBigL('${j + 1}',
                        style: TextStyle(fontSize: 16.sp),
                        align: TextAlign.center),
                    paddedTextBigL(order.details![j].productName,
                        style: TextStyle(fontSize: 16.sp)),
                    paddedTextBigL(Global.format(order.details![j].weight!),
                        align: TextAlign.right,
                        style: TextStyle(fontSize: size?.getWidthPx(8))),
                    paddedTextBigL(
                        Global.format(order.orderTypeId == 5
                                ? order.details![j].priceExcludeTax!
                                : order.details![j].priceIncludeTax!) +
                            '  บาท',
                        align: TextAlign.right,
                        style: TextStyle(
                          fontSize: size?.getWidthPx(8),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (order.orderTypeId == 5) {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditRefillGoldStockScreen(
                                                  index: index,
                                                  j: j,
                                                ),
                                            fullscreenDialog: true))
                                    .whenComplete(() {
                                  setState(() {});
                                });
                              } else if (order.orderTypeId == 6) {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditSellUsedGoldScreen(
                                                  index: index,
                                                  j: j,
                                                ),
                                            fullscreenDialog: true))
                                    .whenComplete(() {
                                  setState(() {});
                                });
                              } else if (order.orderTypeId == 10) {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditRefillThengGoldStockScreen(
                                                  index: index,
                                                  j: j,
                                                ),
                                            fullscreenDialog: true))
                                    .whenComplete(() {
                                  setState(() {});
                                });
                              } else if (order.orderTypeId == 11) {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditSellUsedThengGoldScreen(
                                                  index: index,
                                                  j: j,
                                                ),
                                            fullscreenDialog: true))
                                    .whenComplete(() {
                                  setState(() {});
                                });
                              }
                            },
                            child: Container(
                              height: 60,
                              width: 80,
                              decoration: BoxDecoration(
                                  color: Colors.blue[700],
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'แก้ไข',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              removeItem(index, j);
                            },
                            child: Container(
                              height: 60,
                              width: 80,
                              decoration: BoxDecoration(
                                  color: Colors.red[700],
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'ลบ',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (index < Global.orders.length - 1)
            Container(
              height: 10,
              color: Colors.white,
            ),
          // ProductListTileData(
          //     orderId: order.orderId,
          //     weight:
          //         Global.format(Global.getOrderTotalWeight(order.details!)),
          //     showTotal: true,
          //     totalPrice:
          //         Global.format(Global.getOrderTotalAmount(order.details!)),
          //     type: null //order.orderTypeId.toString(),
          //     ),
        ],
      ),
    );
  }

  void removeProduct(int i) async {
    Global.orders.removeAt(i);
    if (Global.orders.isEmpty) {
      Global.customer = null;
      Global.discount = 0;
      Global.addPrice = 0;
      Global.paymentList?.clear();
    }
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {});
    });
  }

  void removeItem(int i, int j) async {
    Global.orders[i].details!.removeAt(j);
    if (Global.orders[i].details!.isEmpty) {
      Global.orders.removeAt(i);
      removeCart();
    }
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {});
    });
  }

  void removePayment(int i) async {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.paymentList!.removeAt(i);
      Future.delayed(const Duration(milliseconds: 500), () async {
        setState(() {});
      });
    });
  }

  void editPayment(int i) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: const BoxDecoration(color: snBgColor),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  'เลือกวิธีการชำระเงิน',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white),
                                ),
                                Text(
                                    '${Global.payToCustomerOrShopWholeSale(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text))}',
                                    style: TextStyle(
                                        fontSize: size?.getWidthPx(8),
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PaymentMethodWidget(
                            index: i,
                            payment: defaultPayment,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: double.infinity, minHeight: 100),
                            child: MaterialButton(
                              color: snBgColor,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "บันทึก",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                              ),
                              onPressed: () async {
                                Alert.info(
                                    context,
                                    'ต้องการบันทึกข้อมูลหรือไม่?',
                                    '',
                                    'ตกลง', action: () async {
                                  var payment = PaymentModel(
                                      paymentMethod:
                                          Global.currentPaymentMethod,
                                      pairId: Global.pairId,
                                      paymentDate: DateTime.parse(
                                          Global.paymentDateCtrl.text),
                                      paymentDetail:
                                          Global.paymentDetailCtrl.text,
                                      bankId: Global.selectedBank?.id,
                                      bankName: Global.selectedBank?.name,
                                      accountNo:
                                          Global.selectedAccount?.accountNo,
                                      accountName: Global.selectedAccount?.name,
                                      cardName: Global.cardNameCtrl.text,
                                      cardNo: Global.cardNumberCtrl.text,
                                      cardExpiryDate: Global.cardExpireDateCtrl
                                              .text.isNotEmpty
                                          ? DateTime.parse(
                                              Global.cardExpireDateCtrl.text)
                                          : null,
                                      amount: Global.toNumber(
                                          Global.amountCtrl.text),
                                      referenceNumber: Global.refNoCtrl.text,
                                      attachement: Global.paymentAttachment !=
                                              null
                                          ? Global.imageToBase64(
                                              Global.paymentAttachment!)
                                          : null);

                                  Global.paymentList?[i] = payment;

                                  setState(() {});
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ))),
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 30,
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> reserveOrder(OrderModel order) async {
    // motivePrint(order.toJson());
    var result =
        await ApiServices.post('/order/reserve', Global.requestObj(order));
    motivePrint(result?.toJson());
    if (result?.status == "success") {
      motivePrint("Reverse completed");
    }
  }

  void paymentDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: const BoxDecoration(color: snBgColor),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  'เลือกวิธีการชำระเงิน',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white),
                                ),
                                Text(
                                    '${Global.payToCustomerOrShopWholeSale(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text))}',
                                    style: TextStyle(
                                        fontSize: size?.getWidthPx(8),
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: PaymentMethodWidget(
                            payment: defaultPayment,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: double.infinity, minHeight: 100),
                            child: MaterialButton(
                              color: snBgColor,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "บันทึก",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                              ),
                              onPressed: () async {
                                Alert.info(
                                    context,
                                    'ต้องการบันทึกข้อมูลหรือไม่?',
                                    '',
                                    'ตกลง', action: () async {
                                  var payment = PaymentModel(
                                      paymentMethod:
                                          Global.currentPaymentMethod,
                                      pairId: Global.pairId,
                                      paymentDate: DateTime.parse(
                                          Global.paymentDateCtrl.text),
                                      paymentDetail:
                                          Global.paymentDetailCtrl.text,
                                      bankId: Global.selectedBank?.id,
                                      bankName: Global.selectedBank?.name,
                                      accountNo:
                                          Global.selectedAccount?.accountNo,
                                      accountName: Global.selectedAccount?.name,
                                      cardName: Global.cardNameCtrl.text,
                                      cardNo: Global.cardNumberCtrl.text,
                                      cardExpiryDate: Global.cardExpireDateCtrl
                                              .text.isNotEmpty
                                          ? DateTime.parse(
                                              Global.cardExpireDateCtrl.text)
                                          : null,
                                      amount: Global.toNumber(
                                          Global.amountCtrl.text),
                                      referenceNumber: Global.refNoCtrl.text,
                                      attachement: Global.paymentAttachment !=
                                              null
                                          ? Global.imageToBase64(
                                              Global.paymentAttachment!)
                                          : null);

                                  Global.paymentList?.add(payment);

                                  setState(() {});
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ))),
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 30,
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  getPaymentTotal() {
    if (Global.paymentList!.isEmpty) {
      return 0;
    }

    double amount = 0;
    for (int j = 0; j < Global.paymentList!.length; j++) {
      double price = Global.paymentList![j].amount ?? 0;
      amount += price;
    }
    return amount;
  }

  void loadCustomer() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get('/customer/walkin');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        setState(() {
          Global.customer = customerModelFromJson(data);
        });
      } else {
        Global.customer = null;
      }
    } catch (e) {
      motivePrint(e.toString());
    }
    setState(() {
      loading = false;
    });
  }
}

class PaymentCard extends StatelessWidget {
  const PaymentCard(
      {Key? key, this.isSelected = false, this.title, this.image, this.action})
      : super(key: key);

  final bool? isSelected;
  final String? title;
  final String? image;
  final Function()? action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Stack(
        children: [
          Container(
            height: getProportionateScreenWidth(30),
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(8.0),
                vertical: getProportionateScreenHeight(8.0)),
            margin: EdgeInsets.only(
              bottom: getProportionateScreenHeight(8.0),
            ),
            decoration: BoxDecoration(
              color: isSelected!
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(
                getProportionateScreenWidth(
                  4,
                ),
              ),
              boxShadow: [
                isSelected!
                    ? BoxShadow(
                        color: kShadowColor,
                        offset: Offset(
                          getProportionateScreenWidth(2),
                          getProportionateScreenWidth(4),
                        ),
                        blurRadius: 80,
                      )
                    : const BoxShadow(color: Colors.transparent),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: getProportionateScreenWidth(30),
                  height: getProportionateScreenWidth(30),
                  decoration: ShapeDecoration(
                    color: kGreyShade5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        getProportionateScreenWidth(8.0),
                      ),
                    ),
                  ),
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(image!,
                              fit: BoxFit.cover, width: 1000.0),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            "assets/images/no_image.png",
                            fit: BoxFit.cover,
                            width: 1000.0,
                          )),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(8),
                ),
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (isSelected!)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                child: const IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.teal,
                  ),
                  onPressed: null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
