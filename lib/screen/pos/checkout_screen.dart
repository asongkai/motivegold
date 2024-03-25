import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modal_dialog/flutter_modal_dialog.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/pos/customer_entry_screen.dart';
import 'package:motivegold/screen/pos/order_success_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/button/simple_button.dart';
import 'package:motivegold/widget/price_breakdown.dart';

import '../../widget/product_list_tile.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  int currentIndex = 1;

  String actionText = 'change'.tr();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: Text('เช็คเอาท์'.tr()),
      ),
      body: SafeArea(
        child: Column(
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
                                          fontSize: size.getWidthPx(10)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CustomerEntryScreen(),
                                                  fullscreenDialog: true))
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
                                            "${Global.customer!.firstName} ${Global.customer!.lastName}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: size.getWidthPx(6),
                                            ),
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            onTap: (){
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                      const CustomerEntryScreen(),
                                                      fullscreenDialog: true))
                                                  .whenComplete(() {
                                                setState(() {});
                                              });
                                            },
                                            child: Text(
                                              "เปลี่ยน",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: size.getWidthPx(6),
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "${Global.customer!.phone}",
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
                                        "${Global.customer!.email}",
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
                                        "${Global.customer!.address}",
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
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SingleChildScrollView(
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 5,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: bgColor2,
                              ),
                              child: ListView.builder(
                                  itemCount: Global.order?.length,
                                  itemBuilder: (context, index) {
                                    return _itemOrderList(
                                        order: Global.order![index],
                                        index: index);
                                  }),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'เลือกวิธีการชำระเงิน'.tr(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          PaymentCard(
                            isSelected: currentIndex == 1,
                            title: 'โอน'.tr(),
                            image: 'assets/images/money_transfer.jpeg',
                            action: () {
                              setState(() {
                                currentIndex = 1;
                              });
                            },
                          ),
                          PaymentCard(
                            isSelected: currentIndex == 0,
                            title: 'เงินสด'.tr(),
                            image: 'assets/images/cash_on_delivery.jpeg',
                            action: () {
                              setState(() {
                                currentIndex = 0;
                              });
                            },
                          ),
                          // PaymentCard(
                          //   title: 'OnePay',
                          //   image: 'assets/images/onepay.png',
                          //   action: () {
                          //     Alert.warning(context, 'Warning'.tr(), 'OnePay ${'comingSoon'.tr()}', 'OK'.tr(), action: () {});
                          //   },
                          // ),
                          Divider(
                            height: getProportionateScreenHeight(56),
                          ),
                          Text(
                            'ราคา',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          PriceBreakdown(
                            title: 'จำนวนเงินที่ต้องชำระ'.tr(),
                            price:
                                '${formatter.format(Global.getPaymentTotal())} THB',
                          ),
                          const Divider(),
                          PriceBreakdown(
                            title: 'ใครจ่ายให้ใครเท่าไร'.tr(),
                            price:
                            '${Global.payToCustomerOrShop()}',
                          ),
                          const SizedBox(height: 30,),
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
              onPressed: () {
                ModalDialog.waiting(
                  context: context,
                  title: const ModalTitle(text: "กำลังพิมพ์..."),
                  message: "กรุณารอจนกว่ากระบวนการพิมพ์จะเสร็จสิ้น.",
                );

                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderSuccessScreen()));
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ต่อไป".tr(),
                    style: TextStyle(
                        color: Colors.white, fontSize: size.getWidthPx(8)),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void checkout() async {
    setState(() {});
  }

  Widget _itemOrderList({required OrderModel order, required index}) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: ListTile(
            title: ProductListTileData(
              leftTitle: order.orderId,
              leftValue: order.type,
              rightTitle: 'วันที่',
              rightValue: order.orderDate,
            ),
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
                  height: 80,
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
    );
  }

  void removeProduct(int i) async {
    Global.order!.removeAt(i);
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {});
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
