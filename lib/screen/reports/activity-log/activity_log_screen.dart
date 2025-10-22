import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/activity_log.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
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
  DateTime? startDate;
  DateTime? endDate;
  String? selectedActionType;
  String? selectedScreenName;
  bool showFilters = false;

  final List<String> actionTypes = [
    'ทั้งหมด',
    'CREATE',
    'UPDATE',
    'DELETE',
    'GENERATE_REPORT',
    'CANCEL',
    'CONFIRM',
    'REJECT',
  ];

  @override
  void initState() {
    super.initState();
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
                      _buildFilterButton(),
                      const SizedBox(width: 8),
                      _buildSearchButton(),
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
              showFilters ? Icons.filter_alt_off : Icons.filter_alt,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              showFilters ? 'ซ่อนตัวกรอง' : 'ค้นหา',
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

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: () {
        applyFilters();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('วันเริ่มต้น',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              startDate != null
                                  ? DateFormat('dd/MM/yyyy').format(startDate!)
                                  : 'เลือกวันที่',
                              style: TextStyle(
                                fontSize: 14,
                                color: startDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('วันสิ้นสุด',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              endDate != null
                                  ? DateFormat('dd/MM/yyyy').format(endDate!)
                                  : 'เลือกวันที่',
                              style: TextStyle(
                                fontSize: 14,
                                color: endDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Type Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ประเภทการกระทำ',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedActionType,
                    isExpanded: true,
                    hint: const Text('เลือกประเภท'),
                    items: actionTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type == 'ทั้งหมด' ? null : type,
                        child: Text(type),
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
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                      selectedActionType = null;
                      selectedScreenName = null;
                      filteredActivityList = activityList;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('ล้างตัวกรอง'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('ค้นหา'),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void applyFilters() async {
    setState(() {
      loading = true;
    });

    try {
      // Build search request
      var searchData = {
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
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
      var result = await ApiServices.get('/activitylog');
      motivePrint(result?.toJson());
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
