import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/screen/pos/customer_entry_screen.dart';
import 'package:motivegold/screen/pos/print_bill_screen.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/button/simple_button.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/price_breakdown.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../api/api_services.dart';
import '../../utils/alert.dart';
import '../../widget/product_list_tile.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  int currentIndex = 1;
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    // implement initState
    super.initState();
  }

  //Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

//Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('คลังภาพ'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('ถ่ายรูป'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
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
                                                    "${Global.customer!.firstName} ${Global.customer!.lastName}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize:
                                                          size.getWidthPx(6),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  InkWell(
                                                    onTap: () {
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
                                                    },
                                                    child: Text(
                                                      "เปลี่ยน",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: size
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
                                          itemCount: Global.orders?.length,
                                          itemBuilder: (context, index) {
                                            return _itemOrderList(
                                                order: Global.orders![index],
                                                index: index);
                                          }),
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
                                    image:
                                        'assets/images/cash_on_delivery.jpeg',
                                    action: () {
                                      setState(() {
                                        currentIndex = 0;
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'เพิ่มสลิปการชำระเงิน'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      TextButton(
                                        onPressed: showOptions,
                                        child: Text(
                                          'เลือกรูปภาพ',
                                          style: TextStyle(
                                              fontSize: size.getWidthPx(8)),
                                        ),
                                      ),
                                      Center(
                                        child: _image == null
                                            ? Text(
                                                'ไม่ได้เลือกรูปภาพ',
                                                style: TextStyle(
                                                    fontSize:
                                                        size.getWidthPx(6)),
                                              )
                                            : SizedBox(
                                                width: MediaQuery.of(context).size.width / 4,
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
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
                                    ],
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
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      onChanged: (value) {
                                        Global.discount = value.isNotEmpty
                                            ? Global.toNumber(value)
                                            : 0;
                                        setState(() {});
                                      }),
                                  PriceBreakdown(
                                    title: 'จำนวนเงินที่ต้องชำระ'.tr(),
                                    price:
                                        '${formatter.format(Global.getPaymentTotal())} THB',
                                  ),
                                  const Divider(),
                                  PriceBreakdown(
                                    title: 'ใครจ่ายให้ใครเท่าไร'.tr(),
                                    price: '${Global.payToCustomerOrShop()}',
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
                // ModalDialog.waiting(
                //   context: context,
                //   title: const ModalTitle(text: "กำลังพิมพ์..."),
                //   message: "กรุณารอจนกว่ากระบวนการพิมพ์จะเสร็จสิ้น.",
                // );

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
                  Global.orders![i].status = 0;
                  Global.orders![i].discount = Global.discount;
                  Global.orders![i].attachement = _image != null ? Global.imageToBase64(_image!) : null;
                  Global.orders![i].priceIncludeTax =
                      Global.getOrderTotal(Global.orders![i]);
                  Global.orders![i].purchasePrice =
                      Global.orders![i].orderTypeId == 1
                          ? Global.getPapunTotal(Global.orders![i])
                          : 0;
                  Global.orders![i].priceDiff = Global.orders![i].orderTypeId == 1
                      ? Global.getOrderTotal(Global.orders![i]) -
                          Global.getPapunTotal(Global.orders![i])
                      : 0;
                  Global.orders![i].taxBase = Global.orders![i].orderTypeId == 1
                      ? (Global.getOrderTotal(Global.orders![i]) -
                              Global.getPapunTotal(Global.orders![i])) *
                          100 /
                          107
                      : 0;
                  Global.orders![i].taxAmount = Global.orders![i].orderTypeId == 1
                      ? ((Global.getOrderTotal(Global.orders![i]) -
                                  Global.getPapunTotal(Global.orders![i])) *
                              100 /
                              107) *
                          0.07
                      : 0;
                  Global.orders![i].priceExcludeTax = Global
                              .orders![i].orderTypeId ==
                          1
                      ? Global.getOrderTotal(Global.orders![i]) -
                          (((Global.getOrderTotal(Global.orders![i]) -
                                      Global.getPapunTotal(Global.orders![i])) *
                                  100 /
                                  107) *
                              0.07)
                      : 0;
                  Global.orders![i].status = 0;
                  for (var j = 0; j < Global.orders![i].details!.length; j++) {
                    Global.orders![i].details![j].id = 0;
                    Global.orders![i].details![j].orderId = Global.orders![i].id;
                    Global.orders![i].details![j].unitCost =
                        Global.orders![i].details![j].priceIncludeTax! / 15.16;
                    Global.orders![i].details![j].purchasePrice =
                        Global.orders![i].orderTypeId == 1
                            ? Global.getBuyPrice(
                                Global.orders![i].details![j].weight!)
                            : 0;
                    Global.orders![i].details![j].priceDiff =
                        Global.orders![i].orderTypeId == 1
                            ? Global.orders![i].details![j].priceIncludeTax! -
                                Global.getBuyPrice(
                                    Global.orders![i].details![j].weight!)
                            : 0;
                    Global.orders![i].details![j].taxBase =
                        Global.orders![i].orderTypeId == 1
                            ? (Global.orders![i].details![j].priceIncludeTax! -
                                    Global.getBuyPrice(
                                        Global.orders![i].details![j].weight!)) *
                                100 /
                                107
                            : 0;
                    Global.orders![i].details![j].taxAmount = Global
                                .orders![i].orderTypeId ==
                            1
                        ? ((Global.orders![i].details![j].priceIncludeTax! -
                                    Global.getBuyPrice(
                                        Global.orders![i].details![j].weight!)) *
                                100 /
                                107) *
                            0.07
                        : 0;
                    Global.orders![i].details![j].priceExcludeTax =
                        Global.orders![i].orderTypeId == 1
                            ? (Global.orders![i].details![j].priceIncludeTax! -
                                ((((Global.orders![i].details![j]
                                                .priceIncludeTax! -
                                            Global.getBuyPrice(Global.orders![i]
                                                .details![j].weight!)) *
                                        100 /
                                        107) *
                                    0.07)))
                            : 0;
                    Global.orders![i].details![j].createdDate =
                        DateTime.now().toUtc();
                    Global.orders![i].details![j].updatedDate =
                        DateTime.now().toUtc();
                  }
                }
                // print(orderListModelToJson(Global.order!));
                // return;
                final ProgressDialog pr = ProgressDialog(context,
                    type: ProgressDialogType.normal,
                    isDismissible: true,
                    showLogs: true);
                await pr.show();
                pr.update(message: 'processing'.tr());
                try {
                  await await postOrder();
                  Global.orderIds =
                      Global.orders!.map((e) => e.orderId).toList();
                  await pr.hide();
                  if (mounted) {
                    Global.orders!.clear();
                    Global.discount = 0;
                    Global.customer = null;
                    setState(() {});
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PrintBillScreen()));
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

  Future postOrder() async {
    await Future.forEach<OrderModel>(Global.orders!, (e) async {
      var result = await ApiServices.post('/order/create', Global.requestObj(e));
      // print(result!.data);
      if (result?.status == "success") {
        var order = orderModelFromJson(jsonEncode(result?.data));
        int? id = order.id;
        await Future.forEach<OrderDetailModel>(e.details!, (f) async {
          f.orderId = id;
          // await Future.delayed(Duration(seconds: 3));
          var detail =
              await ApiServices.post('/orderdetail', Global.requestObj(f));
          // print(detail!.data);
          if (detail?.status == "success") {
            print("Order completed");
          }
        });
      }
    });
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
              orderId: order.orderId,
              orderDate: Global.dateOnly(order.orderDate!.toString()),
              showTotal: true,
              totalPrice: formatter.format(
                  Global.getOrderTotalAmount(order.details!).toPrecision(2)),
              type: order.orderTypeId.toString(),
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
    Global.orders!.removeAt(i);
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
