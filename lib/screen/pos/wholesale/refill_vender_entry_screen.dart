import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/motive.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/customer/location.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';

class RefillVenderEntryScreen extends StatefulWidget {
  const RefillVenderEntryScreen({super.key});

  @override
  State<RefillVenderEntryScreen> createState() =>
      _RefillVenderEntryScreenState();
}

class _RefillVenderEntryScreenState extends State<RefillVenderEntryScreen> {
  final TextEditingController idCardCtrl = TextEditingController();
  final TextEditingController branchCodeCtrl = TextEditingController();
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailAddressCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController birthDateCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  List<File>? imageFiles = [];

  bool isSeller = false;
  bool isCustomer = false;
  bool isBuyer = false;

  List<String> selectedTypes = [];
  List<CustomerModel> customers = [];
  bool loading = false;
  CustomerModel? selectedCustomer;

  @override
  void initState() {
    // implement initState
    super.initState();
    birthDateCtrl.text = Global.dateOnlyT(DateTime.now().toString());
    init();
  }

  init() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
          await ApiServices.post('/customer/all', Global.requestObj(null));
      // motivePrint(result!.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<CustomerModel> products = customerListModelFromJson(data);
        setState(() {
          customers = products;
        });
      } else {
        customers = [];
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ผู้ขาย"),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SearchAnchor(builder:
                          (BuildContext context, SearchController controller) {
                        return SearchBar(
                          controller: controller,
                          padding: const WidgetStatePropertyAll<EdgeInsets>(
                              EdgeInsets.symmetric(horizontal: 16.0)),
                          onTap: () {
                            controller.openView();
                            setState(() {
                              selectedCustomer = null;
                            });
                          },
                          onChanged: (_) {
                            controller.openView();
                            setState(() {
                              selectedCustomer = null;
                            });
                          },
                          leading: const Icon(Icons.search),
                        );
                      }, suggestionsBuilder:
                          (BuildContext context, SearchController controller) {
                        return customers.isEmpty
                            ? [
                                Container(
                                  margin: const EdgeInsets.only(top: 50.0),
                                  child: const Center(child: NoDataFoundWidget()),
                                )
                              ]
                            : customers.map((e) {
                                return ListTile(
                                  title: Text('${e.firstName} ${e.lastName}',
                                      style: const TextStyle(fontSize: 20)),
                                  onTap: () {
                                    setState(() {
                                      controller.closeView(
                                          '${e.firstName} ${e.lastName}');
                                      selectedCustomer = e;
                                      Global.customer = e;
                                      // idCardCtrl.text = '${e.idCard}';
                                      // firstNameCtrl.text = '${e.firstName}';
                                      // lastNameCtrl.text = '${e.lastName}';
                                      // emailAddressCtrl.text = '${e.email}';
                                      // phoneCtrl.text = '${e.phoneNumber}';
                                      // addressCtrl.text = '${e.address}';
                                      Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          // Here you can write your code for open new view
                                        });
                                      });
                                      //
                                    });
                                  },
                                  trailing: Text(
                                    getCustomerType(e),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              });
                      }),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
                                  labelText: 'เลขบัตรประจำตัวภาษี'.tr(),
                                  validator: null,
                                  inputType: TextInputType.text,
                                  controller: idCardCtrl,
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
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                buildTextFieldBig(
                                  labelText: 'รหัสสาขา'.tr(),
                                  validator: null,
                                  inputType: TextInputType.text,
                                  controller: branchCodeCtrl,
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
                                  labelText: 'ชื่อ (หรือ บริษัท)'.tr(),
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
                                  labelText: 'นามสกุล (หรือ บริษัท)'.tr(),
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
                    const SizedBox(
                      height: 10,
                    ),
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
                                  inputType: TextInputType.phone,
                                  controller: phoneCtrl,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const LocationEntryWidget()
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
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.teal[700]!),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.teal[700]!)))),
              onPressed: () async {
                if (idCardCtrl.text.isEmpty) {
                  Alert.warning(context, 'คำเตือน',
                      'กรุณากรอกเลขประจำตัวผู้เสียภาษี', 'OK',
                      action: () {});
                  return;
                }

                if (selectedCustomer == null) {
                  var customerObject = Global.requestObj({
                    "companyName": "${firstNameCtrl.text} ${lastNameCtrl.text}",
                    "firstName": firstNameCtrl.text,
                    "lastName": lastNameCtrl.text,
                    "email": emailAddressCtrl.text,
                    "doB": birthDateCtrl.text.isEmpty
                        ? ""
                        : Global.convertDate(birthDateCtrl.text).toUtc(),
                    "phoneNumber": phoneCtrl.text,
                    "username": generateRandomString(8),
                    "password": generateRandomString(10),
                    "address": Global.addressCtrl.text,
                    "tambonId": Global.tambonModel?.id,
                    "amphureId": Global.amphureModel?.id,
                    "provinceId": Global.provinceModel?.id,
                    "nationality": '',
                    "postalCode": '',
                    "photoUrl": '',
                    "idCard": '',
                    "branchCode": branchCodeCtrl.text,
                    "taxNumber": idCardCtrl.text,
                    "isSeller": 1,
                    "isBuyer": 1,
                  });

                  // print(customerObject);
                  // return;
                  final ProgressDialog pr = ProgressDialog(context,
                      type: ProgressDialogType.normal,
                      isDismissible: true,
                      showLogs: true);
                  await pr.show();
                  pr.update(message: 'processing'.tr());
                  try {
                    var result = await ApiServices.post(
                        '/customer/create', customerObject);
                    await pr.hide();
                    if (result?.status == "success") {
                      if (mounted) {
                        CustomerModel customer =
                            customerModelFromJson(jsonEncode(result!.data!));
                        // print(customer.toJson());
                        setState(() {
                          Global.customer = customer;
                        });

                        Navigator.of(context).pop();
                      }
                    } else {
                      if (mounted) {
                        Alert.warning(context, 'Warning'.tr(), result!.message!,
                            'OK'.tr(),
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
                  }
                } else {
                  setState(() {
                    Global.customer = selectedCustomer;
                  });

                  Navigator.of(context).pop();
                }
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
      Alert.warning(context, 'คำเตือน'.tr(), 'กรุณาเลือกรูปภาพ'.tr(), 'OK'.tr(),
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
      motivePrint("error while picking file.");
    }
  }

  String getCustomerType(CustomerModel e) {
    // print(e.toJson());
    if (e.isSeller == 1) {
      return 'ผู้ขาย';
    }
    if (e.isBuyer == 1) {
      return 'ผู้ซื้อ';
    }
    if (e.isCustomer == 1) {
      return 'ลูกค้า';
    }
    return 'ลูกค้า';
  }
}
