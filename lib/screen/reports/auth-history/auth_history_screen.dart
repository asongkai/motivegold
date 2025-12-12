import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/auth_log.dart';
import 'package:motivegold/screen/reports/auth-history/preview.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/filter/compact_report_filter.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/text/expend_text.dart';
import 'package:sizer/sizer.dart';

class AuthHistoryScreen extends StatefulWidget {
  const AuthHistoryScreen({super.key});

  @override
  State<AuthHistoryScreen> createState() => _AuthHistoryScreenState();
}

class _AuthHistoryScreenState extends State<AuthHistoryScreen> {
  bool loading = false;
  List<AuthLogModel>? authLogList = [];
  List<AuthLogModel>? filteredAuthLogList = [];
  Screen? size;

  // Filter variables
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  String? selectedType;

  final List<String> authTypes = [
    'ทั้งหมด',
    'Login',
    'Logout',
    'Open',
    'Active',
    'Close',
  ];

  @override
  void initState() {
    super.initState();
    // Set default date range: 1st of current month to today
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(now);
    loadAuthLogs();
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
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
                const Expanded(
                  flex: 4,
                  child: Text("ประวัติการเข้าใช้ระบบ",
                      style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildPrintButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CompactReportFilter(
              fromDateController: fromDateCtrl,
              toDateController: toDateCtrl,
              onSearch: applyFilters,
              onReset: () {
                setState(() {
                  final now = DateTime.now();
                  final firstDayOfMonth = DateTime(now.year, now.month, 1);
                  fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
                  toDateCtrl.text = DateFormat('yyyy-MM-dd').format(now);
                  selectedType = null;
                });
                loadAuthLogs();
              },
              filterSummary: _buildFilterSummary(),
              initiallyExpanded: false,
              autoCollapseOnSearch: true,
              additionalFilters: [
                _buildAuthTypeDropdown(),
              ],
            ),
            Expanded(
              child: loading
                  ? const LoadingProgress()
                  : filteredAuthLogList!.isEmpty
                      ? const NoDataFoundWidget()
                      : Container(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.separated(
                            itemCount: filteredAuthLogList!.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              return modernAuthCard(
                                  filteredAuthLogList, index);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: () {
        loadAuthLogs();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.refresh,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'รีเฟรช',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintButton() {
    return GestureDetector(
      onTap: () {
        if (filteredAuthLogList == null || filteredAuthLogList!.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูลให้พิมพ์', 'OK',
              action: () {});
          return;
        }

        String dateRange = '';
        if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
          dateRange =
              'ระหว่างวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}';
        }

        String typeFilter = selectedType != null && selectedType != 'ทั้งหมด'
            ? 'ประเภท: $selectedType'
            : '';

        String filterInfo = [dateRange, typeFilter]
            .where((s) => s.isNotEmpty)
            .join(' | ');

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewAuthHistoryPage(
              invoice: filteredAuthLogList!,
              filterInfo: filterInfo,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.print,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'พิมพ์',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Row(
            children: [
              Icon(Icons.category, size: 13, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(
                'ประเภทการเข้าใช้',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.login, size: 16),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              hintText: 'เลือกประเภท',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.indigo[600]!, width: 1.5),
              ),
            ),
            items: authTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type == 'ทั้งหมด' ? null : type,
                child: Text(type, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedType = value;
              });
            },
          ),
        ),
      ],
    );
  }

  String _buildFilterSummary() {
    List<String> filters = [];
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      filters.add(
          'วันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    if (selectedType != null) {
      filters.add('ประเภท: $selectedType');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }

  void applyFilters() {
    loadAuthLogs();
  }

  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              const Icon(Icons.filter_list, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'ตัวกรองข้อมูล',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('รีเซ็ต', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'จากวันที่',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: fromDateCtrl,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today, size: 18),
                          suffixIcon: fromDateCtrl.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      fromDateCtrl.clear();
                                    });
                                    loadAuthLogs();
                                  },
                                  child: const Icon(Icons.clear, size: 18))
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12.0),
                          hintText: 'เลือกวันที่เริ่มต้น',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.indigo[600]!),
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (_) => SfDatePickerDialog(
                              initialDate: DateTime.now(),
                              onDateSelected: (date) {
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(date);
                                setState(() {
                                  fromDateCtrl.text = formattedDate;
                                });
                                loadAuthLogs();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ถึงวันที่',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: toDateCtrl,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today, size: 18),
                          suffixIcon: toDateCtrl.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      toDateCtrl.clear();
                                    });
                                    loadAuthLogs();
                                  },
                                  child: const Icon(Icons.clear, size: 18))
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12.0),
                          hintText: 'เลือกวันที่สิ้นสุด',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.indigo[600]!),
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (_) => SfDatePickerDialog(
                              initialDate: DateTime.now(),
                              onDateSelected: (date) {
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(date);
                                setState(() {
                                  toDateCtrl.text = formattedDate;
                                });
                                loadAuthLogs();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ประเภท',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A5568),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    hint: const Text('เลือกประเภท'),
                    isExpanded: true,
                    items: authTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue;
                      });
                      loadAuthLogs();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: loadAuthLogs,
                    icon: const Icon(Icons.search_rounded, size: 20),
                    label: const Text('ค้นหา', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    label: const Text('Reset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      // Reset to today's date instead of clearing
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      fromDateCtrl.text = today;
      toDateCtrl.text = today;
      selectedType = null;
    });
    loadAuthLogs();
  }

  Widget modernAuthCard(List<AuthLogModel>? authList, int index) {
    final authLog = authList![index];
    final isSuccessfulAuth = authLog.type!.toUpperCase() == 'LOGIN' ||
        authLog.type!.toUpperCase() == "ACTIVE" ||
        authLog.type!.toUpperCase() == "OPEN";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Status Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSuccessfulAuth
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSuccessfulAuth
                        ? Icons.login_rounded
                        : Icons.logout_rounded,
                    color: isSuccessfulAuth ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Action Type & Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSuccessfulAuth
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              authLog.type!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSuccessfulAuth ? Colors.green[700] : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Global.formatDate(authLog.date.toString()),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User Information Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Header
                  Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ข้อมูลผู้ใช้',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // User Details
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWideScreen = constraints.maxWidth > 300;

                      if (isWideScreen) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildUserInfoItem(
                                'User ID',
                                '${authLog.user!.id}',
                                Icons.tag_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildUserInfoItem(
                                'Username',
                                authLog.user!.username!,
                                Icons.account_circle_rounded,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildUserInfoItem(
                              'User ID',
                              '${authLog.user!.id}',
                              Icons.tag_rounded,
                            ),
                            const SizedBox(height: 8),
                            _buildUserInfoItem(
                              'Username',
                              authLog.user!.username!,
                              Icons.account_circle_rounded,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Device Details Section
            if (authLog.deviceDetail != null && authLog.deviceDetail!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.devices_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'รายละเอียดอุปกรณ์',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ExpandableText(
                text: authLog.deviceDetail!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void loadAuthLogs() async {
    setState(() {
      loading = true;
    });
    try {
      // Use search endpoint with date filtering
      var searchData = {
        'startDate': fromDateCtrl.text.isNotEmpty
            ? DateTime.parse(fromDateCtrl.text).toIso8601String()
            : null,
        'endDate': toDateCtrl.text.isNotEmpty
            ? DateTime.parse(toDateCtrl.text).toIso8601String()
            : null,
        'type': selectedType != null && selectedType != 'ทั้งหมด' ? selectedType : null,
      };

      var request = jsonEncode({
        'companyId': Global.company?.id ?? Global.user?.companyId,
        'branchId': Global.branch?.id ?? Global.user?.branchId,
        'userId': Global.user?.id,
        'data': searchData,
      });

      var result = await ApiServices.post('/authlog/search', request);
      motivePrint(result?.toJson());

      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<AuthLogModel> logs = authLogListModelFromJson(data);
        setState(() {
          authLogList = logs;
          filteredAuthLogList = logs;
        });
      } else {
        authLogList = [];
        filteredAuthLogList = [];
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

  void removeProduct(int id, int i) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result = await ApiServices.delete('/product', id, queryParams: {
        'userId': Global.user?.id,
        'companyId': Global.company?.id ?? Global.user?.companyId,
        'branchId': Global.branch?.id ?? Global.user?.branchId,
      });
      await pr.hide();
      if (result?.status == "success") {
        authLogList!.removeAt(i);
        setState(() {});
      } else {
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
              action: () {});
        }
      }
    } catch (e) {
      await pr.hide();
      if (mounted) {
        Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
            action: () {});
      }
    }
  }
}
