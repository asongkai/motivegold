import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/motive.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/customer/location.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';

class EditCustomerScreen extends StatefulWidget {
  const EditCustomerScreen({super.key, required this.c});

  final CustomerModel c;

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final TextEditingController idCardCtrl = TextEditingController();
  final TextEditingController branchCodeCtrl = TextEditingController();
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailAddressCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController birthDateCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  TextEditingController remarkCtrl = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  List<File>? imageFiles = [];

  bool isSeller = false;
  bool isCustomer = false;
  bool isBuyer = false;

  ProductTypeModel? selectedType;
  ValueNotifier<dynamic>? typeNotifier;
  List<CustomerModel> customers = [];
  bool loading = false;
  CustomerModel? selectedCustomer;

  @override
  void initState() {
    // implement initState
    super.initState();

    var t = customerTypes().where((e) => e.code == widget.c.customerType);
    typeNotifier = ValueNotifier<ProductTypeModel>(
        t.isEmpty ? customerTypes()[0] : t.first);
    selectedType = t.isEmpty ? customerTypes()[0] : t.first;
    birthDateCtrl.text = Global.dateOnlyT(DateTime.now().toString());
    Global.addressCtrl.text = "";
    // init();
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
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("แก้ไขลูกค้า"),
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
                      child: SizedBox(
                        height: 70,
                        child: MiraiDropDownMenu<ProductTypeModel>(
                          key: UniqueKey(),
                          children: customerTypes(),
                          space: 4,
                          maxHeight: 360,
                          showSearchTextField: true,
                          selectedItemBackgroundColor: Colors.transparent,
                          emptyListMessage: 'ไม่มีข้อมูล',
                          showSelectedItemBackgroundColor: true,
                          itemWidgetBuilder: (
                            int index,
                            ProductTypeModel? project, {
                            bool isItemSelected = false,
                          }) {
                            return DropDownItemWidget(
                              project: project,
                              isItemSelected: isItemSelected,
                              firstSpace: 10,
                              fontSize: size.getWidthPx(8),
                            );
                          },
                          onChanged: (ProductTypeModel value) {
                            selectedType = value;
                            typeNotifier!.value = value;
                            setState(() {});
                          },
                          child: DropDownObjectChildWidget(
                            key: GlobalKey(),
                            fontSize: size.getWidthPx(8),
                            projectValueNotifier: typeNotifier!,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Card(
                      child: Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text(
                                "คือลูกค้า",
                                style: TextStyle(fontSize: 20),
                              ),
                              value: isCustomer,
                              visualDensity: VisualDensity.standard,
                              activeColor: Colors.teal,
                              onChanged: (newValue) {
                                setState(() {
                                  isCustomer = newValue!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text(
                                "เป็นผู้ซื้อ",
                                style: TextStyle(fontSize: 20),
                              ),
                              value: isBuyer,
                              visualDensity: VisualDensity.standard,
                              activeColor: Colors.teal,
                              onChanged: (newValue) {
                                setState(() {
                                  isBuyer = newValue!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text(
                                "เป็นผู้ขาย",
                                style: TextStyle(fontSize: 20),
                              ),
                              value: isSeller,
                              visualDensity: VisualDensity.standard,
                              activeColor: Colors.teal,
                              onChanged: (newValue) {
                                setState(() {
                                  isSeller = newValue!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
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
                                  labelText: getIdTitle(),
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
                    const LocationEntryWidget(),
                    const SizedBox(
                      height: 15,
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
                                  line: 2,
                                  labelText: 'หมายเหตุ'.tr(),
                                  validator: null,
                                  inputType: TextInputType.text,
                                  controller: remarkCtrl,
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
                    "customerType": selectedType?.code,
                    "companyName": "${firstNameCtrl.text} ${lastNameCtrl.text}",
                    "firstName": firstNameCtrl.text,
                    "lastName": lastNameCtrl.text,
                    "email": emailAddressCtrl.text,
                    "doB": "2024-04-25T12:59:54.676Z",
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
                    "branchCode": branchCodeCtrl.text,
                    "idCard":
                        selectedType?.code == "general" ? idCardCtrl.text : "",
                    "taxNumber":
                        selectedType?.code == "company" ? idCardCtrl.text : "",
                    "isSeller": isSeller ? 1 : 0,
                    "isBuyer": isBuyer ? 1 : 0,
                    "isCustomer": isCustomer ? 1 : 0,
                    "remark": remarkCtrl.text,
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
                    motivePrint(result?.toJson());
                    await pr.hide();
                    if (result?.status == "success") {
                      if (mounted) {
                        CustomerModel customer =
                            customerModelFromJson(jsonEncode(result!.data!));
                        // print(customer.toJson());
                        setState(() {
                          Global.customer = customer;
                        });
                        Alert.warning(context, 'Success'.tr(),
                            "บันทึกเรียบร้อยแล้ว", 'OK'.tr(), action: () {
                          Navigator.of(context).pop();
                        });
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

  getIdTitle() {
    return selectedType?.code == 'company'
        ? 'เลขบัตรประจำตัวภาษี'
        : 'เลขบัตรประจำตัวประชาชน';
  }
}
