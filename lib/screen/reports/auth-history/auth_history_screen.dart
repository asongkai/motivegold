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
  bool showFilters = false;

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
                      _buildFilterButton(),
                      const SizedBox(width: 8),
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
            if (showFilters) _buildFilterPanel(),
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

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showFilters = !showFilters;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: showFilters
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'กรอง',
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
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('รีเซ็ต'),
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
                                      _applyFilters();
                                    });
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
                                _applyFilters();
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
                                      _applyFilters();
                                    });
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
                                _applyFilters();
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
                      _applyFilters();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'แสดง ${filteredAuthLogList?.length ?? 0} รายการ',
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
    );
  }

  void _resetFilters() {
    setState(() {
      fromDateCtrl.clear();
      toDateCtrl.clear();
      selectedType = null;
      filteredAuthLogList = List.from(authLogList ?? []);
    });
  }

  void _applyFilters() {
    setState(() {
      filteredAuthLogList = authLogList?.where((log) {
        // Date filter
        if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
          try {
            DateTime fromDate = DateTime.parse(fromDateCtrl.text);
            DateTime toDate = DateTime.parse(toDateCtrl.text);
            DateTime logDate = log.date!;

            if (logDate.isBefore(fromDate) ||
                logDate.isAfter(toDate.add(const Duration(days: 1)))) {
              return false;
            }
          } catch (e) {
            if (kDebugMode) {
              print('Date filter error: $e');
            }
          }
        }

        // Type filter
        if (selectedType != null && selectedType != 'ทั้งหมด') {
          if (log.type?.toLowerCase() != selectedType?.toLowerCase()) {
            return false;
          }
        }

        return true;
      }).toList();
    });
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
      var result = await ApiServices.post('/authlog', Global.requestObj(null));
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
