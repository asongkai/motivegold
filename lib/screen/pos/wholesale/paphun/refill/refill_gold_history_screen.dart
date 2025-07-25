import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/responsive_screen.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';

class RefillGoldHistoryScreen extends StatefulWidget {
  const RefillGoldHistoryScreen({super.key});

  @override
  State<RefillGoldHistoryScreen> createState() =>
      _RefillGoldHistoryScreenState();
}

class _RefillGoldHistoryScreenState extends State<RefillGoldHistoryScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;
  final TextEditingController yearCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  ValueNotifier<dynamic>? yearNotifier;
  ValueNotifier<dynamic>? monthNotifier;
  bool isFilterExpanded = true; // Add this line

  @override
  void initState() {
    super.initState();
    yearNotifier = ValueNotifier<int>(DateTime.now().year);
    monthNotifier = ValueNotifier<int>(DateTime.now().month);
    yearCtrl.text = DateTime.now().year.toString();
    monthCtrl.text = DateTime.now().month.toString();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
      await ApiServices.post('/order/all/type/5', Global.reportRequestObj({"year": yearCtrl.text, "month": monthCtrl.text}));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> products = orderListModelFromJson(data);
        setState(() {
          if (products.isNotEmpty) {
            orders = products;
            filterList = products;
          } else {
            orders!.clear();
            filterList!.clear();
          }
        });
      } else {
        orders = [];
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

  void search() async {
    if (yearCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกปี', 'OK');
      return;
    }

    if (monthCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกเดือน', 'OK');
      return;
    }

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายการประวัติการเติมทอง",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Filter Section
            _buildFilterSection(),

            // Content Area
            Expanded(
              child: loading
                  ? const LoadingProgress()
                  : filterList!.isEmpty
                  ? const NoDataFoundWidget()
                  : Container(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  itemCount: orders!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    return modernDataCard(orders![index], index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Collapsible Header
          GestureDetector(
            onTap: () {
              setState(() {
                isFilterExpanded = !isFilterExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.filter_alt_rounded,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ตัวกรองข้อมูล',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          '${_getThaiMonthName(int.parse(monthCtrl.text))} ${yearCtrl.text}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Collapse/Expand Icon
                  AnimatedRotation(
                    turns: isFilterExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isFilterExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isFilterExpanded ? 1.0 : 0.0,
              child: isFilterExpanded ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // Divider
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 20),

                    // Filter Controls
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'ปี',
                            icon: Icons.calendar_today_rounded,
                            notifier: yearNotifier!,
                            items: Global.genYear(),
                            onChanged: (int value) {
                              yearCtrl.text = value.toString();
                              yearNotifier!.value = value;
                              search();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'เดือน',
                            icon: Icons.date_range_rounded,
                            notifier: monthNotifier!,
                            items: Global.genMonth(),
                            onChanged: (int value) {
                              monthCtrl.text = value.toString();
                              monthNotifier!.value = value;
                              search();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: search,
                        icon: const Icon(Icons.search_rounded, size: 20),
                        label: Text(
                          'ค้นหา'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required ValueNotifier notifier,
    required List<int> items,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: MiraiDropDownMenu<int>(
            key: UniqueKey(),
            children: items,
            space: 4,
            maxHeight: 360,
            showSearchTextField: true,
            selectedItemBackgroundColor: Colors.transparent,
            emptyListMessage: 'ไม่มีข้อมูล',
            showSelectedItemBackgroundColor: true,
            itemWidgetBuilder: (
                int index,
                int? project, {
                  bool isItemSelected = false,
                }) {
              return DropDownItemWidget(
                project: project,
                isItemSelected: isItemSelected,
                firstSpace: 10,
                fontSize: 16.sp,
              );
            },
            onChanged: onChanged,
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 16.sp,
              projectValueNotifier: notifier,
            ),
          ),
        ),
      ],
    );
  }

  Widget modernDataCard(OrderModel order, int index) {
    return GestureDetector(
      onTap: () {
        // Navigation logic here
      },
      child: Container(
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.engineering_rounded,
                      color: Colors.amber[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.orderId.toString()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
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
                              _formatThaiDate(order.orderDate.toString()),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'เติมทอง',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Details Table
              if (order.details != null && order.details!.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTableHeader('สินค้า', Icons.inventory_2_rounded),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildTableHeader('น้ำหนัก', Icons.scale_rounded),
                            ),
                            Expanded(
                              flex: 3,
                              child: _buildTableHeader('คลังสินค้า', Icons.warehouse_rounded),
                            ),
                          ],
                        ),
                      ),

                      // Table Rows
                      ...order.details!.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var detail = entry.value;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: idx % 2 == 0 ? Colors.white : Colors.grey[25],
                            borderRadius: idx == order.details!.length - 1
                                ? const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  detail.productName ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  Global.format(detail.weight ?? 0),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  detail.binLocationName ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to get Thai month names
  String _getThaiMonthName(int month) {
    const thaiMonths = [
      '', // Index 0 (not used)
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    return month > 0 && month <= 12 ? thaiMonths[month] : 'ไม่ระบุ';
  }

  // Helper method to format Thai date
  String _formatThaiDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      String day = date.day.toString().padLeft(2, '0');
      String monthName = _getThaiMonthName(date.month);
      String year = (date.year + 543).toString(); // Convert to Buddhist year
      String time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

      return '$day $monthName $year เวลา $time น.';
    } catch (e) {
      return Global.formatDate(dateString); // Fallback to original format
    }
  }
}