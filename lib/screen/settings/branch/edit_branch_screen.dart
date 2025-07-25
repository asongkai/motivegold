import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/util.dart';
import 'package:sizer/sizer.dart';

class EditBranchScreen extends StatefulWidget {
  final bool showBackButton;
  final BranchModel branch;
  final int index;

  const EditBranchScreen({
    super.key,
    required this.showBackButton,
    required this.branch,
    required this.index,
  });

  @override
  State<EditBranchScreen> createState() => _EditBranchScreenState();
}

class _EditBranchScreenState extends State<EditBranchScreen> {
  int? id;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController provinceCtrl = TextEditingController();
  final TextEditingController branchCodeCtrl = TextEditingController();
  final TextEditingController branchIdCtrl = TextEditingController();
  final TextEditingController licenseNumberCtrl = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    id = widget.branch.id;
    nameCtrl.text = widget.branch.name;
    emailCtrl.text = widget.branch.email ?? '';
    phoneCtrl.text = widget.branch.phone ?? '';
    addressCtrl.text = widget.branch.address ?? '';
    villageCtrl.text = widget.branch.village ?? '';
    districtCtrl.text = widget.branch.district ?? '';
    provinceCtrl.text = widget.branch.province ?? '';
    branchCodeCtrl.text = widget.branch.branchCode ?? '';
    branchIdCtrl.text = widget.branch.branchId ?? '';
    licenseNumberCtrl.text = widget.branch.oldGoldLicenseNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.showBackButton,
          title: Text("แก้ไขสาขา",
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
                        // Branch Information Card
                        _buildInfoCard(
                          title: 'ข้อมูลสาขา',
                          icon: Icons.store,
                          children: [
                            _buildModernTextField(
                              controller: nameCtrl,
                              label: 'ชื่อสาขา',
                              icon: Icons.store_outlined,
                              required: true,
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: licenseNumberCtrl,
                              label: 'เลขที่ใบอนุญาตค้าทองเก่า',
                              icon: Icons.card_membership_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: branchIdCtrl,
                                    label: 'รหัสสาขา',
                                    icon: Icons.numbers_outlined,
                                    keyboardType: TextInputType.phone,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: branchCodeCtrl,
                                    label: 'ชื่อย่อสาขา',
                                    icon: Icons.code_outlined,
                                    required: true,
                                    helperText: 'ภาษาอังกฤษเท่านั้น',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: phoneCtrl,
                                    label: 'โทรศัพท์',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: emailCtrl,
                                    label: 'อีเมล',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Address Information Card
                        _buildInfoCard(
                          title: 'ที่อยู่',
                          icon: Icons.location_on,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: provinceCtrl,
                                    label: 'จังหวัด',
                                    icon: Icons.map_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: districtCtrl,
                                    label: 'เขต',
                                    icon: Icons.location_city_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: villageCtrl,
                                    label: 'บ้าน',
                                    icon: Icons.home_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: addressCtrl,
                                    label: 'ที่อยู่',
                                    icon: Icons.place_outlined,
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
          onPressed: _updateBranch,
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    bool enabled = true,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (required)
          RichText(
            text: TextSpan(
              text: label,
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
            label,
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
            color: enabled ? Colors.grey[50] : Colors.grey[100],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: enabled ? Colors.grey[500] : Colors.grey[400],
                size: 20,
              ),
              hintText: 'กรอก$label',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  void _updateBranch() async {
    if (nameCtrl.text.trim() == "") {
      Alert.warning(context, 'กรุณากรอกชื่อสาขา', '', 'ตกลง');
      return;
    }

    if (branchIdCtrl.text.trim() == "") {
      Alert.warning(context, 'กรุณากรอกรหัสสาขา', '', 'ตกลง');
      return;
    }

    if (branchCodeCtrl.text.trim() == "") {
      Alert.warning(context, 'กรุณากรอกชื่อย่อสาขา', '', 'ตกลง');
      return;
    }

    var object = Global.requestObj({
      "id": id,
      "companyId": widget.branch.companyId,
      "name": nameCtrl.text,
      "email": emailCtrl.text,
      "phone": phoneCtrl.text,
      "address": addressCtrl.text,
      "village": villageCtrl.text,
      "district": districtCtrl.text,
      "province": provinceCtrl.text,
      "branchId": branchIdCtrl.text,
      "branchCode": branchCodeCtrl.text,
      "oldGoldLicenseNumber": licenseNumberCtrl.text
    });

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.put('/branch', id, object);
        await pr.hide();
        if (result?.status == "success") {
          if (mounted) {
            Alert.success(context, 'อัปเดตข้อมูลเรียบร้อยแล้ว', '', 'ตกลง',
                action: () {
              Navigator.of(context).pop();
            });
          }
        } else {
          if (mounted) {
            Alert.warning(
                context, result?.message ?? 'เกิดข้อผิดพลาด', '', 'ตกลง');
          }
        }
      } catch (e) {
        await pr.hide();
        if (mounted) {
          Alert.warning(context, 'เกิดข้อผิดพลาด: ${e.toString()}', '', 'ตกลง');
        }
      }
    });
  }
}
