import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/pos_id.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';

class ConfigurePosIDScreen extends StatefulWidget {
  const ConfigurePosIDScreen({super.key, this.posIdModel});

  final PosIdModel? posIdModel;

  @override
  State<ConfigurePosIDScreen> createState() => _ConfigurePosIDScreenState();
}

class _ConfigurePosIDScreenState extends State<ConfigurePosIDScreen> {
  final TextEditingController posIdCtrl = TextEditingController();
  final TextEditingController detailCtrl = TextEditingController();
  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController deviceIdCtrl = TextEditingController();

  bool loading = false;
  List<BranchModel>? branches;
  BranchModel? selectedBranch;
  ValueNotifier<dynamic>? branchNotifier;

  @override
  void initState() {
    // implement initState
    super.initState();
    // motivePrint(Global.user!.userRole);
    if (widget.posIdModel?.branchId != null) {
      selectedBranch = Global.branchList
          .where((e) => e.id == widget.posIdModel?.branchId)
          .first;
    } else {
      selectedBranch =
          Global.branchList.where((e) => e.id == Global.user?.branchId).first;
    }
    branchNotifier = ValueNotifier<BranchModel>(
        selectedBranch ?? BranchModel(id: 0, name: 'เลือกสาขา'));

    posIdCtrl.text = widget.posIdModel?.posId ?? '';
    detailCtrl.text = widget.posIdModel?.detail ?? '';

    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      deviceIdCtrl.text = (await getDeviceId())!;
      var result =
          await ApiServices.get('/branch/by-company/${Global.user!.companyId}');
      // print(result!.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);

        List<BranchModel> products = branchListModelFromJson(data);
        setState(() {
          branches = products;
        });
        if (Global.user!.userType == 'COMPANY') {
          selectedBranch = branches!
              .where((element) => element.id == Global.user!.branchId)
              .first;
          branchCtrl.text = selectedBranch!.name;
        }
      } else {
        branches = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
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
        title: const Text("Set POS ID"),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: loading
              ? const LoadingProgress()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 7 / 10,
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
                              if (Global.user!.userRole == 'Administrator')
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 80,
                                          child: MiraiDropDownMenu<BranchModel>(
                                            key: UniqueKey(),
                                            children: branches ?? [],
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
                                              BranchModel? project, {
                                              bool isItemSelected = false,
                                            }) {
                                              return DropDownItemWidget(
                                                project: project,
                                                isItemSelected: isItemSelected,
                                                firstSpace: 10,
                                                fontSize: size.getWidthPx(10),
                                              );
                                            },
                                            onChanged: (BranchModel value) {
                                              branchCtrl.text = value.name;
                                              selectedBranch = value;
                                              branchNotifier!.value = value;
                                            },
                                            child: DropDownObjectChildWidget(
                                              key: GlobalKey(),
                                              fontSize: size.getWidthPx(10),
                                              projectValueNotifier:
                                                  branchNotifier!,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
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
                                            labelText: 'รหัสเครื่อง',
                                            textColor: Colors.orange,
                                            validator: null,
                                            inputType: TextInputType.text,
                                            enabled: false,
                                            controller: deviceIdCtrl,
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
                              if (Global.user!.userRole != 'Administrator')
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (Global.user!.userType ==
                                              'ADMIN') {}
                                        },
                                        child: buildTextFieldBig(
                                          labelText: 'สาขา'.tr(),
                                          validator: null,
                                          enabled: false,
                                          option: true,
                                          inputType: TextInputType.text,
                                          controller: branchCtrl,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
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
                                            labelText: 'รหัสเครื่อง POS ID',
                                            textColor: Colors.orange,
                                            validator: null,
                                            inputType: TextInputType.text,
                                            controller: posIdCtrl,
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
                                            line: 3,
                                            labelText: 'คำอธิบาย...',
                                            textColor: Colors.orange,
                                            validator: null,
                                            inputType: TextInputType.text,
                                            controller: detailCtrl,
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
                            ],
                          ),
                        ),
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
                if (deviceIdCtrl.text.trim() == "") {
                  Alert.warning(context, 'warning'.tr(), 'กรุณากรอกรหัสเครื่อง',
                      'OK'.tr(),
                      action: () {});
                  return;
                }

                if (posIdCtrl.text.trim() == "") {
                  Alert.warning(context, 'warning'.tr(),
                      'กรุณากรอกรหัสเครื่อง POS', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "posId": posIdCtrl.text,
                  "detail": detailCtrl.text,
                  "deviceId": await getDeviceId(),
                  "branchId": selectedBranch!.id.toString(),
                  "companyId": Global.user!.companyId.toString(),
                });

                Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                    action: () async {
                  final ProgressDialog pr = ProgressDialog(context,
                      type: ProgressDialogType.normal,
                      isDismissible: true,
                      showLogs: true);
                  await pr.show();
                  pr.update(message: 'processing'.tr());
                  try {
                    var result = await ApiServices.post(
                        '/company/configure/pos/id', object);
                    motivePrint(result?.toJson());
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
                        Alert.warning(context, 'Warning'.tr(),
                            result!.message ?? result.data, 'OK'.tr(),
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
