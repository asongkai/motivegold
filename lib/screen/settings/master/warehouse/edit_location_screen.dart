import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

class EditLocationScreen extends StatefulWidget {
  final WarehouseModel location;
  final int index;

  const EditLocationScreen(
      {super.key, required this.location, required this.index});

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

  bool sell = false;
  bool matching = false;
  bool transit = false;

  @override
  void initState() {
    super.initState();
    motivePrint(Global.user!.userRole);
    // Initialize with existing location data
    nameCtrl.text = widget.location.name;
    addressCtrl.text = widget.location.address!;
    sell = widget.location.sell == 1 ? true : false;
    matching = widget.location.matching == 1 ? true : false;
    transit = widget.location.transit == 1 ? true : false;
    branchNotifier = ValueNotifier<BranchModel>(
        selectedBranch ?? BranchModel(id: 0, name: 'เลือกสาขา'));
    loadData();
  }

  // ORIGINAL loadData functionality preserved exactly
  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
      await ApiServices.get('/branch/by-company/${Global.user!.companyId}');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<BranchModel> products = branchListModelFromJson(data);
        setState(() {
          branches = products;
        });
        selectedBranch = branches
            ?.where((element) => element.id == widget.location.branchId)
            .first;
        branchNotifier = ValueNotifier<BranchModel>(
            selectedBranch ?? BranchModel(id: 0, name: 'เลือกสาขา'));
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("แก้ไขคลังสินค้า",
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
                  // Current Location Info Header
                  _buildCurrentLocationHeader(),

                  const SizedBox(height: 20),

                  // Branch Selection Card
                  _buildInfoCard(
                    title: 'ข้อมูลสาขา',
                    icon: Icons.store_outlined,
                    children: [
                      if (Global.user!.userRole == 'Administrator')
                        _buildDropdownField()
                      else
                        _buildBranchTextField(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Location Info Card
                  _buildInfoCard(
                    title: 'ข้อมูลคลังสินค้า',
                    icon: Icons.warehouse_outlined,
                    children: [
                      _buildTextField(
                        controller: nameCtrl,
                        labelText: 'ชื่อคลังสินค้า',
                        icon: Icons.inventory_2_outlined,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: addressCtrl,
                        labelText: 'ที่อยู่คลังสินค้า',
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Settings Card
                  _buildInfoCard(
                    title: 'การตั้งค่า',
                    icon: Icons.settings_outlined,
                    children: [
                      _buildCheckboxOption(
                        title: 'ขายหน้าร้าน',
                        subtitle: 'เปิดใช้งานการขายหน้าร้าน',
                        value: sell,
                        onChanged: (value) {
                          setState(() {
                            sell = value!;
                          });
                        },
                        icon: Icons.storefront,
                      ),
                      const SizedBox(height: 12),
                      _buildCheckboxOption(
                        title: 'ทองแท่ง (จับคู่)',
                        subtitle: 'เปิดใช้งานการจับคู่ทองแท่ง',
                        value: matching,
                        onChanged: (value) {
                          setState(() {
                            matching = value!;
                          });
                        },
                        icon: Icons.compare_arrows,
                      ),
                      const SizedBox(height: 12),
                      _buildCheckboxOption(
                        title: 'Transit',
                        subtitle: 'เปิดใช้งานคลังขนส่ง',
                        value: transit,
                        onChanged: (value) {
                          setState(() {
                            transit = value!;
                          });
                        },
                        icon: Icons.local_shipping_outlined,
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
          onPressed: _updateLocation,
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

  Widget _buildCurrentLocationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_location_alt,
              color: Colors.blue[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'กำลังแก้ไข',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.location.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildBranchTextField() {
    return _buildTextField(
      controller: branchCtrl,
      labelText: 'สาขา',
      icon: Icons.store,
      enabled: false,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool enabled = true,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRequired ? Colors.orange[300]! : Colors.grey[200]!,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText + (isRequired ? ' *' : ''),
          labelStyle: TextStyle(
            color: isRequired ? Colors.orange[600] : Colors.grey[600],
            fontWeight: isRequired ? FontWeight.w600 : FontWeight.normal,
          ),
          prefixIcon: Icon(
            icon,
            color: isRequired ? Colors.orange[600] : Colors.grey[400],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value ? Colors.teal[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.teal[300]! : Colors.grey[200]!,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: value ? Colors.teal[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: value ? Colors.teal[700] : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: value ? Colors.teal[800] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: value ? Colors.teal[600] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.teal[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ORIGINAL save functionality preserved exactly
  void _updateLocation() async {
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
      "sell": sell ? 1 : 0,
      "matching": matching ? 1 : 0,
      "transit": transit ? 1 : 0
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
            var result = await ApiServices.put(
                '/binlocation', widget.location.id, object);
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
  }

  saveRow() {
    setState(() {});
  }
}