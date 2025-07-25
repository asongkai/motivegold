import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/prefix.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:sizer/sizer.dart';

List<String> prefixFormat = [
  "{BRANCH CODE}-{DOC TYPE}{YY}{MM}-{RUNNING NUMBER (4 DIGITS)}",
  "{BRANCH CODE}-{DOC TYPE}{YY}{MM}-{RUNNING NUMBER (6 DIGITS)}",
];

class OrderIdPrefixScreen extends StatefulWidget {
  const OrderIdPrefixScreen({super.key});

  @override
  State<OrderIdPrefixScreen> createState() => _OrderIdPrefixScreenState();
}

class _OrderIdPrefixScreenState extends State<OrderIdPrefixScreen> {
  final TextEditingController nameCtrl = TextEditingController();

  bool loading = false;
  PrefixModel? prefixModel;
  int selectedOption = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get(
          '/company/configure/prefix/get/${Global.user!.companyId}');
      if (result?.status == "success") {
        PrefixModel model = PrefixModel.fromJson(result?.data);
        setState(() {
          prefixModel = model;
          selectedOption = Global.prefixIndex(model.settingMode!);
          if (selectedOption == 1) {
            nameCtrl.text = prefixFormat[0];
          } else if (selectedOption == 2) {
            nameCtrl.text = prefixFormat[1];
          }
        });
      } else {
        prefixModel = null;
        selectedOption = 0;
        nameCtrl.text = "";
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
          title: Text("ตั้งค่า ID การทำธุรกรรม",
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
                        // Settings Card
                        _buildInfoCard(
                          title: 'ตัวเลือกการรีเซ็ต ID',
                          icon: Icons.settings_outlined,
                          children: [
                            _buildRadioOption(
                              title: 'รีเซ็ต ID ทุกเดือน',
                              subtitle:
                                  'รหัสธุรกรรมจะรีเซ็ตเป็น 0001 ทุกต้นเดือน',
                              value: 1,
                              icon: Icons.calendar_month_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildRadioOption(
                              title: 'รีเซ็ต ID ทุกปี',
                              subtitle:
                                  'รหัสธุรกรรมจะรีเซ็ตเป็น 000001 ทุกต้นปี',
                              value: 2,
                              icon: Icons.calendar_today_outlined,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Preview Card
                        _buildInfoCard(
                          title: 'ตัวอย่างรูปแบบรหัสธุรกรรม',
                          icon: Icons.preview_outlined,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'รูปแบบ ID ที่จะใช้งาน',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.orange[300]!),
                                    ),
                                    child: Text(
                                      nameCtrl.text.isEmpty
                                          ? 'กรุณาเลือกตัวเลือกด้านบน'
                                          : nameCtrl.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'monospace',
                                        color: nameCtrl.text.isEmpty
                                            ? Colors.grey[500]
                                            : Colors.orange[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (nameCtrl.text.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _buildFormatExplanation(),
                                  ],
                                ],
                              ),
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
          onPressed: _savePrefixSettings,
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

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required int value,
    required IconData icon,
  }) {
    bool isSelected = selectedOption == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = value;
          if (selectedOption == 1) {
            nameCtrl.text = prefixFormat[0];
          } else if (selectedOption == 2) {
            nameCtrl.text = prefixFormat[1];
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.teal[300]! : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.teal[700] : Colors.grey[600],
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
                      color: isSelected ? Colors.teal[800] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.teal[600] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<int>(
              value: value,
              groupValue: selectedOption,
              onChanged: (int? newValue) {
                setState(() {
                  selectedOption = newValue!;
                  if (selectedOption == 1) {
                    nameCtrl.text = prefixFormat[0];
                  } else if (selectedOption == 2) {
                    nameCtrl.text = prefixFormat[1];
                  }
                });
              },
              activeColor: Colors.teal[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'คำอธิบายรูปแบบ:',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.orange[700],
          ),
        ),
        const SizedBox(height: 8),
        _buildFormatItem('BRANCH CODE', 'รหัสสาขา (เช่น DM, RS, TN)'),
        _buildFormatItem('DOC TYPE', 'ประเภทเอกสาร (เช่น SN, BU)'),
        _buildFormatItem('YY', 'ปี (2 หลัก)'),
        _buildFormatItem('MM', 'เดือน (2 หลัก)'),
        _buildFormatItem(
            'RUNNING NUMBER',
            selectedOption == 1
                ? 'เลขลำดับ 4 หลัก (0001-9999)'
                : 'เลขลำดับ 6 หลัก (000001-999999)'),
      ],
    );
  }

  Widget _buildFormatItem(String code, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _savePrefixSettings() async {
    if (selectedOption == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('โปรดเลือกตัวเลือกการรีเซ็ต ID'),
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
      "companyId": Global.user!.companyId.toString(),
      "settingMode": Global.prefixName(selectedOption),
      "prefix": ""
    });

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result =
            await ApiServices.post('/company/configure/prefix/set', object);
        await pr.hide();
        if (result?.status == "success") {
          if (mounted) {
            loadData();
            Alert.success(
                context, 'Success', 'บันทึกการตั้งค่าเรียบร้อยแล้ว', 'OK'.tr(),
                action: () {});
            setState(() {});
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
