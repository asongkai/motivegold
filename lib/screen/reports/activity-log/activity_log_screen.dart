import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/activity_log.dart';
import 'package:motivegold/screen/reports/activity-log/preview.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/filter/compact_report_filter.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/text/expend_text.dart';
import 'package:sizer/sizer.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  bool loading = false;
  List<ActivityLogModel>? activityList = [];
  List<ActivityLogModel>? filteredActivityList = [];
  Screen? size;

  // Filter variables
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  String? selectedActionType;
  String? selectedScreenName;

  final List<String> actionTypes = [
    'ทั้งหมด',
    'CREATE',
    'UPDATE',
    'DELETE',
    'GENERATE_REPORT',
    'CANCEL',
    'CONFIRM',
    'REJECT',
    'LOGIN',
    'LOGOUT',
  ];

  @override
  void initState() {
    super.initState();
    // Set default date range: 1st of current month to today
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(now);
    loadActivities();
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
                const Expanded(
                  flex: 4,
                  child: Text("กิจกรรมย้อนหลัง",
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
                  selectedActionType = null;
                  selectedScreenName = null;
                });
                loadActivities();
              },
              filterSummary: _buildFilterSummary(),
              initiallyExpanded: false,
              autoCollapseOnSearch: true,
              additionalFilters: [
                _buildActionTypeDropdown(),
              ],
            ),
            Expanded(
              child: loading
                  ? const LoadingProgress()
                  : filteredActivityList!.isEmpty
                      ? const NoDataFoundWidget(
                          message:
                              "ยังไม่มีบันทึกกิจกรรมในระบบ\nกิจกรรมจะถูกบันทึกอัตโนมัติเมื่อมีการใช้งานระบบ")
                      : Container(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.separated(
                            itemCount: filteredActivityList!.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              return modernActivityCard(
                                  filteredActivityList, index);
                            },
                          ),
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
        if (filteredActivityList == null || filteredActivityList!.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูลให้พิมพ์', 'OK', action: () {});
          return;
        }

        String dateRange = '';
        if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
          dateRange = 'ระหว่างวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}';
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewActivityLogPage(
              activities: filteredActivityList!,
              dateRange: dateRange,
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

  Widget _buildActionTypeDropdown() {
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
                'ประเภทกิจกรรม',
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
            value: selectedActionType,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.label, size: 16),
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
            items: actionTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type == 'ทั้งหมด' ? null : type,
                child: Text(type, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedActionType = value;
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
    if (selectedActionType != null) {
      filters.add('ประเภท: $selectedActionType');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }

  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'ตัวกรองข้อมูล',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Date Range
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'จากวันที่',
                  icon: Icons.calendar_today,
                  controller: fromDateCtrl,
                  onClear: () {
                    setState(() {
                      fromDateCtrl.text = "";
                      toDateCtrl.text = "";
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: 'ถึงวันที่',
                  icon: Icons.calendar_today,
                  controller: toDateCtrl,
                  onClear: () {
                    setState(() {
                      fromDateCtrl.text = "";
                      toDateCtrl.text = "";
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Type Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text('ประเภทการกระทำ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedActionType,
                      isExpanded: true,
                      hint: const Text('เลือกประเภท', style: TextStyle(fontSize: 14)),
                      items: actionTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type == 'ทั้งหมด' ? null : type,
                          child: Text(type, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedActionType = value;
                        });
                      },
                    ),
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
                    onPressed: applyFilters,
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
                    onPressed: () {
                      setState(() {
                        // Reset to today's date instead of clearing
                        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                        fromDateCtrl.text = today;
                        toDateCtrl.text = today;
                        selectedActionType = null;
                        selectedScreenName = null;
                      });
                      loadActivities();
                    },
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

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today, size: 18),
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.clear, size: 18))
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              hintText: label,
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
                    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                    setState(() {
                      controller.text = formattedDate;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget modernActivityCard(List<ActivityLogModel>? activities, int index) {
    final activity = activities![index];
    final isSuccess = activity.result?.toUpperCase() == 'SUCCESS';

    IconData actionIcon;
    Color actionColor;

    switch (activity.actionType?.toUpperCase()) {
      case 'CREATE':
        actionIcon = Icons.add_circle_rounded;
        actionColor = Colors.green;
        break;
      case 'UPDATE':
        actionIcon = Icons.edit_rounded;
        actionColor = Colors.blue;
        break;
      case 'DELETE':
        actionIcon = Icons.delete_rounded;
        actionColor = Colors.red;
        break;
      case 'CANCEL':
        actionIcon = Icons.cancel_rounded;
        actionColor = Colors.orange;
        break;
      case 'CONFIRM':
        actionIcon = Icons.check_circle_rounded;
        actionColor = Colors.teal;
        break;
      case 'REJECT':
        actionIcon = Icons.block_rounded;
        actionColor = Colors.deepOrange;
        break;
      case 'GENERATE_REPORT':
        actionIcon = Icons.print_rounded;
        actionColor = Colors.purple;
        break;
      case 'LOGIN':
        actionIcon = Icons.login_rounded;
        actionColor = Colors.blueAccent;
        break;
      case 'LOGOUT':
        actionIcon = Icons.logout_rounded;
        actionColor = Colors.grey;
        break;
      default:
        actionIcon = Icons.info_rounded;
        actionColor = Colors.grey;
    }

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
                // Action Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: actionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    actionIcon,
                    color: actionColor,
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
                              color: actionColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activity.actionType ?? 'UNKNOWN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: actionColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activity.result ?? 'UNKNOWN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSuccess
                                    ? Colors.green[700]
                                    : Colors.red[700],
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
                            activity.actionDate != null
                                ? Global.formatDate(
                                    activity.actionDate.toString())
                                : 'ไม่ระบุ',
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

            // User & Screen Information
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
                  if (activity.userDisplayName != null &&
                      activity.userDisplayName!.isNotEmpty)
                    _buildInfoRow(
                      Icons.person_rounded,
                      'ผู้ใช้',
                      activity.userDisplayName!,
                    ),
                  if (activity.screenName != null &&
                      activity.screenName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.screen_share_rounded,
                      'หน้าจอ',
                      activity.screenName!,
                    ),
                  ],
                  if (activity.recordId != null &&
                      activity.recordId!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.tag_rounded,
                      'รหัสรายการ',
                      activity.recordId!,
                    ),
                  ],
                ],
              ),
            ),

            // Description
            if (activity.description != null &&
                activity.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.description_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'รายละเอียด',
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
                text: activity.description!,
              ),
            ],

            // Result Detail (for failures)
            if (!isSuccess &&
                activity.resultDetail != null &&
                activity.resultDetail!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 16,
                          color: Colors.red[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'รายละเอียดข้อผิดพลาด',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.resultDetail!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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

  void applyFilters() async {
    setState(() {
      loading = true;
    });

    try {
      // Build search request
      var searchData = {
        'startDate': fromDateCtrl.text.isNotEmpty
            ? DateTime.parse(fromDateCtrl.text).toIso8601String()
            : null,
        'endDate': toDateCtrl.text.isNotEmpty
            ? DateTime.parse(toDateCtrl.text).toIso8601String()
            : null,
        'actionType': selectedActionType,
        'screenName': selectedScreenName,
      };

      var request = jsonEncode({
        'companyId': Global.company?.id ?? Global.user?.companyId,
        'branchId': Global.branch?.id ?? Global.user?.branchId,
        'userId': Global.user?.id,
        'data': searchData,
      });

      var result = await ApiServices.post('/activitylog/search', request);

      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ActivityLogModel> activities = activityLogListModelFromJson(data);
        setState(() {
          activityList = activities;
          filteredActivityList = activities;
        });
      } else {
        setState(() {
          activityList = [];
          filteredActivityList = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error applying filters: ${e.toString()}');
      }
      setState(() {
        filteredActivityList = [];
      });
    }

    setState(() {
      loading = false;
    });
  }

  void loadActivities() async {
    setState(() {
      loading = true;
    });
    try {
      // Use search endpoint with role-based filtering and date filter
      var searchData = {
        'startDate': fromDateCtrl.text.isNotEmpty
            ? DateTime.parse(fromDateCtrl.text).toIso8601String()
            : null,
        'endDate': toDateCtrl.text.isNotEmpty
            ? DateTime.parse(toDateCtrl.text).toIso8601String()
            : null,
        'actionType': null,
        'screenName': null,
      };

      var request = jsonEncode({
        'companyId': Global.company?.id ?? Global.user?.companyId,
        'branchId': Global.branch?.id ?? Global.user?.branchId,
        'userId': Global.user?.id,
        'data': searchData,
      });

      var result = await ApiServices.post('/activitylog/search', request);

      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ActivityLogModel> activities = activityLogListModelFromJson(data);
        setState(() {
          activityList = activities;
          filteredActivityList = activities;
        });
      } else {
        activityList = [];
        filteredActivityList = [];
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
}
