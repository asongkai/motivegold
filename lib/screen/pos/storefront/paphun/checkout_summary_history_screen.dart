import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/response.dart' as rs;
import 'package:motivegold/screen/pos/storefront/customer_entry_screen.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/button/simple_button.dart';
import 'package:motivegold/widget/empty.dart';
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
  String? currentPaymentMethod;
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool loading = false;
  List<OrderModel> orders = [];
  double discount = 0;
  CustomerModel? customer;

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
      if (Global.pairId == null) {
        result = await ApiServices.post(
            '/order/order-list', encoder.convert(Global.orderIds));
      } else {
        result = await ApiServices.post(
            '/order/print-order-list/${Global.pairId}',
            Global.requestObj(null));
      }
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> dump = orderListModelFromJson(data);
        setState(() {
          orders = dump;
          orders = orders;
          customer = orders.first.customer;
          currentPaymentMethod = orders.first.paymentMethod;
          print(currentPaymentMethod);
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
    Screen? size = Screen(MediaQuery.of(context).size);
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
                                    child: customer == null
                                        ? SimpleRoundButton(
                                            buttonText: Text(
                                              'เพิ่ม',
                                              style: TextStyle(
                                                  fontSize:
                                                      size.getWidthPx(10)),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const CustomerEntryScreen(),
                                                          fullscreenDialog:
                                                              true))
                                                  .whenComplete(() {
                                                setState(() {});
                                              });
                                            },
                                          )
                                        : Column(
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
                                                          size.getWidthPx(6),
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
                                                  fontSize: size.getWidthPx(6),
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
                                                  fontSize: size.getWidthPx(6),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                "${customer!.address}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: size.getWidthPx(6),
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
                                  SingleChildScrollView(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              5,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: bgColor2,
                                      ),
                                      child: ListView.builder(
                                          itemCount: orders.length,
                                          itemBuilder: (context, index) {
                                            return _itemOrderList(
                                                order: orders[index],
                                                index: index);
                                          }),
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
                                  PaymentCard(
                                    isSelected: currentPaymentMethod == "TR",
                                    title: 'โอน'.tr(),
                                    image: 'assets/images/money_transfer.jpeg',
                                    action: () {
                                      setState(() {
                                        // currentPaymentMethod = "TR";
                                      });
                                    },
                                  ),
                                  PaymentCard(
                                    isSelected: currentPaymentMethod == "CA",
                                    title: 'เงินสด'.tr(),
                                    image:
                                        'assets/images/cash_on_delivery.jpeg',
                                    action: () {
                                      setState(() {
                                        // currentPaymentMethod = "CA";
                                      });
                                    },
                                  ),
                                  if (_image != null)
                                    Center(
                                      child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.file(_image!),
                                              ),
                                              Positioned(
                                                right: 0.0,
                                                top: 0.0,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _image = null;
                                                    });
                                                  },
                                                  child: const CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    child: Icon(Icons.close),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
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
        : amount == 0 ? '0' : 'เราจ่ายเงินให้กับลูกค้า ${formatter.format(-amount)} THB';
  }

  Widget _itemOrderList({required OrderModel order, required index}) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: ListTile(
            title: ProductListTileData(
              orderId: order.orderId,
              weight: Global.dateOnly(order.orderDate!.toString()),
              showTotal: true,
              totalPrice: Global.format(
                  Global.getOrderTotalAmount(order.details!).toPrecision(2)),
              type: order.orderTypeName.toString(),
            ),
          ),
        ),
      ],
    );
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
