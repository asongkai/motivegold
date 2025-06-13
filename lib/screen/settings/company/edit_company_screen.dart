import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/image/profile_image.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/util.dart';

class EditCompanyScreen extends StatefulWidget {
  final bool showBackButton;
  final CompanyModel company;
  final int index;

  const EditCompanyScreen(
      {super.key,
      required this.showBackButton,
      required this.company,
      required this.index});

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  int? id;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController taxNumberCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController provinceCtrl = TextEditingController();

  bool loading = false;
  String? logo;
  File? file;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.company.id;
    nameCtrl.text = widget.company.name ?? '';
    emailCtrl.text = widget.company.email ?? '';
    phoneCtrl.text = widget.company.phone ?? '';
    addressCtrl.text = widget.company.address ?? '';
    villageCtrl.text = widget.company.village ?? '';
    districtCtrl.text = widget.company.district ?? '';
    provinceCtrl.text = widget.company.province ?? '';
    taxNumberCtrl.text = widget.company.taxNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.showBackButton,
          title: const Text("แก้ไขบริษัท",
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
          child: loading
              ? const LoadingProgress()
              : SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          if (logo != null)
                            Container(
                              height: 220.0,
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Center(
                                      child: Text(
                                    'โลโก้บริษัท',
                                    style: TextStyle(
                                        fontSize: 30, color: textColor),
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Stack(
                                        fit: StackFit.loose,
                                        children: <Widget>[
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {},
                                                child: ProfilePhoto(
                                                  totalWidth: 140,
                                                  cornerRadius: 80,
                                                  color: Colors.blue,
                                                  image: FileImage(file!),
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _settingModalBottomSheet(context);
                                            },
                                            child: const Padding(
                                                padding: EdgeInsets.only(
                                                    top: 90.0, right: 100.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      radius: 25.0,
                                                      child: Icon(
                                                        Icons.camera_alt,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  ],
                                                )),
                                          ),
                                        ]),
                                  )
                                ],
                              ),
                            ),
                          if (logo == null)
                            Container(
                              height: 220.0,
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Center(
                                      child: Text(
                                    'โลโก้บริษัท',
                                    style: TextStyle(
                                        fontSize: 30, color: textColor),
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Stack(
                                        fit: StackFit.loose,
                                        children: <Widget>[
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                  width: 140.0,
                                                  height: 140.0,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/no_image.png'),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _settingModalBottomSheet(context);
                                            },
                                            child: const Padding(
                                                padding: EdgeInsets.only(
                                                    top: 90.0, right: 100.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      radius: 25.0,
                                                      child: Icon(
                                                        Icons.camera_alt,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  ],
                                                )),
                                          ),
                                        ]),
                                  )
                                ],
                              ),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'ชื่อบริษัท',
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: nameCtrl,
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'โทรศัพท์',
                                        validator: null,
                                        inputType: TextInputType.phone,
                                        controller: phoneCtrl,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'อีเมล',
                                        validator: null,
                                        inputType: TextInputType.emailAddress,
                                        controller: emailCtrl,
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'จังหวัด',
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: provinceCtrl,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'เขต',
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: districtCtrl,
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'บ้าน',
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: villageCtrl,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'ที่อยู่',
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
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'หมายเลขประจำตัวผู้เสียภาษี',
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: taxNumberCtrl,
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
                if (nameCtrl.text.trim() == "") {
                  Alert.warning(context, 'warning', 'กรุณากรอกข้อมูล', 'OK',
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "id": id,
                  "name": nameCtrl.text,
                  "email": emailCtrl.text,
                  "phone": phoneCtrl.text,
                  "address": addressCtrl.text,
                  "village": villageCtrl.text,
                  "district": districtCtrl.text,
                  "province": provinceCtrl.text,
                  "taxNumber": taxNumberCtrl.text,
                  "logo": logo
                });

                Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                    action: () async {
                  final ProgressDialog pr = ProgressDialog(context,
                      type: ProgressDialogType.normal,
                      isDismissible: true,
                      showLogs: true);
                  await pr.show();
                  pr.update(message: 'processing');
                  try {
                    var result = await ApiServices.put('/company', id, object);
                    await pr.hide();
                    if (result?.status == "success") {
                      if (mounted) {
                        // motivePrint(result?.data);
                        var c = CompanyModel.fromJson(result?.data);
                        if (c.id == Global.company?.id) {
                          Global.company = CompanyModel.fromJson(result?.data);
                          setState(() {});
                        }
                        Alert.success(context, 'Success', '', 'OK', action: () {
                          Navigator.of(context).pop();
                        });
                      }
                    } else {
                      if (mounted) {
                        Alert.warning(
                            context, 'Warning', result!.message!, 'OK',
                            action: () {});
                      }
                    }
                  } catch (e) {
                    await pr.hide();
                    if (mounted) {
                      Alert.warning(context, 'Warning', e.toString(), 'OK',
                          action: () {});
                    }
                  }
                });
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "บันทึก",
                    style: TextStyle(color: Colors.white, fontSize: 32),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Icon(
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

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('ถ่ายรูป'),
                  onTap: () {
                    pickProfileImage(context, ImageSource.camera);
                  }),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('เลือกรูป'),
                onTap: () {
                  pickProfileImage(context, ImageSource.gallery);
                },
              ),
            ],
          );
        });
  }

  void pickProfileImage(BuildContext context, ImageSource imageSource) async {
    final XFile? image = await picker.pickImage(source: imageSource);
    setState(() {
      if (image != null) {
        file = File(image.path);
        logo = Global.imageToBase64(file!);
      }
    });
    Navigator.of(context).pop();
  }
}
