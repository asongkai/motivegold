import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/pos_id.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

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
    super.initState();

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text(
            widget.posIdModel == null ? "ตั้งค่า POS ID" : "แก้ไข POS ID",
            style: TextStyle(
                fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w900),
          ),
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
                        // Branch Selection Card (Admin only)
                        if (Global.user!.userRole == 'Administrator')
                          _buildInfoCard(
                            title: 'เลือกสาขา',
                            icon: Icons.store,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
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
                          ),

                        // Branch Display (Non-Admin)
                        if (Global.user!.userRole != 'Administrator')
                          _buildInfoCard(
                            title: 'สาขา',
                            icon: Icons.store,
                            children: [
                              _buildModernTextField(
                                controller: branchCtrl,
                                label: 'สาขา',
                                icon: Icons.store_outlined,
                                enabled: false,
                              ),
                            ],
                          ),

                        const SizedBox(height: 20),

                        // Device Information Card
                        _buildInfoCard(
                          title: 'ข้อมูลอุปกรณ์',
                          icon: Icons.devices,
                          children: [
                            _buildModernTextField(
                              controller: deviceIdCtrl,
                              label: 'รหัสเครื่อง',
                              icon: Icons.smartphone_outlined,
                              enabled: false,
                              helperText: 'รหัสอุปกรณ์ที่ระบบสร้างให้อัตโนมัติ',
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // POS Configuration Card
                        _buildInfoCard(
                          title: 'การตั้งค่า POS',
                          icon: Icons.point_of_sale,
                          children: [
                            _buildModernTextField(
                              controller: posIdCtrl,
                              label: 'รหัสเครื่อง POS ID',
                              icon: Icons.point_of_sale_outlined,
                              required: true,
                              helperText: 'รหัสเฉพาะสำหรับระบุเครื่อง POS นี้',
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: detailCtrl,
                              label: 'คำอธิบาย',
                              icon: Icons.description_outlined,
                              maxLines: 3,
                              helperText:
                                  'รายละเอียดเพิ่มเติมเกี่ยวกับเครื่อง POS นี้',
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
          onPressed: _savePosConfiguration,
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
                "บันทึกการตั้งค่า".tr(),
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    bool enabled = true,
    String? helperText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (required)
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 14.sp,
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
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: enabled ? Colors.grey[50] : Colors.grey[100],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: enabled ? Colors.grey[500] : Colors.grey[400],
                size: 20,
              ),
              hintText: 'กรอก$label',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: enabled ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  void _savePosConfiguration() async {
    if (deviceIdCtrl.text.trim() == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณากรอกรหัสเครื่อง'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (posIdCtrl.text.trim() == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณากรอกรหัสเครื่อง POS'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณาเลือกสาขา'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result =
            await ApiServices.post('/company/configure/pos/id', object);
        motivePrint(result?.toJson());
        await pr.hide();
        if (result?.status == "success") {
          if (mounted) {
            Alert.success(
                context,
                'Success',
                widget.posIdModel == null
                    ? 'ตั้งค่า POS ID เรียบร้อยแล้ว'
                    : 'อัปเดต POS ID เรียบร้อยแล้ว',
                'OK'.tr(), action: () {
              Navigator.of(context).pop();
            });
          }
        } else {
          if (mounted) {
            Alert.error(context, 'Error',
                result?.message ?? result?.data ?? 'เกิดข้อผิดพลาด', 'OK'.tr(),
                action: () {});
          }
        }
      } catch (e) {
        await pr.hide();
        if (mounted) {
          Alert.error(
              context, 'Error', 'เกิดข้อผิดพลาด: ${e.toString()}', 'OK'.tr(),
              action: () {});
        }
      }
    });
  }

  saveRow() {
    setState(() {});
  }
}
