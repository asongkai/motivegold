
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../../../api/api_services.dart';
import '../../../../model/branch.dart';
import '../../../../model/warehouseModel.dart';
import '../../../../utils/alert.dart';
import '../../../../utils/global.dart';
import '../../../../utils/responsive_screen.dart';
import '../../../../widget/dropdown/DropDownItemWidget.dart';
import '../../../../widget/dropdown/DropDownObjectChildWidget.dart';


class EditLocationScreen extends StatefulWidget {
  final WarehouseModel location;
  final int index;
  const EditLocationScreen({super.key, required this.location, required this.index});

  @override
  State<EditLocationScreen> createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController branchCtrl = TextEditingController();

  bool loading = false;
  List<BranchModel>? branches;
  BranchModel? selectedBranch;
  ValueNotifier<dynamic>? branchNotifier;

  @override
  void initState() {
    // implement initState
    super.initState();
    motivePrint(Global.user!.userRole);
    nameCtrl.text = widget.location.name;
    addressCtrl.text = widget.location.address!;
    branchNotifier = ValueNotifier<BranchModel>(selectedBranch ?? BranchModel(id: 0, name: 'เลือกสาขา'));
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get('/branch/by-company/${Global.user!.companyId}');
      // print(result!.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);

        List<BranchModel> products = branchListModelFromJson(data);
        setState(() {
          branches = products;
        });
        selectedBranch = branches?.where((element) => element.id == widget.location.branchId).first;
        branchNotifier = ValueNotifier<BranchModel>(selectedBranch ?? BranchModel(id: 0, name: 'เลือกสาขา'));
        branchCtrl.text = selectedBranch!.name;
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
        title: const Text("แก้ไขคลังสินค้า"),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: loading ? const LoadingProgress() : SingleChildScrollView(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Global.user!.userRole == 'Administrator')
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets
                                .all(
                                8.0),
                            child:
                            SizedBox(
                              height: 80,
                              child: MiraiDropDownMenu<
                                  BranchModel>(
                                key:
                                UniqueKey(),
                                children:
                                branches ?? [],
                                space: 4,
                                maxHeight:
                                360,
                                showSearchTextField:
                                true,
                                selectedItemBackgroundColor:
                                Colors
                                    .transparent,
                                emptyListMessage: 'ไม่มีข้อมูล',
                                showSelectedItemBackgroundColor:
                                true,
                                itemWidgetBuilder:
                                    (
                                    int index,
                                    BranchModel?
                                    project, {
                                  bool isItemSelected =
                                  false,
                                }) {
                                  return DropDownItemWidget(
                                    project:
                                    project,
                                    isItemSelected:
                                    isItemSelected,
                                    firstSpace:
                                    10,
                                    fontSize:
                                    size.getWidthPx(6),
                                  );
                                },
                                onChanged:
                                    (BranchModel
                                value) {
                                  branchCtrl.text = value.name;
                                  selectedBranch = value;
                                  branchNotifier!.value =
                                      value;
                                },
                                child:
                                DropDownObjectChildWidget(
                                  key:
                                  GlobalKey(),
                                  fontSize:
                                  size.getWidthPx(6),
                                  projectValueNotifier:
                                  branchNotifier!,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                                if (Global.user!.userType == 'ADMIN') {

                                }
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
                                  labelText: 'ชื่อคลังสินค้า'.tr(),
                                  textColor: Colors
                                      .orange,
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
                                  line: 3,
                                  labelText: 'ที่อยู่คลังสินค้า'.tr(),
                                  textColor: Colors
                                      .orange,
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
                if (nameCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกข้อมูล', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "id": widget.location.id,
                  "companyId": Global.user!.companyId,
                  "branchId": selectedBranch!.id.toString(),
                  "name": nameCtrl.text,
                  "address": addressCtrl.text,
                });

                // return;
                final ProgressDialog pr = ProgressDialog(context,
                    type: ProgressDialogType.normal,
                    isDismissible: true,
                    showLogs: true);
                await pr.show();
                pr.update(message: 'processing'.tr());
                try {
                  var result = await ApiServices.put('/binlocation', widget.location.id, object);
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
    setState(() {});
  }
}
