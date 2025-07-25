import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/pos_id.dart';
import 'package:motivegold/screen/settings/pos-id/configure_pos_id_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';

class PosIdScreen extends StatefulWidget {
  const PosIdScreen({super.key});

  @override
  State<PosIdScreen> createState() => _PosIdScreenState();
}

class _PosIdScreenState extends State<PosIdScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  PosIdModel? posIdModel;
  Screen? size;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    loadData();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get(
          '/company/configure/pos/id/get/${await getDeviceId()}');
      if (result?.status == "success") {
        var data = PosIdModel.fromJson(result?.data);
        setState(() {
          posIdModel = data;
          Global.posIdModel = data;
        });
        _animationController?.forward();
      } else {
        posIdModel = null;
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
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("ตั้งค่า POS ID",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: LoadingProgress())
            : posIdModel == null
                ? _buildEmptyState()
                : _fadeAnimation != null
                    ? FadeTransition(
                        opacity: _fadeAnimation!,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPosInfoCard(),
                                const SizedBox(height: 20),
                                _buildDeviceInfoCard(),
                                if (Global.user!.userRole ==
                                    'Administrator') ...[
                                  const SizedBox(height: 20),
                                  _buildActionCard(),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPosInfoCard(),
                              const SizedBox(height: 20),
                              _buildDeviceInfoCard(),
                              if (Global.user!.userRole == 'Administrator') ...[
                                const SizedBox(height: 20),
                                _buildActionCard(),
                              ],
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.point_of_sale_outlined,
                size: 60,
                color: Colors.teal[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ยังไม่มี POS ID',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กรุณาตั้งค่า POS ID เพื่อใช้งานระบบ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfigurePosIDScreen(
                        posIdModel: posIdModel,
                      ),
                      fullscreenDialog: true,
                    ),
                  ).whenComplete(() {
                    loadData();
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'ตั้งค่า POS ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosInfoCard() {
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.point_of_sale,
                  color: Colors.teal[600],
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POS ID ของคุณ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      posIdModel?.posId ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ใช้งานได้',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
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
              Icon(Icons.devices, color: Colors.teal[600], size: 24),
              const SizedBox(width: 12),
              const Text(
                'ข้อมูลอุปกรณ์',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.smartphone_outlined,
            label: 'Device ID',
            value: posIdModel?.deviceId ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'วันที่ลงทะเบียน',
            value: posIdModel?.createdDate != null
                ? DateFormat('dd/MM/yyyy HH:mm')
                    .format(posIdModel!.createdDate!)
                : 'N/A',
          ),
          if (posIdModel?.updatedDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.update_outlined,
              label: 'วันที่อัปเดตล่าสุด',
              value: DateFormat('dd/MM/yyyy HH:mm')
                  .format(posIdModel!.updatedDate!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
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
              Icon(Icons.settings, color: Colors.teal[600], size: 24),
              const SizedBox(width: 12),
              const Text(
                'การจัดการ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfigurePosIDScreen(
                          posIdModel: posIdModel,
                        ),
                        fullscreenDialog: true,
                      ),
                    ).whenComplete(() {
                      loadData();
                    });
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  label: const Text(
                    'แก้ไข',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
                        action: () async {
                      removeProduct();
                    });
                  },
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 20),
                  label: const Text(
                    'ลบ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'หมายเหตุ: การลบ POS ID จะไม่สามารถใช้งานระบบได้จนกว่าจะตั้งค่าใหม่',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void removeProduct() async {
    final ProgressDialog pr = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: true,
      showLogs: true,
    );
    await pr.show();
    pr.update(message: 'processing'.tr());

    try {
      var result = await ApiServices.post(
          '/company/configure/pos/id/delete/${posIdModel?.id}',
          Global.requestObj(null));
      motivePrint(result?.toJson());
      await pr.hide();

      if (result?.status == "success") {
        if (mounted) {
          // Simply navigate back - the empty state will show success
          // Navigator.of(context).pop();
          // Show success message on the previous screen
          Alert.success(
              context, 'Success', 'ลบ POS ID เรียบร้อยแล้ว', 'OK'.tr(),
              action: () {});
          loadData();
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
  }
}
