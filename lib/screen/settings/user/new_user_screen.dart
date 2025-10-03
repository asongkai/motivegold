import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

class NewUserScreen extends StatefulWidget {
  final bool showBackButton;

  const NewUserScreen({super.key, required this.showBackButton});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
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
  Screen? size;

  ProductTypeModel? selectedUserRole;

  ValueNotifier<ProductTypeModel>? userRoleNotifier;
  ValueNotifier<dynamic>? companyNotifier;
  ValueNotifier<dynamic>? branchNotifier;

  @override
  void initState() {
    super.initState();
    branchNotifier =
        ValueNotifier<BranchModel>(BranchModel(id: 0, name: 'เลือกสาขา'));
    companyNotifier =
        ValueNotifier<CompanyModel>(CompanyModel(id: 0, name: 'เลือกบริษัท'));
    userRoleNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกบทบาทของผู้ใช้'));
    loadData();
  }

  // ORIGINAL loadData functionality preserved exactly
  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get('/company');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<CompanyModel> products = companyListModelFromJson(data);
        setState(() {
          companies = products;
        });
        motivePrint(Global.user!.userType);
        if (Global.user!.userType == 'COMPANY') {
          selectedCompany = companies!
              .where((element) => element.id == Global.user!.companyId)
              .first;
          companyCtrl.text = selectedCompany!.name;
          companyNotifier = ValueNotifier<CompanyModel>(
              selectedCompany ?? CompanyModel(id: 0, name: 'เลือกบริษัท'));
          await loadBranches();
        }
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

  // ORIGINAL loadBranches functionality preserved exactly
  Future<void> loadBranches() async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    var result =
    await ApiServices.get('/branch/by-company/${selectedCompany!.id}');
    await pr.hide();
    if (result?.status == "success") {
      var data = jsonEncode(result?.data);
      List<BranchModel> products = branchListModelFromJson(data);
      setState(() {
        branches = products;
      });
    } else {
      setState(() {
        branches = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.showBackButton,
          title: Text("เพิ่มผู้ใช้",
              style: TextStyle(
                  fontSize: 16.sp,
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
              ? const Center(child: LoadingProgress())
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company & Branch Card
                  _buildInfoCard(
                    title: 'ข้อมูลบริษัทและสาขา',
                    icon: Icons.business_outlined,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompanyDropdown(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildBranchDropdown(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Personal Info Card
                  _buildInfoCard(
                    title: 'ข้อมูลส่วนตัว',
                    icon: Icons.person_outline,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: firstNameCtrl,
                              labelText: 'ชื่อจริง',
                              icon: Icons.person,
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: lastNameCtrl,
                              labelText: 'นามสกุล',
                              icon: Icons.person,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: phoneCtrl,
                              labelText: 'โทรศัพท์',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: emailCtrl,
                              labelText: 'อีเมล',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Account Info Card
                  _buildInfoCard(
                    title: 'ข้อมูลบัญชีผู้ใช้',
                    icon: Icons.account_circle_outlined,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildTextField(
                              controller: usernameCtrl,
                              labelText: 'ชื่อผู้ใช้',
                              icon: Icons.account_circle,
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: _buildUserRoleDropdown(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: passwordCtrl,
                              labelText: 'รหัสผ่าน',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: cpasswordCtrl,
                              labelText: 'ยืนยันรหัสผ่าน',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: _saveUser,
          backgroundColor: Colors.teal[700],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                "บันทึก".tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.teal[600], size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRequired)
          RichText(
            text: TextSpan(
              text: labelText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          )
        else
          Text(
            labelText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.grey[500],
                size: 20,
              ),
              hintText: 'กรอก${labelText.toLowerCase()}',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompanyDropdown() {
    bool isAdmin = Global.user!.userType == 'ADMIN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'บริษัท',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Conditional rendering based on user type
        if (isAdmin)
        // Admin sees dropdown
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: MiraiDropDownMenu<CompanyModel>(
              key: UniqueKey(),
              children: companies!,
              space: 4,
              maxHeight: 360,
              showSearchTextField: true,
              enable: true,
              selectedItemBackgroundColor: Colors.transparent,
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
                  fontSize: 16.sp,
                );
              },
              onChanged: (CompanyModel value) async {
                companyCtrl.text = value.name;
                selectedCompany = value;
                companyNotifier!.value = value;
                await loadBranches();
                if (mounted) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {});
                }
              },
              child: DropDownObjectChildWidget(
                key: GlobalKey(),
                fontSize: 16.sp,
                projectValueNotifier: companyNotifier!,
              ),
            ),
          )
        else
        // Non-admin sees text display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCompany?.name ?? 'ไม่มีข้อมูลบริษัท',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: selectedCompany != null ? Colors.black87 : Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.business,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'สาขา',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: MiraiDropDownMenu<BranchModel>(
            key: UniqueKey(),
            children: branches ?? [],
            space: 4,
            maxHeight: 360,
            showSearchTextField: true,
            selectedItemBackgroundColor: Colors.transparent,
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
                fontSize: 16.sp,
              );
            },
            onChanged: (BranchModel value) {
              branchCtrl.text = value.name;
              selectedBranch = value;
              branchNotifier!.value = value;
            },
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 16.sp,
              projectValueNotifier: branchNotifier!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'บทบาทของผู้ใช้',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: MiraiDropDownMenu<ProductTypeModel>(
            key: UniqueKey(),
            children: userRoles(),
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
                fontSize: 16.sp,
              );
            },
            onChanged: (ProductTypeModel project) {
              selectedUserRole = project;
              userRoleNotifier!.value = project;
              setState(() {});
            },
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 16.sp,
              projectValueNotifier: userRoleNotifier!,
            ),
          ),
        ),
      ],
    );
  }

  // ORIGINAL save functionality preserved exactly
  void _saveUser() async {
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

    if (selectedUserRole == null) {
      Alert.warning(
          context, 'warning'.tr(), 'เลือกบทบาทของผู้ใช้', 'OK'.tr(),
          action: () {});
      return;
    }

    if (firstNameCtrl.text.trim() == "" ||
        lastNameCtrl.text == "" ||
        emailCtrl.text == "" ||
        usernameCtrl.text == "" ||
        passwordCtrl.text == "") {
      Alert.warning(
          context, 'warning'.tr(), 'กรุณากรอกข้อมูล', 'OK'.tr(),
          action: () {});
      return;
    }

    if (passwordCtrl.text != cpasswordCtrl.text) {
      Alert.warning(context, 'warning'.tr(), 'รหัสผ่านไม่เหมือนกัน',
          'OK'.tr(),
          action: () {});
      return;
    }

    var object = encoder.convert({
      "firstName": firstNameCtrl.text,
      "email": emailCtrl.text,
      "phoneNumber": phoneCtrl.text,
      "lastName": lastNameCtrl.text,
      "username": usernameCtrl.text,
      "password": passwordCtrl.text,
      "companyId": selectedCompany!.id.toString(),
      "branchId": selectedBranch!.id.toString(),
      "userRole": selectedUserRole!.code,
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
            var result =
            await ApiServices.post('/user/register', object);
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
                Alert.warning(context, result!.status!.toUpperCase(),
                    result.message ?? '', 'OK'.tr(),
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
  }
}