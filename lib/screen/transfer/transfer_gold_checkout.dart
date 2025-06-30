import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/model/transfer_detail.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/price_breakdown.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';

class TransferGoldCheckOutScreen extends StatefulWidget {
  const TransferGoldCheckOutScreen({super.key});

  @override
  State<TransferGoldCheckOutScreen> createState() =>
      _TransferGoldCheckOutScreenState();
}

class _TransferGoldCheckOutScreenState
    extends State<TransferGoldCheckOutScreen> {
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
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("ยืนยันการโอน",
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
          child: Global.transfer == null
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
                                horizontal: getProportionateScreenWidth(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                          itemCount:
                                              Global.transfer!.details!.length,
                                          itemBuilder: (context, index) {
                                            return _itemOrderList(
                                                transfer: Global.transfer!,
                                                detail: Global
                                                    .transfer!.details![index],
                                                index: index);
                                          }),
                                    ),
                                  ),
                                  PriceBreakdown(
                                    title: 'ยอดรวม'.tr(),
                                    price:
                                        '${formatter.format(Global.getTransferWeightTotalAmount())} กรัม',
                                  ),
                                  PriceBreakdown(
                                    title: ''.tr(),
                                    price:
                                        '${formatter.format(Global.getTransferWeightTotalAmount() / getUnitWeightValue())} บาททอง',
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Divider(),
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
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
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
                      WidgetStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.teal[700]!),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.teal[700]!)))),
              onPressed: () async {
                // ModalDialog.waiting(
                //   context: context,
                //   title: const ModalTitle(text: "กำลังพิมพ์..."),
                //   message: "กรุณารอจนกว่ากระบวนการพิมพ์จะเสร็จสิ้น.",
                // );

                // if (Global.customer == null) {
                //   if (mounted) {
                //     Alert.warning(
                //         context, 'Warning'.tr(), 'กรุณากรอกลูกค้า', 'OK'.tr());
                //     return;
                //   }
                // }

                // if (_image == null) {
                //   if (mounted) {
                //     Alert.warning(context, 'Warning'.tr(),
                //         'กรุณาเลือกภาพการชำระเงิน', 'OK'.tr());
                //     return;
                //   }
                // }

                // motivePrint(Global.transfer?.toJson());

                Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                    action: () async {
                  Global.transfer!.id = 0;
                  Global.transfer!.createdDate = DateTime.now();
                  Global.transfer!.updatedDate = DateTime.now();
                  Global.transfer!.customerId =
                      Global.customer == null ? 0 : Global.customer!.id!;
                  Global.transfer!.attachement =
                      _image == null ? null : Global.imageToBase64(_image!);
                  for (var j = 0; j < Global.transfer!.details!.length; j++) {
                    Global.transfer!.details![j].id = 0;
                    Global.transfer!.details![j].transferId =
                        Global.transfer!.id;
                    Global.transfer!.details![j].createdDate = DateTime.now();
                    Global.transfer!.details![j].updatedDate = DateTime.now();
                    // motivePrint(Global.transfer!.details![j].toJson());
                  }
                  // motivePrint(Global.transfer?.toJson());
                  // return;
                  final ProgressDialog pr = ProgressDialog(context,
                      type: ProgressDialogType.normal,
                      isDismissible: true,
                      showLogs: true);
                  await pr.show();
                  pr.update(message: 'processing'.tr());
                  try {
                    // await postOrder();
                    var result =
                    await ApiServices.post('/transfer', Global.requestObj(Global.transfer));
                    // print(result!.toJson());
                    // return;

                    if (result!.status == "success") {
                      var transfer = transferModelFromJson(jsonEncode(result.data));
                      int? transferId = transfer.id;
                      await Future.forEach<TransferDetailModel>(Global.transfer!.details!,
                              (f) async {
                            f.transferId = transferId;
                            var detail = (transfer.transferType == 'INTERNAL')
                                ? await ApiServices.post('/transferdetail', Global.requestObj(f))
                                : await ApiServices.post(
                                '/transferdetail/between-branch', Global.requestObj(f));
                            // print(detail!.data);
                            if (detail?.status == "success") {
                              print("Order completed");
                            }
                          });
                      await pr.hide();
                      if (mounted) {
                        Alert.success(context, 'Success'.tr(), "", 'OK'.tr(),
                            action: () {
                              Global.transfer!.details!.clear();
                              Global.transfer = null;
                              Global.transferDetail!.clear();
                              // Global.discount = 0;
                              Global.customer = null;
                              setState(() {});
                              Navigator.of(context).pop();
                            });
                      }
                    } else {
                      await pr.hide();
                      Alert.warning(
                          context, 'Warning'.tr(), result.message ?? '', 'OK'.tr(),
                          action: () {});
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

  Future postOrder() async {
    var result =
        await ApiServices.post('/transfer', Global.requestObj(Global.transfer));
    // print(result!.data);
    // return;
    if (result!.status == "success") {
      var transfer = transferModelFromJson(jsonEncode(result.data));
      int? transferId = transfer.id;
      await Future.forEach<TransferDetailModel>(Global.transfer!.details!,
          (f) async {
        f.transferId = transferId;
        var detail = (transfer.transferType == 'INTERNAL')
            ? await ApiServices.post('/transferdetail', Global.requestObj(f))
            : await ApiServices.post(
                '/transferdetail/between-branch', Global.requestObj(f));
        // print(detail!.data);
        if (detail?.status == "success") {
          print("Order completed");
        }
      });
    }
  }

  void checkout() async {
    setState(() {});
  }

  Widget _itemOrderList(
      {required TransferModel transfer,
      required TransferDetailModel detail,
      required index}) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: ListTile(
            title: ListTileData(
              leftTitle:
                  '${transfer.fromBinLocationName} --- ${transfer.toBinLocationName}',
              leftValue: detail.weight!.toString(),
              rightTitle: '',
              rightValue: '',
              single: true,
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
    Global.transfer!.details!.removeAt(i);
    if (Global.transfer!.details!.isEmpty) {
      Global.transfer = null;
    }
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
              color: isSelected! ? Colors.white : Colors.white.withValues(alpha: 0.5),
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
