import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/master/setting_value.dart';
import 'package:motivegold/model/pos_id.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:sizer/sizer.dart';

class EditKycSettingScreen extends StatefulWidget {
  final SettingsValueModel setting;
  final int index;

  const EditKycSettingScreen({
    super.key,
    required this.setting,
    required this.index,
    this.posIdModel
  });

  final PosIdModel? posIdModel;

  @override
  State<EditKycSettingScreen> createState() => _EditKycSettingScreenState();
}

class _EditKycSettingScreenState extends State<EditKycSettingScreen> {
  final TextEditingController maxKycValue = TextEditingController();
  final TextEditingController deviceIdCtrl = TextEditingController();
  final TextEditingController branchCtrl = TextEditingController();

  bool loading = false;
  SettingsValueModel? settingsValueModel;

  // Branch dropdown variables
  List<BranchModel>? branches;
  BranchModel? selectedBranch;
  ValueNotifier<dynamic>? branchNotifier;

  // KYC option
  String? kycOption = 'Force';

  @override
  void initState() {
    super.initState();
    branchNotifier = ValueNotifier<BranchModel>(BranchModel(id: 0, name: 'เลือกสถานประกอบการ'));
    loadData();
    _populateFields();
  }

  void _populateFields() {
    // Populate form with existing data
    maxKycValue.text = Global.format(widget.setting.maxKycValue ?? 0);
    kycOption = widget.setting.kycOption ?? 'Force';

    if (widget.setting.branch != null) {
      selectedBranch = widget.setting.branch;
      branchCtrl.text = widget.setting.branch!.name;
      branchNotifier!.value = widget.setting.branch;
    }
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      // deviceIdCtrl.text = (await getDeviceId())!;

      // Load branches
      await loadBranches();

      var result = await ApiServices.post('/settings/kyc-by-company', Global.requestObj(null));
      if (result?.status == "success") {
        setState(() {});
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

  Future<void> loadBranches() async {
    try {
      var result = Global.user!.userType == 'ADMIN'
          ? await ApiServices.post('/branch/all', Global.requestObj(null))
          : await ApiServices.get('/branch/by-company/${Global.user!.companyId}');

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
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      setState(() {
        branches = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("แก้ไขการตั้งค่า KYC",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: loading
              ? const LoadingProgress()
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch Selection Card (Read-only display)
                  _buildInfoCard(
                    title: 'สถานประกอบการ',
                    icon: Icons.store_outlined,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.setting.branch?.name ?? 'ไม่ระบุสาขา',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ไม่สามารถเปลี่ยนสาขาได้หลังจากบันทึกแล้ว',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // KYC Option Card
                  _buildInfoCard(
                    title: 'การแสดงตนเมื่อรับซื้อทองเก่า',
                    icon: Icons.calculate_outlined,
                    children: [
                      _buildKycOptionToggle(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // KYC Settings Card
                  _buildInfoCard(
                    title: 'การตั้งค่า KYC',
                    icon: Icons.settings_outlined,
                    children: [
                      _buildTextField(
                        controller: maxKycValue,
                        labelText: 'มูลค่าสูงสุดของ KYC',
                        icon: Icons.account_balance_wallet,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        helperText: 'กรอกจำนวนเงินในหน่วยบาท',
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
          onPressed: _updateKycSetting,
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
                "อัพเดต".tr(),
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
            keyboardType: keyboardType,
            inputFormatters: keyboardType == TextInputType.number
                ? [ThousandsFormatter(allowFraction: true)]
                : null,
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

  Widget _buildKycOptionToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    kycOption = 'Force';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: kycOption == 'Force'
                        ? Colors.teal
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kycOption == 'Force'
                              ? Colors.white
                              : Colors.transparent,
                          border: Border.all(
                            color: kycOption == 'Force'
                                ? Colors.white
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: kycOption == 'Force'
                            ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.teal,
                        )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'บังคับ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kycOption == 'Force'
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 56,
              color: Colors.grey[200],
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    kycOption = 'Optional';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: kycOption == 'Optional'
                        ? Colors.teal
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kycOption == 'Optional'
                              ? Colors.white
                              : Colors.transparent,
                          border: Border.all(
                            color: kycOption == 'Optional'
                                ? Colors.white
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: kycOption == 'Optional'
                            ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.teal,
                        )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ไม่บังคับ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kycOption == 'Optional'
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateKycSetting() async {
    if (maxKycValue.text.trim() == "") {
      Alert.warning(context, 'warning'.tr(),
          'กรุณากรอกมูลค่าสูงสุดของ KYC', 'OK'.tr(),
          action: () {});
      return;
    }

    if (kycOption == null || kycOption == "") {
      Alert.warning(context, 'warning'.tr(),
          'กรุณาเลือกตัวเลือกการแสดงตนเมื่อรับซื้อทองเก่า', 'OK'.tr(),
          action: () {});
      return;
    }

    var object = Global.requestObj({
      "id": widget.setting.id,
      "branchId": widget.setting.branchId,
      "maxKycValue": Global.toNumber(maxKycValue.text),
      "kycOption": kycOption,
    });

    Alert.info(context, 'ต้องการอัพเดตข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal,
              isDismissible: true,
              showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());
          try {
            var result = await ApiServices.post('/settings/update-kyc', object);
            if (result != null) {
              motivePrint(result.toJson());
            }
            await pr.hide();
            if (result?.status == "success") {
              if (mounted) {
                Alert.success(context, 'Success'.tr(),
                    'อัพเดตการตั้งค่า KYC เรียบร้อยแล้ว\nกรุณาเข้าสู่ระบบใหม่อีกครั้งเพื่อใช้งาน', 'OK'.tr(),
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
  }
}