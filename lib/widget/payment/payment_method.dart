import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';

class PaymentMethodWidget extends StatefulWidget {
  const PaymentMethodWidget({super.key});

  @override
  State<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget> {

  bool loading = false;
  ValueNotifier<dynamic>? paymentNotifier;

  @override
  void initState() {
    // implement initState
    super.initState();
    paymentNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(name: 'เลือกวิธีการชำระเงิน', code: '', id: 0));
    Global.paymentDateCtrl.text = Global.formatDateDD(DateTime.now().toString());
    init();
  }

  init() async {}

  final picker = ImagePicker();

  //Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        Global.paymentAttachment = File(pickedFile.path);
      }
    });
  }

//Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        Global.paymentAttachment = File(pickedFile.path);
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 80,
                    child: MiraiDropDownMenu<ProductTypeModel>(
                      key: UniqueKey(),
                      children: paymentTypes(),
                      space: 4,
                      maxHeight: 360,
                      showSearchTextField: true,
                      selectedItemBackgroundColor: Colors.transparent,
                      emptyListMessage: 'ไม่มีข้อมูล',
                      showSelectedItemBackgroundColor: true,
                      otherDecoration: const InputDecoration(),
                      itemWidgetBuilder: (
                        int index,
                        ProductTypeModel? project, {
                        bool isItemSelected = false,
                      }) {
                        return DropDownItemWidget(
                          project: project,
                          isItemSelected: isItemSelected,
                          firstSpace: 10,
                          fontSize: size.getWidthPx(6),
                        );
                      },
                      onChanged: (ProductTypeModel value) {
                        Global.selectedPayment = value;
                        Global.currentPaymentMethod =
                            Global.selectedPayment?.code;
                        paymentNotifier!.value = value;
                        setState(() {});
                        setState(() {});
                      },
                      child: DropDownObjectChildWidget(
                        key: GlobalKey(),
                        fontSize: size.getWidthPx(8),
                        projectValueNotifier: paymentNotifier!,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        if (Global.currentPaymentMethod == 'TR')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      buildTextFieldBig(
                        labelText: 'โอนเข้าบัญชีธนาคาร'.tr(),
                        validator: null,
                        inputType: TextInputType.text,
                        controller: Global.bankCtrl,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      buildTextFieldBig(
                        labelText: 'เลขที่อ้างอิง'.tr(),
                        validator: null,
                        inputType: TextInputType.text,
                        controller: Global.refNoCtrl,
                      ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      buildTextFieldBig(
                        labelText: 'ชื่อบนบัตร'.tr(),
                        validator: null,
                        inputType: TextInputType.text,
                        controller: Global.cardNameCtrl,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: TextField(
                    controller: Global.cardExpireDateCtrl,
                    //editing controller of this TextField
                    style: const TextStyle(fontSize: 35),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today),
                      //icon of text field
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 3.0, horizontal: 10.0),
                      labelText: "วันหมดอายุบัตร".tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(8),
                        ),
                        borderSide: const BorderSide(
                          color: kGreyShade3,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(2),
                        ),
                        borderSide: const BorderSide(
                          color: kGreyShade3,
                        ),
                      ),
                    ),
                    readOnly: true,
                    //set it true, so that user will not able to edit text
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1990),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2101));
                      if (pickedDate != null) {
                        motivePrint(
                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        motivePrint(
                            formattedDate); //formatted date output using intl package =>  2021-03-16
                        //you can implement different kind of Date Format here according to your requirement
                        setState(() {
                          Global.cardExpireDateCtrl.text =
                              formattedDate; //set output date to TextField value.
                        });
                      } else {
                        motivePrint("Date is not selected");
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: TextField(
                    controller: Global.paymentDateCtrl,
                    //editing controller of this TextField
                    style: const TextStyle(fontSize: 38),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today),
                      //icon of text field
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      labelText: "วันที่จ่ายเงิน".tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(8),
                        ),
                        borderSide: const BorderSide(
                          color: kGreyShade3,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(2),
                        ),
                        borderSide: const BorderSide(
                          color: kGreyShade3,
                        ),
                      ),
                    ),
                    readOnly: true,
                    //set it true, so that user will not able to edit text
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1990),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2101));
                      if (pickedDate != null) {
                        motivePrint(
                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        motivePrint(
                            formattedDate); //formatted date output using intl package =>  2021-03-16
                        //you can implement different kind of Date Format here according to your requirement
                        setState(() {
                          Global.paymentDateCtrl.text =
                              formattedDate; //set output date to TextField value.
                        });
                      } else {
                        motivePrint("Date is not selected");
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      buildTextFieldBig(
                        line: 2,
                        labelText: 'รายละเอียด'.tr(),
                        validator: null,
                        inputType: TextInputType.text,
                        controller: Global.paymentDetailCtrl,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        if (Global.currentPaymentMethod != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'เพิ่มสลิปการชำระเงิน'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),
          ),
        if (Global.currentPaymentMethod != null)
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: showOptions,
              icon: const Icon(
                Icons.add_a_photo_outlined,
              ),
              label: Text(
                'เลือกรูปภาพ',
                style: TextStyle(fontSize: size.getWidthPx(8)),
              ),
            ),
          ),
        if (Global.currentPaymentMethod != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Global.paymentAttachment == null
                  ? Text(
                      'ไม่ได้เลือกรูปภาพ',
                      style: TextStyle(fontSize: size.getWidthPx(6)),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(Global.paymentAttachment!),
                          ),
                          Positioned(
                            right: 0.0,
                            top: 0.0,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  Global.paymentAttachment = null;
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
          ),
      ],
    );
  }
}
