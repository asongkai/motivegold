import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/bank/bank.dart';
import 'package:motivegold/model/bank/bank_account.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';
class EditBankAccountScreen extends StatefulWidget {
  final BankAccountModel account;
  final int index;

  const EditBankAccountScreen(
      {super.key, required this.account, required this.index});

  @override
  State<EditBankAccountScreen> createState() => _EditBankAccountScreenState();
}

class _EditBankAccountScreenState extends State<EditBankAccountScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController codeCtrl = TextEditingController();

  bool loading = false;

  List<BankModel> bankList = [];

  BankModel? selectedBank;
  ValueNotifier<dynamic>? bankNotifier;

  ProductTypeModel? selectedBankAccountType;
  ValueNotifier<dynamic>? bankAccountTypeNotifier;

  @override
  void initState() {
    // implement initState
    super.initState();
    nameCtrl.text = widget.account.name ?? '';
    codeCtrl.text = widget.account.accountNo ?? '';
    bankNotifier =
        ValueNotifier<BankModel>(BankModel(id: 0, name: 'เลือกธนาคาร'));
    var ls = bankAccountTypes()
        .where((e) => e.code == widget.account.accountType)
        .toList();
    selectedBankAccountType = ls.isNotEmpty ? ls.first : null;
    bankAccountTypeNotifier = ValueNotifier<ProductTypeModel>(
        selectedBankAccountType ??
            ProductTypeModel(id: 0, name: 'เลือกประเภทบัญชีเงินฝาก'));
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post('/bank/all', Global.requestObj(null));
      // print(result!.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);

        List<BankModel> products = bankModelFromJson(data);
        setState(() {
          bankList = products;
          selectedBank =
              bankList.where((e) => e.id == widget.account.bankId).first;
          bankNotifier = ValueNotifier<BankModel>(
              selectedBank ?? BankModel(id: 0, name: 'เลือกธนาคาร'));
        });
      } else {
        bankList = [];
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
          title: Text("แก้ไขบัญชีธนาคาร",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: loading
          ? const Center(child: LoadingProgress())
          : SafeArea(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 70,
                                    child: MiraiDropDownMenu<BankModel>(
                                      key: UniqueKey(),
                                      children: bankList,
                                      space: 4,
                                      maxHeight: 360,
                                      showSearchTextField: true,
                                      selectedItemBackgroundColor:
                                          Colors.transparent,
                                      emptyListMessage: 'ไม่มีข้อมูล',
                                      showSelectedItemBackgroundColor: true,
                                      itemWidgetBuilder: (
                                        int index,
                                        BankModel? project, {
                                        bool isItemSelected = false,
                                      }) {
                                        return DropDownItemWidget(
                                          project: project,
                                          isItemSelected: isItemSelected,
                                          firstSpace: 10,
                                          fontSize: 16.sp,
                                        );
                                      },
                                      onChanged: (BankModel value) {
                                        selectedBank = value;
                                        bankNotifier!.value = value;
                                      },
                                      child: DropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: 16.sp,
                                        projectValueNotifier: bankNotifier!,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 70,
                                    child: MiraiDropDownMenu<ProductTypeModel>(
                                      key: UniqueKey(),
                                      children: bankAccountTypes(),
                                      space: 4,
                                      maxHeight: 360,
                                      showSearchTextField: true,
                                      selectedItemBackgroundColor:
                                          Colors.transparent,
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
                                          fontSize: 16.sp,
                                        );
                                      },
                                      onChanged: (ProductTypeModel value) {
                                        selectedBankAccountType = value;
                                        bankAccountTypeNotifier!.value = value;
                                      },
                                      child: DropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: 16.sp,
                                        projectValueNotifier:
                                            bankAccountTypeNotifier!,
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
                                        labelText: 'ชื่อบัญชีธนาคาร'.tr(),
                                        labelColor: Colors.orange,
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: nameCtrl,
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
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'หมายเลขบัญชีธนาคาร'.tr(),
                                        labelColor: Colors.orange,
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: codeCtrl,
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
                if (selectedBank == null) {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณาเลือกธนาคาร', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (nameCtrl.text.trim() == "") {
                  Alert.warning(context, 'warning'.tr(),
                      'กรุณากรอกชื่อบัญชีธนาคาร', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (codeCtrl.text.trim() == "") {
                  Alert.warning(context, 'warning'.tr(),
                      'กรุณากรอกหมายเลขบัญชีธนาคาร', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "id": widget.account.id,
                  "name": nameCtrl.text,
                  "accountNo": codeCtrl.text,
                  "bankId": selectedBank?.id,
                  "bankCode": selectedBank?.code,
                  "branchId": Global.branch?.id,
                  "accountType": selectedBankAccountType?.code,
                  "companyId": Global.company?.id
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
                        '/bankaccount', widget.account.id, object);
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
