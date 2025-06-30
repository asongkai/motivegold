import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/bank/bank.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';

class EditTambonScreen extends StatefulWidget {
  final TambonModel tambon;
  final int index;

  const EditTambonScreen(
      {super.key, required this.tambon, required this.index});

  @override
  State<EditTambonScreen> createState() => _EditTambonScreenState();
}

class _EditTambonScreenState extends State<EditTambonScreen> {
  final TextEditingController nameTHCtrl = TextEditingController();
  final TextEditingController nameENCtrl = TextEditingController();
  final TextEditingController zipCodeCtrl = TextEditingController();

  ProvinceModel? selectedProvince;
  ValueNotifier<dynamic>? provinceNotifier;

  AmphureModel? selectedAmphure;
  ValueNotifier<dynamic>? amphureNotifier;
  bool loading = false;

  @override
  void initState() {
    // implement initState
    super.initState();
    nameTHCtrl.text = widget.tambon.nameTh ?? '';
    nameENCtrl.text = widget.tambon.nameEn ?? '';
    zipCodeCtrl.text = widget.tambon.zipCode.toString();

    provinceNotifier = ValueNotifier<ProvinceModel>(
        selectedProvince ?? ProvinceModel(nameTh: 'เลือกจังหวัด', id: 0));

    amphureNotifier = ValueNotifier<AmphureModel>(
        selectedAmphure ?? AmphureModel(nameTh: 'เลือกอำเภอ', id: 0));

    init();
  }

  init() async {
    setState(() {
      loading = true;
    });

    try {
      var result =
          await ApiServices.get('/location/amphure/${widget.tambon.amphureId}');
      motivePrint(result?.toJson());
      if (result?.status == "success") {
        var amphure = AmphureModel.fromJson(result?.data);
        var provinceId = amphure.provinceId;
        await loadAmphureByProvince(provinceId);
        var provinces = Global.provinceList.where((e) => e.id == provinceId);
        if (provinces.isNotEmpty) {
          selectedProvince = provinces.first;
        }
        var amphures =
            Global.amphureList.where((e) => e.id == widget.tambon.amphureId);
        if (amphures.isNotEmpty) {
          selectedAmphure = amphures.first;
        }
        provinceNotifier = ValueNotifier<ProvinceModel>(
            selectedProvince ?? ProvinceModel(nameTh: 'เลือกจังหวัด', id: 0));

        amphureNotifier = ValueNotifier<AmphureModel>(
            selectedAmphure ?? AmphureModel(nameTh: 'เลือกอำเภอ', id: 0));
        setState(() {});
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
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("แก้ไขตำบล",
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
              ? Center(
                  child: LoadingProgress(),
                )
              : SingleChildScrollView(
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
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เลือกจังหวัด',
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(10),
                                                color: textColor),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          SizedBox(
                                            height: 70,
                                            child: MiraiDropDownMenu<
                                                ProvinceModel>(
                                              key: UniqueKey(),
                                              children: Global.provinceList,
                                              space: 4,
                                              maxHeight: 360,
                                              showSearchTextField: true,
                                              selectedItemBackgroundColor:
                                                  Colors.transparent,
                                              emptyListMessage: 'ไม่มีข้อมูล',
                                              showSelectedItemBackgroundColor:
                                                  true,
                                              itemWidgetBuilder: (
                                                int index,
                                                ProvinceModel? project, {
                                                bool isItemSelected = false,
                                              }) {
                                                return LocationDropDownItemWidget(
                                                  project: project,
                                                  isItemSelected:
                                                      isItemSelected,
                                                  firstSpace: 10,
                                                  fontSize: size.getWidthPx(8),
                                                );
                                              },
                                              onChanged: (ProvinceModel value) {
                                                selectedProvince = value;
                                                provinceNotifier!.value = value;
                                                loadAmphureByProvince(value.id);
                                                selectedAmphure = null;
                                                amphureNotifier = ValueNotifier<AmphureModel>(
                                                    selectedAmphure ?? AmphureModel(nameTh: 'เลือกอำเภอ', id: 0));
                                                setState(() {});
                                              },
                                              child:
                                                  LocationDropDownObjectChildWidget(
                                                key: GlobalKey(),
                                                fontSize: size.getWidthPx(8),
                                                projectValueNotifier:
                                                    provinceNotifier!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เลือกอำเภอ',
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(10),
                                                color: textColor),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          SizedBox(
                                            height: 70,
                                            child:
                                                MiraiDropDownMenu<AmphureModel>(
                                              key: UniqueKey(),
                                              children: Global.amphureList,
                                              space: 4,
                                              maxHeight: 360,
                                              showSearchTextField: true,
                                              selectedItemBackgroundColor:
                                                  Colors.transparent,
                                              emptyListMessage: 'ไม่มีข้อมูล',
                                              showSelectedItemBackgroundColor:
                                                  true,
                                              itemWidgetBuilder: (
                                                int index,
                                                AmphureModel? project, {
                                                bool isItemSelected = false,
                                              }) {
                                                return LocationDropDownItemWidget(
                                                  project: project,
                                                  isItemSelected:
                                                      isItemSelected,
                                                  firstSpace: 10,
                                                  fontSize: size.getWidthPx(8),
                                                );
                                              },
                                              onChanged: (AmphureModel value) {
                                                selectedAmphure = value;
                                                amphureNotifier!.value = value;
                                              },
                                              child:
                                                  LocationDropDownObjectChildWidget(
                                                key: GlobalKey(),
                                                fontSize: size.getWidthPx(8),
                                                projectValueNotifier:
                                                    amphureNotifier!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            labelText: 'ชื่อตำบล (TH)'.tr(),
                                            labelColor: Colors.orange,
                                            validator: null,
                                            inputType: TextInputType.text,
                                            controller: nameTHCtrl,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
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
                                          labelText: 'ชื่อตำบล (EN)'.tr(),
                                          labelColor: Colors.orange,
                                          validator: null,
                                          inputType: TextInputType.text,
                                          controller: nameENCtrl,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
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
                                          labelText: 'Zip Code'.tr(),
                                          labelColor: Colors.orange,
                                          validator: null,
                                          inputType: TextInputType.text,
                                          controller: zipCodeCtrl,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                if (selectedProvince == null) {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณาเลือกจังหวัด', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (selectedAmphure == null) {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณาเลือกอำเภอ', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (nameTHCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกชื่อ', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (zipCodeCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอก Zip Code', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "id": widget.tambon.id,
                  "nameTH": nameTHCtrl.text,
                  "nameEN": nameENCtrl.text,
                  "provinceId": selectedProvince?.id,
                  "amphureId": selectedAmphure?.id,
                  "zipCode": Global.toNumber(zipCodeCtrl.text),
                });

                Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                    action: () async {
                  // return;
                  final ProgressDialog pr = ProgressDialog(context,
                      type: ProgressDialogType.normal,
                      isDismissible: true,
                      showLogs: true);
                  await pr.show();
                  pr.update(message: 'processing'.tr());
                  try {
                    var result = await ApiServices.put(
                        '/location/tambon', widget.tambon.id, object);
                    await pr.hide();
                    if (result?.status == "success") {
                      if (mounted) {
                        Alert.success(context, 'Success'.tr(), '', 'OK'.tr(),
                            action: () {
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
                });
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
    setState(() {});
  }
}
