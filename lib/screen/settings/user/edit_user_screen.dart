import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/user.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';

class EditUserScreen extends StatefulWidget {
  final bool showBackButton;
  final UserModel user;
  final int index;

  const EditUserScreen(
      {super.key,
      required this.showBackButton,
      required this.user,
      required this.index});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  String? id;
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController cpasswordCtrl = TextEditingController();

  bool loading = false;
  List<CompanyModel>? companies;
  List<BranchModel>? branches;
  CompanyModel? selectedCompany;
  BranchModel? selectedBranch;

  ProductTypeModel? selectedUserRole;

  ValueNotifier<ProductTypeModel>? userRoleNotifier;
  ValueNotifier<dynamic>? companyNotifier;
  ValueNotifier<dynamic>? branchNotifier;

  @override
  void initState() {
    // implement initState
    super.initState();

    id = widget.user.id;
    firstNameCtrl.text = widget.user.firstName ?? '';
    lastNameCtrl.text = widget.user.lastName ?? '';
    emailCtrl.text = widget.user.email ?? '';
    usernameCtrl.text = widget.user.username ?? '';
    phoneCtrl.text = widget.user.phoneNumber ?? '';
    selectedUserRole = userRoles()
        .where((element) => element.code == widget.user.userRole)
        .first;
    userRoleNotifier = ValueNotifier<ProductTypeModel>(selectedUserRole ??
        ProductTypeModel(id: 0, name: 'เลือกบทบาทของผู้ใช้'));
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get('/company');
      // print(result!.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);

        List<CompanyModel> products = companyListModelFromJson(data);
        setState(() {
          companies = products;
        });

        selectedCompany = companies
            ?.where((element) => element.id == widget.user.companyId)
            .first;
        companyNotifier = ValueNotifier<CompanyModel>(
            selectedCompany ?? CompanyModel(id: 0, name: 'เลือกบริษัท'));
        await loadBranches();
        companyCtrl.text = selectedCompany!.name;
      } else {
        companies = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> loadBranches() async {
    var result =
        await ApiServices.get('/branch/by-company/${selectedCompany!.id}');
    // print(result!.toJson());
    if (result?.status == "success") {
      var data = jsonEncode(result?.data);

      List<BranchModel> products = branchListModelFromJson(data);
      setState(() {
        branches = products;
      });
      selectedBranch = branches
          ?.where((element) => element.id == widget.user.branchId)
          .first;
      branchNotifier = ValueNotifier<BranchModel>(
          selectedBranch ?? BranchModel(id: 0, name: 'เลือกสาขา'));
      branchCtrl.text = selectedBranch!.name;
    } else {
      branches = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Screen size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.showBackButton,
          title: const Text("แก้ไขผู้ใช้",
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 80,
                                    child: MiraiDropDownMenu<CompanyModel>(
                                      key: UniqueKey(),
                                      children: companies!,
                                      space: 4,
                                      maxHeight: 360,
                                      showSearchTextField: true,
                                      selectedItemBackgroundColor:
                                          Colors.transparent,
                                      emptyListMessage: 'ไม่มีข้อมูล',
                                      showSelectedItemBackgroundColor: true,
                                      itemWidgetBuilder: (
                                        int index,
                                        CompanyModel? project, {
                                        bool isItemSelected = false,
                                      }) {
                                        return DropDownItemWidget(
                                          project: project,
                                          isItemSelected: isItemSelected,
                                          firstSpace: 10,
                                          fontSize: size.getWidthPx(6),
                                        );
                                      },
                                      onChanged: (CompanyModel value) {
                                        companyCtrl.text = value.name;
                                        selectedCompany = value;
                                        companyNotifier!.value = value;
                                      },
                                      child: DropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: size.getWidthPx(6),
                                        projectValueNotifier: companyNotifier!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                                      showSelectedItemBackgroundColor: true,
                                      itemWidgetBuilder: (
                                        int index,
                                        BranchModel? project, {
                                        bool isItemSelected = false,
                                      }) {
                                        return DropDownItemWidget(
                                          project: project,
                                          isItemSelected: isItemSelected,
                                          firstSpace: 10,
                                          fontSize: size.getWidthPx(6),
                                        );
                                      },
                                      onChanged: (BranchModel value) {
                                        branchCtrl.text = value.name;
                                        selectedBranch = value;
                                        branchNotifier!.value = value;
                                      },
                                      child: DropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: size.getWidthPx(6),
                                        projectValueNotifier: branchNotifier!,
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
                                        labelText: 'ชื่อจริง'.tr(),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
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
                                        labelText: 'อีเมล'.tr(),
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
                                flex: 5,
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
                                        labelText: 'ชื่อผู้ใช้'.tr(),
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: usernameCtrl,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 80,
                                    child: MiraiDropDownMenu<ProductTypeModel>(
                                      key: UniqueKey(),
                                      children: userRoles(),
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
                                          fontSize: size.getWidthPx(6),
                                        );
                                      },
                                      onChanged: (ProductTypeModel project) {
                                        selectedUserRole = project;
                                        userRoleNotifier!.value = project;
                                        setState(() {});
                                      },
                                      child: DropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: size.getWidthPx(6),
                                        projectValueNotifier: userRoleNotifier!,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                          labelText: 'รหัสผ่าน'.tr(),
                                          validator: null,
                                          inputType: TextInputType.text,
                                          controller: passwordCtrl,
                                          isPassword: true),
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
                                          labelText: 'ยืนยันรหัสผ่าน'.tr(),
                                          validator: null,
                                          inputType: TextInputType.text,
                                          controller: cpasswordCtrl,
                                          isPassword: true),
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
                if (selectedCompany == null) {
                  Alert.warning(
                      context, 'warning'.tr(), 'เลือกบริษัท', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (selectedBranch == null) {
                  Alert.warning(context, 'warning'.tr(), 'เลือกสาขา', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (firstNameCtrl.text.trim() == "" ||
                    lastNameCtrl.text == "" ||
                    emailCtrl.text == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกข้อมูล', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (passwordCtrl.text.trim() != "") {
                  if (passwordCtrl.text != cpasswordCtrl.text) {
                    Alert.warning(context, 'warning'.tr(),
                        'รหัสผ่านไม่เหมือนกัน', 'OK'.tr(),
                        action: () {});
                    return;
                  }
                }

                var object = encoder.convert({
                  "id": id,
                  "firstName": firstNameCtrl.text,
                  "email": emailCtrl.text,
                  "phoneNumber": phoneCtrl.text,
                  "lastName": lastNameCtrl.text,
                  "username": usernameCtrl.text,
                  "password": passwordCtrl.text,
                  "companyId": selectedCompany!.id.toString(),
                  "branchId": selectedBranch!.id.toString()
                });

                // print(object);
                // return;
                Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                    action: () async {
                  final ProgressDialog pr = ProgressDialog(context,
                      type: ProgressDialogType.normal,
                      isDismissible: true,
                      showLogs: true);
                  await pr.show();
                  pr.update(message: 'processing'.tr());
                  try {
                    var result = await ApiServices.put('/user', id, object);
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
}
