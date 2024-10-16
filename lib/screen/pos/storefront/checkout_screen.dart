import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/screen/pos/storefront/broker/broker_entry_screen.dart';
import 'package:motivegold/screen/pos/storefront/customer_entry_screen.dart';
import 'package:motivegold/screen/pos/storefront/print_bill_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/button/simple_button.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/payment/payment_method.dart';
import 'package:motivegold/widget/price_breakdown.dart';
import 'package:motivegold/widget/product_list_tile.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  Screen? size;

  @override
  void initState() {
    // implement initState
    super.initState();
    Global.selectedPayment = null;
    Global.currentPaymentMethod = null;
    Global.paymentAttachment = null;
    Global.cardNameCtrl.text = "";
    Global.cardExpireDateCtrl.text = "";
    Global.bankCtrl.text = "";
    Global.refNoCtrl.text = "";
    Global.paymentDateCtrl.text = Global.dateOnlyT(DateTime.now().toString());
    Global.paymentDetailCtrl.text = "";
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
          child: Global.orders!.isEmpty
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
                                    child: Global.customer == null
                                        ? SimpleRoundButton(
                                            buttonText: Text(
                                              'เพิ่ม',
                                              style: TextStyle(
                                                  fontSize:
                                                      size!.getWidthPx(10)),
                                            ),
                                            onPressed: () {
                                              if (Global.orders![0]
                                                  .orderTypeId ==
                                                  8 ||
                                                  Global.orders![0]
                                                      .orderTypeId ==
                                                      9) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                        const BrokerEntryScreen(),
                                                        fullscreenDialog:
                                                        true))
                                                    .whenComplete(() {
                                                  setState(() {});
                                                });
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                        const CustomerEntryScreen(),
                                                        fullscreenDialog:
                                                        true))
                                                    .whenComplete(() {
                                                  setState(() {});
                                                });
                                              }
                                            },
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "${Global.customer!.firstName} ${Global.customer!.lastName}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize:
                                                          size!.getWidthPx(6),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  InkWell(
                                                    onTap: () {
                                                      if (Global.orders![0]
                                                                  .orderTypeId ==
                                                              8 ||
                                                          Global.orders![0]
                                                                  .orderTypeId ==
                                                              9) {
                                                        Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const BrokerEntryScreen(),
                                                                    fullscreenDialog:
                                                                        true))
                                                            .whenComplete(() {
                                                          setState(() {});
                                                        });
                                                      } else {
                                                        Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const CustomerEntryScreen(),
                                                                    fullscreenDialog:
                                                                        true))
                                                            .whenComplete(() {
                                                          setState(() {});
                                                        });
                                                      }
                                                    },
                                                    child: Text(
                                                      "เปลี่ยน",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: size!
                                                              .getWidthPx(6),
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                "${Global.customer!.phoneNumber}",
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
                                                "${Global.customer!.email}",
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
                                                "${Global.customer!.address}",
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
                                        ...Global.orders!.map((e) {
                                          return _itemOrderList(
                                              order: e, index: 0);
                                        })
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'เลือกวิธีการชำระเงิน'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                  ),
                                  const PaymentMethodWidget(),
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
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      onChanged: (value) {
                                        Global.discount = value.isNotEmpty
                                            ? Global.toNumber(value)
                                            : 0;
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
                                              '${formatter.format(Global.getPaymentTotal())} THB',
                                        ),
                                        PriceBreakdown(
                                          title: 'ใครจ่ายให้ใครเท่าไร'.tr(),
                                          price:
                                              '${Global.payToCustomerOrShop()}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: Global.paymentAttachment == null
                                        ? 100
                                        : 0,
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
      persistentFooterButtons: [
        SizedBox(
            height: 70,
            width: 150,
            child: ElevatedButton(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.teal[700]!),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.teal[700]!)))),
              onPressed: () async {
                if (Global.customer == null) {
                  if (mounted) {
                    Alert.warning(
                        context, 'Warning'.tr(), 'กรุณากรอกลูกค้า', 'OK'.tr());
                    return;
                  }
                }

                // if (_image == null) {
                //   if (mounted) {
                //     Alert.warning(context, 'Warning'.tr(),
                //         'กรุณาเลือกภาพการชำระเงิน', 'OK'.tr());
                //     return;
                //   }
                // }

                for (var i = 0; i < Global.orders!.length; i++) {
                  Global.orders![i].id = 0;
                  Global.orders![i].createdDate = DateTime.now().toUtc();
                  Global.orders![i].updatedDate = DateTime.now().toUtc();
                  Global.orders![i].customerId = Global.customer!.id!;
                  Global.orders![i].status = "0";
                  Global.orders![i].discount = Global.discount;
                  Global.orders![i].paymentMethod = Global.currentPaymentMethod;
                  Global.orders![i].attachement =
                      Global.paymentAttachment != null
                          ? Global.imageToBase64(Global.paymentAttachment!)
                          : null;
                  Global.orders![i].priceIncludeTax =
                      Global.getOrderTotal(Global.orders![i]);
                  Global.orders![i].purchasePrice =
                      Global.orders![i].orderTypeId == 2
                          ? 0
                          : Global.getPapunTotal(Global.orders![i]);
                  Global.orders![i].priceDiff =
                      Global.orders![i].orderTypeId == 2
                          ? 0
                          : Global.getOrderTotal(Global.orders![i]) -
                              Global.getPapunTotal(Global.orders![i]);
                  Global.orders![i].taxBase = Global.orders![i].orderTypeId == 2
                      ? 0
                      : (Global.getOrderTotal(Global.orders![i]) -
                              Global.getPapunTotal(Global.orders![i])) *
                          100 /
                          107;
                  Global.orders![i].taxAmount =
                      Global.orders![i].orderTypeId == 2
                          ? 0
                          : ((Global.getOrderTotal(Global.orders![i]) -
                                      Global.getPapunTotal(Global.orders![i])) *
                                  100 /
                                  107) *
                              0.07;
                  Global.orders![i].priceExcludeTax = Global
                              .orders![i].orderTypeId ==
                          2
                      ? 0
                      : Global.getOrderTotal(Global.orders![i]) -
                          (((Global.getOrderTotal(Global.orders![i]) -
                                      Global.getPapunTotal(Global.orders![i])) *
                                  100 /
                                  107) *
                              0.07);
                  for (var j = 0; j < Global.orders![i].details!.length; j++) {
                    Global.orders![i].details![j].id = 0;
                    Global.orders![i].details![j].orderId =
                        Global.orders![i].id;
                    Global.orders![i].details![j].unitCost =
                        Global.orders![i].details![j].priceIncludeTax! / 15.16;
                    Global.orders![i].details![j].purchasePrice =
                        Global.orders![i].orderTypeId == 2
                            ? 0
                            : Global.getBuyPrice(
                                Global.orders![i].details![j].weight!);
                    Global.orders![i].details![j].priceDiff =
                        Global.orders![i].orderTypeId == 2
                            ? 0
                            : Global.orders![i].details![j].priceIncludeTax! -
                                Global.getBuyPrice(
                                    Global.orders![i].details![j].weight!);
                    Global.orders![i].details![j].taxBase = Global
                                .orders![i].orderTypeId ==
                            2
                        ? 0
                        : (Global.orders![i].details![j].priceIncludeTax! -
                                Global.getBuyPrice(
                                    Global.orders![i].details![j].weight!)) *
                            100 /
                            107;
                    Global.orders![i].details![j].taxAmount =
                        Global.orders![i].orderTypeId == 2
                            ? 0
                            : ((Global.orders![i].details![j].priceIncludeTax! -
                                        Global.getBuyPrice(Global
                                            .orders![i].details![j].weight!)) *
                                    100 /
                                    107) *
                                0.07;
                    Global.orders![i].details![j].priceExcludeTax =
                        Global.orders![i].orderTypeId == 2
                            ? 0
                            : (Global.orders![i].details![j].priceIncludeTax! -
                                ((((Global.orders![i].details![j]
                                                .priceIncludeTax! -
                                            Global.getBuyPrice(Global.orders![i]
                                                .details![j].weight!)) *
                                        100 /
                                        107) *
                                    0.07)));
                    Global.orders![i].details![j].createdDate =
                        DateTime.now().toUtc();
                    Global.orders![i].details![j].updatedDate =
                        DateTime.now().toUtc();
                  }
                }
                // print(orderListModelToJson(Global.orders!));
                // return;
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
                      '/order/gen-pair/${Global.orders?.first.orderTypeId}',
                      Global.requestObj(null));

                  // print(detail!.data);
                  if (pair?.status == "success") {

                    await postPayment(pair?.data);
                    await postOrder(pair?.data);
                    Global.orderIds =
                        Global.orders!.map((e) => e.orderId).toList();
                    Global.pairId = pair?.data;
                    await pr.hide();
                    if (mounted) {
                      Global.orders!.clear();
                      Global.discount = 0;
                      Global.customer = null;
                      Global.posOrder = null;
                      setState(() {});
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrintBillScreen()));
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
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "บันทึก".tr(),
                    style: TextStyle(
                        color: Colors.white, fontSize: size!.getWidthPx(8)),
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

  Future postPayment(int pairId) async {
    var result = await ApiServices.post(
        '/order/payment',
        Global.requestObj(
          PaymentModel(
              id: 0,
              pairId: pairId,
              paymentMethod: Global.currentPaymentMethod,
              paymentDate: DateTime.parse(Global.paymentDateCtrl.text).toUtc(),
              bankName: Global.bankCtrl.text,
              referenceNumber: Global.refNoCtrl.text,
              cardName: Global.cardNameCtrl.text,
              cardExpiryDate: Global.cardExpireDateCtrl.text.trim() != ""
                  ? DateTime.parse(Global.cardExpireDateCtrl.text).toUtc()
                  : null,
              paymentDetail: Global.paymentDetailCtrl.text,
              attachement: Global.paymentAttachment != null
                  ? Global.imageToBase64(Global.paymentAttachment!)
                  : null,
              createdDate: DateTime.now().toUtc(),
              updatedDate: DateTime.now().toUtc()),
        ));
    // motivePrint(result?.toJson());
    if (result?.status == "success") {
      motivePrint("Payment completed");
    }
  }

  Future postOrder(int pairId) async {
    await Future.forEach<OrderModel>(Global.orders!, (e) async {
      e.pairId = pairId;
      var result =
          await ApiServices.post('/order/create', Global.requestObj(e));
      if (result?.status == "success") {
        var order = orderModelFromJson(jsonEncode(result?.data));
        int? id = order.id;
        await Future.forEach<OrderDetailModel>(e.details!, (f) async {
          f.orderId = id;
          var detail =
              await ApiServices.post('/orderdetail', Global.requestObj(f));
          if (detail?.status == "success") {
            motivePrint("Order completed");
          }
        });
      }
    });
  }

  Widget _itemOrderList({required OrderModel order, required index}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 8,
              child: ProductListTileData(
                  orderId: order.orderId,
                  weight:
                      Global.format(Global.getOrderTotalWeight(order.details!)),
                  showTotal: true,
                  totalPrice:
                      Global.format(Global.getOrderTotalAmount(order.details!)),
                  type: null //order.orderTypeId.toString(),
                  ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      removeProduct(index);
                    },
                    child: Container(
                      height: 60,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
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

  void removeProduct(int i) async {
    Global.orders!.removeAt(i);
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {});
    });
  }

  Future<void> reserveOrder(OrderModel order) async {
    motivePrint(order.toJson());
    var result = await ApiServices.post(
        '/order/reserve',
        Global.requestObj(order));
    motivePrint(result?.toJson());
    if (result?.status == "success") {
      motivePrint("Reverse completed");
    }
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
              color: isSelected! ? Colors.white : Colors.white.withOpacity(0.5),
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
