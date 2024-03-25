import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modal_dialog/flutter_modal_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/motive.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';

import '../../utils/global.dart';

class CustomerEntryScreen extends StatefulWidget {
  const CustomerEntryScreen({super.key});

  @override
  State<CustomerEntryScreen> createState() => _CustomerEntryScreenState();
}

class _CustomerEntryScreenState extends State<CustomerEntryScreen> {
  final TextEditingController idCardCtrl = TextEditingController();
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailAddressCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController birthDateCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  List<File>? imageFiles = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    birthDateCtrl.text = "2023-12-03";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ลูกค้า"),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: SizedBox(
              // height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding:
                      const EdgeInsets
                          .all(8.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(width: 5.0, color: Colors.teal),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Spacer(),
                            Icon(
                              Icons.scanner,
                              color: Colors.teal,
                              size: 32,
                            ),
                            Text(
                                "สแกน", style: TextStyle(color: Colors.teal),), Spacer(),
                          ],
                        ),
                        onPressed: () {
                          ModalDialog.waiting(
                            context: context,
                            title: const ModalTitle(text: "กำลังสแกน"),
                            message: "กรุณาใส่บัตรประจำตัวประชาชนและรอให้กระบวนการเสร็จสิ้น.",
                          );

                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              idCardCtrl.text = generateRandomString(10);
                              firstNameCtrl.text = generateRandomString(6);
                              lastNameCtrl.text = generateRandomString(6);
                              emailAddressCtrl.text = '${generateRandomString(10)}@gmail.com';
                              phoneCtrl.text = generateRandomString(12);
                              addressCtrl.text = generateRandomString(150);
                            });
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                buildTextFieldBig(
                                  labelText: 'เลขบัตรประจำตัวประชาชน'.tr(),
                                  validator: null,
                                  inputType: TextInputType.text,
                                  controller: idCardCtrl,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                buildTextFieldBig(
                                  labelText: 'ชื่อ'.tr(),
                                  validator: null,
                                  inputType: TextInputType.text,
                                  controller: firstNameCtrl,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                buildTextFieldBig(
                                  labelText: 'นามสกุล'.tr(),
                                  validator: null,
                                  inputType: TextInputType.text,
                                  controller: lastNameCtrl,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                buildTextFieldBig(
                                  labelText: 'อีเมล'.tr(),
                                  validator: null,
                                  inputType: TextInputType.emailAddress,
                                  controller: emailAddressCtrl,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                buildTextFieldBig(
                                  labelText: 'โทรศัพท์'.tr(),
                                  validator: null,
                                  inputType: TextInputType.number,
                                  controller: phoneCtrl,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: TextField(
                              controller: birthDateCtrl,
                              //editing controller of this TextField
                              style: const TextStyle(fontSize: 38),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.calendar_today),
                                //icon of text field
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                labelText: "วันเกิด".tr(),
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
                                    firstDate: DateTime.now(),
                                    //DateTime.now() - not to allow to choose before today.
                                    lastDate: DateTime(2101));
                                if (pickedDate != null) {
                                  print(
                                      pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                  print(
                                      formattedDate); //formatted date output using intl package =>  2021-03-16
                                  //you can implement different kind of Date Format here according to your requirement
                                  setState(() {
                                    birthDateCtrl.text =
                                        formattedDate; //set output date to TextField value.
                                  });
                                } else {
                                  print("Date is not selected");
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                buildTextFieldBig(
                                  line: 3,
                                  labelText: 'ที่อยู่'.tr(),
                                  validator: null,
                                  inputType: TextInputType.text,
                                  controller: addressCtrl,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.teal[700]!),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.teal[700]!)))),
              onPressed: () {

                if (idCardCtrl.text.isEmpty) {
                  idCardCtrl.text = generateRandomString(10);
                  firstNameCtrl.text = generateRandomString(6);
                  lastNameCtrl.text = generateRandomString(6);
                  emailAddressCtrl.text =
                  '${generateRandomString(10)}@gmail.com';
                  phoneCtrl.text = generateRandomString(12);
                  addressCtrl.text = generateRandomString(150);
                }

                CustomerModel customer = CustomerModel(
                  id: generateRandomString(10),
                  idCard: idCardCtrl.text,
                  firstName: firstNameCtrl.text,
                  lastName: lastNameCtrl.text,
                  email: emailAddressCtrl.text,
                  phone: phoneCtrl.text,
                  province: generateRandomString(8),
                  district: generateRandomString(10),
                  village: generateRandomString(10),
                  address: addressCtrl.text
                );

                setState(() {
                  Global.customer = customer;
                });

                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "บันทึก".tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  const Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  saveRow() {
    if (birthDateCtrl.text.isEmpty) {
      Alert.warning(
          context, 'คำเตือน'.tr(), 'กรุณาเลือกวันเกิด'.tr(), 'OK'.tr(),
          action: () {});
      return;
    }

    if (Motive.imagesFileList!.isEmpty) {
      Alert.warning(
          context, 'คำเตือน'.tr(), 'กรุณาเลือกรูปภาพ'.tr(), 'OK'.tr(),
          action: () {});
      return;
    }

    setState(() {});
  }

  openImages() async {
    try {
      var pickedFiles = await imagePicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      imageFiles = pickedFiles.map((e) => File(e.path)).toList();
      Motive.imagesFileList = imageFiles;
      setState(() {});
    } catch (e) {
      print("error while picking file.");
    }
  }
}
