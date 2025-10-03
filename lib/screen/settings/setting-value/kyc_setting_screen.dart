import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/master/setting_value.dart';
import 'package:motivegold/model/pos_id.dart';
import 'package:motivegold/screen/settings/setting-value/form/add_kyc_setting_screen.dart';
import 'package:motivegold/screen/settings/setting-value/form/edit_kyc_setting_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
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

class KycSettingScreen extends StatefulWidget {
  const KycSettingScreen({super.key, this.posIdModel});

  final PosIdModel? posIdModel;

  @override
  State<KycSettingScreen> createState() => _KycSettingScreenState();
}

class _KycSettingScreenState extends State<KycSettingScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  List<SettingsValueModel> settings = [];
  List<SettingsValueModel>? filteredSettings = [];
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    super.dispose();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post('/settings/kyc-by-company', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<SettingsValueModel> products = settingsValueModelFromJson(data);
        setState(() {
          settings = products;
          filteredSettings = products;
        });
        _animationController?.forward();
      } else {
        settings = [];
        filteredSettings = [];
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

  void _filterSettings(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        filteredSettings = settings;
      } else {
        filteredSettings = settings
            .where((setting) =>
        setting.branch?.name.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList();
      }
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
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Text("KYC Settings",
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _navigateToNewKycSetting();
                          },
                          child: Container(
                            color: Colors.teal[900],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'เพิ่มการตั้งค่า',
                                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: LoadingProgress())
            : Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterSettings,
                decoration: InputDecoration(
                  hintText: 'ค้นหาสาขา...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      if (mounted) {
                        _searchController.clear();
                        _filterSettings('');
                      }
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            // Settings Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'พบ ${filteredSettings?.length ?? 0} สาขา',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Settings List
            Expanded(
              child: filteredSettings!.isEmpty
                  ? _buildEmptyState()
                  : _fadeAnimation != null
                  ? FadeTransition(
                opacity: _fadeAnimation!,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredSettings!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildModernSettingCard(
                        filteredSettings![index], index);
                  },
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredSettings!.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildModernSettingCard(
                      filteredSettings![index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบข้อมูลการตั้งค่า KYC',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองค้นหาด้วยคำอื่น',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSettingCard(SettingsValueModel setting, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Add navigation to edit KYC settings if needed
              _showSettingDetails(setting);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Settings Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue[50],
                    ),
                    child: Icon(
                      Icons.settings_applications,
                      color: Colors.blue[600],
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Branch Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          setting.branch?.name ?? 'ไม่ระบุสาขา',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // KYC Info Row
                        Row(
                          children: [
                            // KYC Value
                            if (setting.maxKycValue != null)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        size: 16,
                                        color: Colors.orange[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'KYC: ${setting.maxKycValue!.toStringAsFixed(0)} บาท',
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (setting.maxKycValue != null && setting.kycOption != null)
                              const SizedBox(width: 8),
                            // KYC Option with color coding
                            if (setting.kycOption != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getKycOptionColor(setting.kycOption!)[0],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getKycOptionIcon(setting.kycOption!),
                                      size: 16,
                                      color: _getKycOptionColor(setting.kycOption!)[1],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getKycOptionText(setting.kycOption!),
                                      style: TextStyle(
                                        color: _getKycOptionColor(setting.kycOption!)[1],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        _buildActionButtons(setting, index)
                      ],
                    ),
                  ),
                  // Arrow Icon
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingDetails(SettingsValueModel setting) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.blue[600]),
                  const SizedBox(width: 12),
                  Text(
                    setting.branch?.name ?? 'ไม่ระบุสาขา',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Settings Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildDetailRow('KYC Option', _getKycOptionText(setting.kycOption ?? '')),
                    _buildDetailRow('Max KYC Value', '${Global.format(setting.maxKycValue ?? 0)} บาท'),
                    if (setting.updatedDate != null)
                      _buildDetailRow('Last Updated',
                          DateFormat('dd/MM/yyyy HH:mm').format(setting.updatedDate!)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNewKycSetting() {
    // Navigate to new KYC setting screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddKycSettingScreen(),
      ),
    ).whenComplete(() {
      // Reload data when returning from new setting screen
      loadData();
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions for KYC Option color coding
  List<Color> _getKycOptionColor(String kycOption) {
    switch (kycOption.toLowerCase()) {
      case 'force':
        return [Colors.red[50]!, Colors.red[700]!];
      case 'optional':
        return [Colors.green[50]!, Colors.green[700]!];
      default:
        return [Colors.grey[50]!, Colors.grey[700]!];
    }
  }

  IconData _getKycOptionIcon(String kycOption) {
    switch (kycOption.toLowerCase()) {
      case 'force':
        return Icons.warning;
      case 'optional':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _getKycOptionText(String kycOption) {
    switch (kycOption.toLowerCase()) {
      case 'force':
        return 'บังคับ';
      case 'optional':
        return 'ไม่บังคับ';
      default:
        return kycOption.isNotEmpty ? kycOption : '-';
    }
  }

  Widget _buildActionButtons(SettingsValueModel setting, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (Global.user!.userRole == 'Administrator')
            _buildActionButton(
              icon: Icons.edit_outlined,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditKycSettingScreen(
                      setting: setting,
                      index: index,
                    ),
                    fullscreenDialog: true,
                  ),
                ).whenComplete(() {
                  loadData();
                });
              },
            ),
          if (Global.user!.userRole == 'Administrator') ...[
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.delete_outline,
              color: Colors.red,
              onTap: () {
                _showDeleteConfirmation(setting.id!, index);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int id, int index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          removeKycSetting(id, index);
        });
  }

  void removeKycSetting(int id, int index) async {
    final ProgressDialog pr = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: true,
      showLogs: true,
    );
    await pr.show();
    pr.update(message: 'processing'.tr());

    try {
      var result = await ApiServices.delete('/settings/kyc', id);
      await pr.hide();

      if (result?.status == "success") {
        setState(() {
          settings.removeAt(index);
          filteredSettings = List.from(settings);
        });

        // Show success snackbar
        if (mounted) {
          loadData();
          Alert.success(
              context, 'Success', 'ลบข้อมูลการตั้งค่า KYC เรียบร้อยแล้ว', 'OK'.tr(),
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
  }
}