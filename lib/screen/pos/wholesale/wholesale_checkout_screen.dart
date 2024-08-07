import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/button/simple_button.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/price_breakdown.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/product_list_tile.dart';
import 'refill/refill_vender_entry_screen.dart';

class WholesaleCheckOutScreen extends StatefulWidget {
  const WholesaleCheckOutScreen({super.key});

  @override
  State<WholesaleCheckOutScreen> createState() =>
      _WholesaleCheckOutScreenState();
}

class _WholesaleCheckOutScreenState extends State<WholesaleCheckOutScreen> {
  int currentIndex = 1;
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  String currentPaymentMethod = 'CA';

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
                                    'ผู้ขาย',
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
                                                              const RefillVenderEntryScreen(),
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
                                                                          const RefillVenderEntryScreen(),
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
                                    'รายการสินค้า',
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
                                              order: e,
                                              index: 0);
                                        })
                                      ],
                                    ),
                                  ),
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
                                          price: '${Global.payToBrokerOrShop()}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
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
                                    isSelected: currentPaymentMethod == 'TR',
                                    title: 'โอน'.tr(),
                                    image: 'assets/images/money_transfer.jpeg',
                                    action: () {
                                      setState(() {
                                        currentPaymentMethod = 'TR';
                                      });
                                    },
                                  ),
                                  PaymentCard(
                                    isSelected: currentPaymentMethod == 'CA',
                                    title: 'เงินสด'.tr(),
                                    image:
                                    'assets/images/cash_on_delivery.jpeg',
                                    action: () {
                                      setState(() {
                                        currentPaymentMethod = 'CA';
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'เอกสารที่แนบมา'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: ElevatedButton.icon(
                                          onPressed: showOptions,
                                          icon: const Icon(Icons.add_a_photo_outlined,), label: Text(
                                          'เลือกรูปภาพ',
                                          style: TextStyle(
                                              fontSize: size.getWidthPx(8)),
                                        ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: _image == null
                                              ? Text(
                                                  'ไม่ได้เลือกรูปภาพ',
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.getWidthPx(6)),
                                                )
                                              : SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4,
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8.0),
                                                        child:
                                                            Image.file(_image!),
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
                                                          child:
                                                              const CircleAvatar(
                                                            backgroundColor:
                                                                Colors.red,
                                                            child:
                                                                Icon(Icons.close),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: _image == null ? 200 : 0,
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
                  Global.orders![i].paymentMethod = currentPaymentMethod;
                  Global.orders![i].attachement = _image != null ? Global.imageToBase64(_image!) : null;
                  Global.orders![i].priceIncludeTax =
                      Global.getOrderTotal(Global.orders![i]);
                  Global.orders![i].purchasePrice = 0;
                  Global.orders![i].priceDiff = 0;
                  Global.orders![i].taxBase = 0;
                  Global.orders![i].taxAmount = 0;
                  Global.orders![i].priceExcludeTax = 0;
                  for (var j = 0; j < Global.orders![i].details!.length; j++) {
                    Global.orders![i].details![j].id = 0;
                    Global.orders![i].details![j].orderId = Global.orders![i].id;
                    Global.orders![i].details![j].unitCost =
                        Global.orders![i].details![j].priceIncludeTax! / 15.16;
                    Global.orders![i].details![j].purchasePrice =0;
                    Global.orders![i].details![j].priceDiff = 0;
                    Global.orders![i].details![j].taxBase = 0;
                    Global.orders![i].details![j].taxAmount =  0;
                    Global.orders![i].details![j].priceExcludeTax = 0;
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
                  // Gen pair ID before submit
                  var pair = await ApiServices.post(
                      '/order/gen-pair/${Global.orders?.first.orderTypeId}',
                      Global.requestObj(null));
                  if (pair?.status == "success") {
                    await postOrder(pair?.data);
                    Global.orderIds =
                        Global.orders!.map((e) => e.orderId).toList();
                    Global.pairId = pair?.data;
                    await pr.hide();
                    if (mounted) {
                      Alert.success(context, 'Success'.tr(), "", 'OK'.tr(),
                          action: () async {
                        Global.order!.details!.clear();
                        Global.order = null;
                        Global.refillOrderDetail!.clear();
                        Global.discount = 0;
                        Global.customer = null;
                        setState(() {});
                        Navigator.of(context).pop();
                      });
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
                  const Icon(
                    Icons.save_alt_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(
                    "บันทึก".tr(),
                    style: TextStyle(
                        color: Colors.white, fontSize: size.getWidthPx(8)),
                  ),
                ],
              ),
            )),
      ],
    );
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
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: ProductListTileData(
              orderId: order.orderId,
              weight: Global.format(
                  Global.getOrderTotalWeight(order.details!)),
              showTotal: true,
              totalPrice: Global.format(
                  Global.getOrderTotalAmount(order.details!)),
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
