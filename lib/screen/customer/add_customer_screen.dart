import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/motive.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/customer/location.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';
import 'package:thai_idcard_reader_flutter/thai_idcard_reader_flutter.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController idCardCtrl = TextEditingController();
  final TextEditingController branchCodeCtrl = TextEditingController();
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailAddressCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController birthDateCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  TextEditingController companyNameCtrl = TextEditingController();
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

  ThaiIDCard? _data;
  String? _error;
  UsbDevice? _device;
  dynamic _card;
  StreamSubscription? subscription;
  final List _idCardType = [
    ThaiIDType.cid,
    ThaiIDType.photo,
    ThaiIDType.nameTH,
    ThaiIDType.nameEN,
    ThaiIDType.gender,
    ThaiIDType.birthdate,
    ThaiIDType.address,
    ThaiIDType.issueDate,
    ThaiIDType.expireDate,
  ];
  List<String> selectedTypes = [];

  @override
  void initState() {
    // implement initState
    super.initState();
    typeNotifier = ValueNotifier<ProductTypeModel>(customerTypes()[1]);
    selectedType = customerTypes()[1];
    // birthDateCtrl.text = Global.dateOnlyT(DateTime.now().toString());
    Global.addressCtrl.text = "";
    ThaiIdcardReaderFlutter.deviceHandlerStream.listen(_onUSB);
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

  void _onUSB(usbEvent) {
    try {
      if (usbEvent.hasPermission) {
        subscription =
            ThaiIdcardReaderFlutter.cardHandlerStream.listen(_onData);
      } else {
        if (subscription == null) {
          subscription?.cancel();
          subscription = null;
        }
        _clear();
      }
      setState(() {
        _device = usbEvent;
      });
    } catch (e) {
      setState(() {
        _error = "_onUSB $e";
      });
      Alert.error(context, 'OnUsb', "$e", 'OK', action: () {});
    }
  }

  void _onData(readerEvent) {
    try {
      setState(() {
        _card = readerEvent;
      });
      if (readerEvent.isReady) {
        readCard(only: selectedTypes);
      } else {
        _clear();
      }
    } catch (e) {
      setState(() {
        _error = "_onData $e";
      });
      Alert.error(context, 'OnData', "$e", 'OK', action: () {});
    }
  }

  readCard({List<String> only = const []}) async {
    try {
      var response = await ThaiIdcardReaderFlutter.read(only: only);
      setState(() {
        _data = response;
      });

      if (_data != null) {
        idCardCtrl.text = _data!.cid!;
        if (_data!.firstnameTH != null) {
          firstNameCtrl.text = '${_data!.titleTH} ${_data!.firstnameTH}';
          lastNameCtrl.text = '${_data?.lastnameTH!}';
        } else {
          firstNameCtrl.text = '${_data!.titleEN} ${_data!.firstnameEN}';
          lastNameCtrl.text = '${_data?.lastnameEN!}';
        }
        emailAddressCtrl.text = "";
        phoneCtrl.text = "";
        var address0 = _data!.address ?? "";

        if (address0.isNotEmpty) {
          var sp1 = address0.split("ตำบล");
          var sp2 = sp1[1].split("อำเภอ");
          var sp3 = sp2[1].split("จังหวัด");

          var address = sp1[0].trimLeft().trimRight();
          var tambon = sp2[0].trimLeft().trimRight();
          var ampher = sp3[0].trimLeft().trimRight();
          var chunvat = sp3[1].trimLeft().trimRight();

          Global.addressCtrl.text = address0;

          int? chungVatId = filterChungVatByName(chunvat);
          await loadAmphureByProvince(chungVatId);
          int? ampherId = filterAmpheryName(ampher);
          await loadTambonByAmphure(ampherId);
          int? tambonId = filterTambonByName(tambon);
          Alert.success(context, 'Success', 'ID Synced', 'OK', action: () {
            setState(() {});
          });
        }

        birthDateCtrl.text = Global.formatDateDD(_data!.birthdate!);
      }
      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'ERR readCard $e';
      });
      if (mounted) {
        Alert.warning(context, 'ERR readCard'.tr(), '$e', 'OK'.tr());
      }
    }
  }

  formattedDate(dt) {
    try {
      DateTime dateTime = DateTime.parse(dt);
      String formattedDate = DateFormat.yMMMMd('th_TH').format(dateTime);
      return formattedDate;
    } catch (e) {
      return dt.split('').toString() + e.toString();
    }
  }

  _clear() {
    setState(() {
      _data = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("เพิ่มลูกค้า"),
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
                    if (selectedType?.code == 'general')
                      if (_device != null)
                        UsbDeviceCard(
                          device: _device,
                        ),
                    if (selectedType?.code == 'general')
                      if (_card != null) Text(_card.toString()),
                    if (selectedType?.code == 'general')
                      if (_device == null || !_device!.isAttached) ...[
                        const EmptyHeader(
                          text: 'เสียบเครื่องอ่านบัตรก่อน',
                        ),
                      ],
                    if (selectedType?.code == 'general')
                      if (_error != null) Text(_error.toString()),
                    if (selectedType?.code == 'general')
                      if (_data == null &&
                          (_device != null && _device!.hasPermission)) ...[
                        const EmptyHeader(
                          icon: Icons.credit_card,
                          text: 'เสียบบัตรประชาชนได้เลย',
                        ),
                        SizedBox(
                          height: 200,
                          child: Wrap(children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                    value: selectedTypes.isEmpty,
                                    onChanged: (val) {
                                      setState(() {
                                        if (selectedTypes.isNotEmpty) {
                                          selectedTypes = [];
                                        }
                                      });
                                    }),
                                const Text('readAll'),
                              ],
                            ),
                            for (var ea in _idCardType)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                      value: selectedTypes.contains(ea),
                                      onChanged: (val) {
                                        motivePrint(ea);
                                        setState(() {
                                          if (selectedTypes.contains(ea)) {
                                            selectedTypes.remove(ea);
                                          } else {
                                            selectedTypes.add(ea);
                                          }
                                        });
                                      }),
                                  Text('$ea'),
                                ],
                              ),
                          ]),
                        ),
                      ],
                    if (selectedType?.code == 'general')
                      const SizedBox(
                        height: 10,
                      ),
                    if (selectedType?.code == 'general')
                      if (_data != null)
                        if (_data!.photo.isNotEmpty)
                          Center(
                            child: Image.memory(
                              Uint8List.fromList(_data!.photo),
                            ),
                          ),
                    const SizedBox(
                      height: 10,
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
                        if (selectedType?.code == 'company')
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
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedType?.code == 'general')
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
                        if (selectedType?.code == 'general')
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
                        if (selectedType?.code == 'company')
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
                                    labelText: 'ชื่อบริษัท'.tr(),
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
                    if (selectedType?.code == 'general')
                      const SizedBox(
                        height: 15,
                      ),
                    if (selectedType?.code == 'general')
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
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
                                    motivePrint(
                                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    motivePrint(
                                        formattedDate); //formatted date output using intl package =>  2021-03-16
                                    //you can implement different kind of Date Format here according to your requirement
                                    setState(() {
                                      birthDateCtrl.text =
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
                  Alert.warning(
                      context, 'คำเตือน', 'กรุณากรอก${getIdTitle()}', 'OK',
                      action: () {});
                  return;
                }

                if (selectedCustomer == null) {
                  var customerObject = Global.requestObj({
                    "customerType": selectedType?.code,
                    "companyName": companyNameCtrl.text,
                    "firstName": firstNameCtrl.text,
                    "lastName": lastNameCtrl.text,
                    "email": emailAddressCtrl.text,
                    "doB": birthDateCtrl.text.isEmpty
                        ? ""
                        : DateTime.parse(birthDateCtrl.text).toUtc().toString(),
                    "phoneNumber": phoneCtrl.text,
                    "username": generateRandomString(8),
                    "password": generateRandomString(10),
                    "address": Global.addressCtrl.text,
                    "tambonId": Global.tambonModel?.id,
                    "amphureId": Global.amphureModel?.id,
                    "provinceId": Global.provinceModel?.id,
                    "nationality    ": '',
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

                  print(customerObject);
                  // return;
                  final ProgressDialog pr = ProgressDialog(context,
                      type: ProgressDialogType.normal,
                      isDismissible: true,
                      showLogs: true);
                  await pr.show();
                  pr.update(message: 'processing'.tr());
                  // try {
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
                        Alert.success(context, 'Success'.tr(),
                            "บันทึกเรียบร้อยแล้ว", 'OK'.tr(), action: () {
                          Navigator.of(context).pop();
                        });
                      }
                    } else {
                      if (mounted) {
                        Alert.warning(context, 'Warning'.tr(), result!.message ?? result.data,
                            'OK'.tr(),
                            action: () {});
                      }
                    }
                  // } catch (e) {
                  //   await pr.hide();
                  //   if (mounted) {
                  //     Alert.warning(
                  //         context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
                  //         action: () {});
                  //   }
                  // }
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

class EmptyHeader extends StatelessWidget {
  final IconData? icon;
  final String? text;

  const EmptyHeader({
    this.icon,
    this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: SizedBox(
            height: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon ?? Icons.usb,
                  size: 60,
                ),
                Center(
                    child: Text(
                  text ?? 'Empty',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            )));
  }
}

class UsbDeviceCard extends StatelessWidget {
  final dynamic device;

  const UsbDeviceCard({
    Key? key,
    this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: device.isAttached ? 1.0 : 0.5,
      child: Card(
        child: ListTile(
          leading: const Icon(
            Icons.usb,
            size: 32,
          ),
          title: Text('${device!.manufacturerName} ${device!.productName}'),
          subtitle: Text(device!.identifier ?? ''),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            color: device!.hasPermission ? Colors.green : Colors.grey,
            child: Text(
                device!.hasPermission
                    ? 'Listening'
                    : (device!.isAttached ? 'Connected' : 'Disconnected'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
      ),
    );
  }
}

class DisplayInfo extends StatelessWidget {
  const DisplayInfo({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    TextStyle sTitle =
        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    TextStyle sVal = const TextStyle(fontSize: 28);

    copyFn(value) {
      Clipboard.setData(ClipboardData(text: value)).then((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Copy it already")));
      });
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '$title : ',
                style: sTitle,
              ),
            ],
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: sVal,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => copyFn(value),
                child: const Icon(Icons.copy),
              )
            ],
          ),
          const Divider(
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}