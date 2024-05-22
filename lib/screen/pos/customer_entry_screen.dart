import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modal_dialog/flutter_modal_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/motive.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:thai_idcard_reader_flutter/thai_idcard_reader_flutter.dart';

import '../../api/api_services.dart';
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

  ThaiIDCard? _data;
  var _error;
  UsbDevice? _device;
  var _card;
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
    birthDateCtrl.text = "2023-12-03";
    ThaiIdcardReaderFlutter.deviceHandlerStream.listen(_onUSB);
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
        _error = "_onUSB " + e.toString();
      });
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
        _error = "_onData " + e.toString();
      });
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
        addressCtrl.text = _data!.address!;
        //birthDateCtrl.text = '${formattedDate(_data!.birthdate)}';
      }
      setState(() {

      });
    } catch (e) {
      setState(() {
        _error = 'ERR readCard $e';
      });
      if (mounted) {
        Alert.warning(context, 'Warning'.tr(), '$e', 'OK'.tr());
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
                    if (_device != null)
                      UsbDeviceCard(
                        device: _device,
                      ),
                    if (_card != null) Text(_card.toString()),
                    if (_device == null || !_device!.isAttached) ...[
                      const EmptyHeader(
                        text: 'เสียบเครื่องอ่านบัตรก่อน',
                      ),
                    ],
                    if (_error != null) Text(_error.toString()),
                    if (_data == null && (_device != null && _device!.hasPermission)) ...[
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(width: 5.0, color: Colors.teal),
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
                              "สแกน",
                              style: TextStyle(color: Colors.teal),
                            ),
                            Spacer(),
                          ],
                        ),
                        onPressed: () {
                          ModalDialog.waiting(
                            context: context,
                            title: const ModalTitle(text: "กำลังสแกน"),
                            message:
                                "กรุณาใส่บัตรประจำตัวประชาชนและรอให้กระบวนการเสร็จสิ้น.",
                          );

                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              idCardCtrl.text = generateRandomString(10);
                              firstNameCtrl.text = generateRandomString(6);
                              lastNameCtrl.text = generateRandomString(6);
                              emailAddressCtrl.text =
                                  '${generateRandomString(10)}@gmail.com';
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
              onPressed: () async {
                if (idCardCtrl.text.isEmpty) {
                  idCardCtrl.text = generateRandomString(10);
                  firstNameCtrl.text = generateRandomString(6);
                  lastNameCtrl.text = generateRandomString(6);
                  emailAddressCtrl.text =
                      '${generateRandomString(10)}@gmail.com';
                  phoneCtrl.text = generateRandomString(12);
                  addressCtrl.text = generateRandomString(150);
                }

                var customerObject = Global.requestObj({
                  "companyName": generateRandomString(10),
                  "fistName": firstNameCtrl.text,
                  "lastName": lastNameCtrl.text,
                  "email": emailAddressCtrl.text,
                  "doB": "2024-04-25T12:59:54.676Z",
                  "phoneNumber": phoneCtrl.text,
                  "username": generateRandomString(8),
                  "password": generateRandomString(10),
                  "address": addressCtrl.text,
                  "district": generateRandomString(10),
                  "province": generateRandomString(10),
                  "nationality": generateRandomString(10),
                  "postalCode": generateRandomString(4),
                  "photoUrl": generateRandomString(10),
                  "idCard": generateRandomString(10),
                  "taxNumber": generateRandomString(10)
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
                  var result =
                      await ApiServices.post('/customer/create', customerObject);
                  await pr.hide();
                  if (result?.status == "success") {
                    if (mounted) {
                      CustomerModel customer = customerModelFromJson(
                          jsonEncode(result!.data!));
                      // print(customer.toJson());
                      setState(() {
                        Global.customer = customer;
                      });

                      Navigator.of(context).pop();
                    }
                  } else {
                    if (mounted) {
                      Alert.warning(
                          context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
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
      print("error while picking file.");
    }
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
            height: 300,
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

    _copyFn(value) {
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
                onTap: () => _copyFn(value),
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
