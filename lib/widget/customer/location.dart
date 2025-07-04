import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownObjectChildWidget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sizer/sizer.dart';

class LocationEntryWidget extends StatefulWidget {
  const LocationEntryWidget({super.key});

  @override
  State<LocationEntryWidget> createState() => _LocationEntryWidgetState();
}

class _LocationEntryWidgetState extends State<LocationEntryWidget> {

  bool loading = false;

  @override
  void initState() {
    // implement initState
    super.initState();
    Global.provinceNotifier = ValueNotifier<ProvinceModel>(
        ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด'));
    Global.amphureNotifier = ValueNotifier<AmphureModel>(
        AmphureModel(id: 0, nameTh: 'เลือกอำเภอ'));
    Global.tambonNotifier = ValueNotifier<TambonModel>(
        TambonModel(id: 0, nameTh: 'เลือกตำบล'));
    init();
  }

  init() async {
    setState(() {
      loading = true;
    });
    try {

      var province =
      await ApiServices.post('/customer/province', Global.requestObj(null));
      // motivePrint(province!.toJson());
      if (province?.status == "success") {
        var data = jsonEncode(province?.data);
        List<ProvinceModel> products = provinceModelFromJson(data);
        setState(() {
          Global.provinceList = products;
        });
      } else {
        Global.provinceList = [];
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('เลือกจังหวัด', style: TextStyle(fontSize: 16.sp, color: textColor),),
                    const SizedBox(height: 4,),
                    SizedBox(
                      height: 70,
                      child: MiraiDropDownMenu<ProvinceModel>(
                        key: UniqueKey(),
                        children: Global.provinceList,
                        space: 4,
                        maxHeight: 360,
                        showSearchTextField: true,
                        selectedItemBackgroundColor: Colors.transparent,
                        emptyListMessage: 'ไม่มีข้อมูล',
                        showSelectedItemBackgroundColor: true,
                        itemWidgetBuilder: (
                            int index,
                            ProvinceModel? project, {
                              bool isItemSelected = false,
                            }) {
                          return LocationDropDownItemWidget(
                            project: project,
                            isItemSelected: isItemSelected,
                            firstSpace: 10,
                            fontSize: 16.sp,
                          );
                        },
                        onChanged: (ProvinceModel value) {
                          Global.provinceModel = value;
                          Global.provinceNotifier!.value = value;
                          loadAmphureByProvince(value.id);
                        },
                        child: LocationDropDownObjectChildWidget(
                          key: GlobalKey(),
                          fontSize: 16.sp,
                          projectValueNotifier:
                          Global.provinceNotifier!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('เลือกอำเภอ', style: TextStyle(fontSize: 16.sp, color: textColor),),
                    const SizedBox(height: 4,),
                    SizedBox(
                      height: 70,
                      child: MiraiDropDownMenu<AmphureModel>(
                        key: UniqueKey(),
                        children: Global.amphureList,
                        space: 4,
                        maxHeight: 360,
                        showSearchTextField: true,
                        selectedItemBackgroundColor: Colors.transparent,
                        emptyListMessage: 'ไม่มีข้อมูล',
                        showSelectedItemBackgroundColor: true,
                        itemWidgetBuilder: (
                            int index,
                            AmphureModel? project, {
                              bool isItemSelected = false,
                            }) {
                          return LocationDropDownItemWidget(
                            project: project,
                            isItemSelected: isItemSelected,
                            firstSpace: 10,
                            fontSize: 16.sp,
                          );
                        },
                        onChanged: (AmphureModel value) {
                          Global.amphureModel = value;
                          Global.amphureNotifier!.value = value;
                          loadTambonByAmphure(value.id);
                        },
                        child: LocationDropDownObjectChildWidget(
                          key: GlobalKey(),
                          fontSize: 16.sp,
                          projectValueNotifier: Global.amphureNotifier!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('เลือกตำบล', style: TextStyle(fontSize: 16.sp, color: textColor),),
                    const SizedBox(height: 4,),
                    SizedBox(
                      height: 70,
                      child: MiraiDropDownMenu<TambonModel>(
                        key: UniqueKey(),
                        children: Global.tambonList,
                        space: 4,
                        maxHeight: 360,
                        showSearchTextField: true,
                        selectedItemBackgroundColor: Colors.transparent,
                        emptyListMessage: 'ไม่มีข้อมูล',
                        showSelectedItemBackgroundColor: true,
                        itemWidgetBuilder: (
                            int index,
                            TambonModel? project, {
                              bool isItemSelected = false,
                            }) {
                          return LocationDropDownItemWidget(
                            project: project,
                            isItemSelected: isItemSelected,
                            firstSpace: 10,
                            fontSize: 16.sp,
                          );
                        },
                        onChanged: (TambonModel value) {
                          Global.tambonModel = value;
                          Global.tambonNotifier!.value = value;
                        },
                        child: LocationDropDownObjectChildWidget(
                          key: GlobalKey(),
                          fontSize: 16.sp,
                          projectValueNotifier:
                          Global.tambonNotifier!,
                        ),
                      ),
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
                      line: 3,
                      labelText: 'ที่อยู่'.tr(),
                      validator: null,
                      inputType: TextInputType.text,
                      controller: Global.addressCtrl,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void loadAmphureByProvince(int? id) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result =
      await ApiServices.post('/customer/amphure/$id', Global.requestObj(null));
      // motivePrint(result!.toJson());
      await pr.hide();
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<AmphureModel> products = amphureModelFromJson(data);
        setState(() {
          Global.amphureList = products;
        });
      } else {
        Global.amphureList = [];
      }

    } catch (e) {
      await pr.hide();
      motivePrint(e.toString());
    }
  }

  void loadTambonByAmphure(int? id) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result =
      await ApiServices.post('/customer/tambon/$id', Global.requestObj(null));
      // motivePrint(result!.toJson());
      await pr.hide();
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<TambonModel> products = tambonModelFromJson(data);
        setState(() {
          Global.tambonList = products;
        });
      } else {
        Global.tambonList = [];
      }

    } catch (e) {
      await pr.hide();
      motivePrint(e.toString());
    }
  }
}
