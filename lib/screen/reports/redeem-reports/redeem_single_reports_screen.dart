import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/redeem-reports/preview_redeem_single.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/filter/compact_report_filter.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

// Simple class for Thai month
class ThaiMonth {
  final int value;
  final String name;

  ThaiMonth(this.value, this.name);

  @override
  String toString() => name;

  Map<String, dynamic> toJson() => {'value': value, 'name': name};
}

class RedeemSingleReportScreen extends StatefulWidget {
  const RedeemSingleReportScreen({super.key});

  @override
  State<RedeemSingleReportScreen> createState() =>
      _RedeemSingleReportScreenState();
}

class _RedeemSingleReportScreenState extends State<RedeemSingleReportScreen> {
  bool loading = false;
  List<RedeemModel>? orders = [];
  List<RedeemModel?>? filterList = [];
  List<RedeemDetailModel>? detailsList = []; // Flattened details list for display (matching PDF Type 1)
  Screen? size;

  // Sorting
  int? sortColumnIndex;
  bool isAscending = true;

  final TextEditingController yearCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  ValueNotifier<dynamic>? yearNotifier;
  ValueNotifier<dynamic>? monthNotifier;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  ValueNotifier<dynamic>? fromDateNotifier;
  ValueNotifier<dynamic>? toDateNotifier;
  DateTime? fromDate;
  DateTime? toDate;

  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  final List<ThaiMonth> thaiMonths = [
    ThaiMonth(1, 'มกราคม'),
    ThaiMonth(2, 'กุมภาพันธ์'),
    ThaiMonth(3, 'มีนาคม'),
    ThaiMonth(4, 'เมษายน'),
    ThaiMonth(5, 'พฤษภาคม'),
    ThaiMonth(6, 'มิถุนายน'),
    ThaiMonth(7, 'กรกฎาคม'),
    ThaiMonth(8, 'สิงหาคม'),
    ThaiMonth(9, 'กันยายน'),
    ThaiMonth(10, 'ตุลาคม'),
    ThaiMonth(11, 'พฤศจิกายน'),
    ThaiMonth(12, 'ธันวาคม'),
  ];

  @override
  void initState() {
    super.initState();
    resetFilter();
    search();
  }

  void search() async {
    makeSearchDate();

    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/redeem/all/reports',
          Global.reportRequestObj({
            "year": yearCtrl.text == "" ? null : yearCtrl.text,
            "month": monthCtrl.text == "" ? null : monthCtrl.text,
            "fromDate": fromDate.toString(),
            "toDate": toDate.toString(),
          }));

      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<RedeemModel> products = redeemListModelFromJson(data);
        setState(() {
          if (products.isNotEmpty) {
            orders = products;
            filterList = products;

            // Create flattened details list (same logic as PDF Type 1)
            detailsList = [];
            for (int i = 0; i < orders!.length; i++) {
              // If order has no details, create a placeholder detail to show the order
              if (orders![i].details == null || orders![i].details!.isEmpty) {
                final placeholderDetail = RedeemDetailModel(
                  redeemId: orders![i].id,
                  redeemDate: orders![i].redeemDate,
                  customerName: orders![i].redeemStatus == 'CANCEL'
                      ? 'ยกเลิกเอกสาร***'
                      : (orders![i].customer != null
                          ? getCustomerNameForReports(orders![i].customer!)
                          : ''),
                  taxNumber: orders![i].redeemStatus == 'CANCEL'
                      ? ''
                      : (orders![i].customer?.taxNumber != ''
                          ? orders![i].customer?.taxNumber ?? ''
                          : orders![i].customer?.idCard ?? ''),
                  referenceNo: '', // No reference number for empty details
                  redemptionVat: 0,
                  redemptionValue: 0,
                  depositAmount: 0,
                  taxBase: 0,
                  taxAmount: 0,
                );
                detailsList!.add(placeholderDetail);
              } else {
                for (int j = 0; j < orders![i].details!.length; j++) {
                  orders![i].details![j].redeemDate = orders![i].redeemDate;
                  orders![i].details![j].customerName =
                      orders![i].redeemStatus == 'CANCEL'
                          ? 'ยกเลิกเอกสาร***'
                          : (orders![i].customer != null
                              ? getCustomerNameForReports(orders![i].customer!)
                              : '');
                  // Remove tax ID for cancelled redeems
                  orders![i].details![j].taxNumber = orders![i].redeemStatus == 'CANCEL'
                      ? ''
                      : (orders![i].customer?.taxNumber != ''
                          ? orders![i].customer?.taxNumber ?? ''
                          : orders![i].customer?.idCard ?? '');
                }
                detailsList!.addAll(orders![i].details!);
              }
            }

            // Sort details by referenceNo (same logic as PDF Type 1)
            detailsList!.sort((a, b) {
              // Handle null values - put them at the end
              if (a.referenceNo == null && b.referenceNo == null) return 0;
              if (a.referenceNo == null) return 1;
              if (b.referenceNo == null) return -1;

              // Try to parse as numbers first
              final aNum = int.tryParse(a.referenceNo!);
              final bNum = int.tryParse(b.referenceNo!);

              // If both are numbers, compare numerically
              if (aNum != null && bNum != null) {
                return aNum.compareTo(bNum);
              }

              // If one is a number and one is not, put numbers first
              if (aNum != null && bNum == null) return -1;
              if (aNum == null && bNum != null) return 1;

              // If both are strings, compare alphabetically
              return a.referenceNo!.compareTo(b.referenceNo!);
            });
          } else {
            orders!.clear();
            filterList!.clear();
            detailsList!.clear();
          }
        });
      } else {
        orders = [];
        detailsList = [];
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

  makeSearchDate() {
    int month = 0;
    int year = 0;

    if (monthCtrl.text.isEmpty) {
      month = DateTime.now().month;
    } else {
      month = Global.toNumber(monthCtrl.text).toInt();
    }

    if (yearCtrl.text.isEmpty) {
      year = DateTime.now().year;
    } else {
      year = Global.toNumber(yearCtrl.text).toInt();
    }

    if (fromDateCtrl.text.isNotEmpty) {
      // Check if it's already in yyyy-MM-dd format (from date picker)
      if (fromDateCtrl.text.contains('-') && fromDateCtrl.text.length == 10) {
        // Date picker format: yyyy-MM-dd, parse directly
        fromDate = DateTime.parse(fromDateCtrl.text);
      } else {
        // Old format: just day number
        fromDate = Global.convertDate(
            '${twoDigit(Global.toNumber(fromDateCtrl.text).toInt())}-${twoDigit(month)}-$year');
      }
    } else {
      fromDate = null;
    }

    if (toDateCtrl.text.isNotEmpty) {
      // Check if it's already in yyyy-MM-dd format (from date picker)
      if (toDateCtrl.text.contains('-') && toDateCtrl.text.length == 10) {
        // Date picker format: yyyy-MM-dd, parse directly
        toDate = DateTime.parse(toDateCtrl.text);
      } else {
        // Old format: just day number
        toDate = Global.convertDate(
            '${twoDigit(Global.toNumber(toDateCtrl.text).toInt())}-${twoDigit(month)}-$year');
      }
    } else {
      toDate = null;
    }

    if (fromDate == null && toDate == null) {
      if (monthCtrl.text.isNotEmpty && yearCtrl.text.isEmpty) {
        fromDate = DateTime(year, month, 1);
        toDate = Jiffy.parseFromDateTime(fromDate!).endOf(Unit.month).dateTime;
      } else if (monthCtrl.text.isEmpty && yearCtrl.text.isNotEmpty) {
        fromDate = DateTime(year, 1, 1);
        toDate = Jiffy.parseFromDateTime(fromDate!)
            .add(months: 12, days: -1)
            .dateTime;
      } else {
        fromDate = DateTime(year, month, 1);
        toDate = Jiffy.parseFromDateTime(fromDate!).endOf(Unit.month).dateTime;
      }
    }

    motivePrint(fromDate.toString());
    motivePrint(toDate.toString());
  }

  void _sortData(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;

      // Sort detailsList to match the displayed data (matching PDF Type 1 structure)
      detailsList!.sort((a, b) {
        dynamic aValue, bValue;

        switch (columnIndex) {
          case 0: // Date
            aValue = a.redeemDate ?? DateTime.now();
            bValue = b.redeemDate ?? DateTime.now();
            break;
          case 1: // Reference No (Ticket Number)
            // Handle numeric vs string sorting for reference numbers
            final aNum = int.tryParse(a.referenceNo ?? '');
            final bNum = int.tryParse(b.referenceNo ?? '');
            if (aNum != null && bNum != null) {
              aValue = aNum;
              bValue = bNum;
            } else {
              aValue = a.referenceNo ?? '';
              bValue = b.referenceNo ?? '';
            }
            break;
          case 2: // Redeem ID (Tax Invoice) - Need to look up from parent order
            String aRedeemId = '';
            String bRedeemId = '';
            try {
              final aOrder = orders?.firstWhere((order) => order.id == a.redeemId);
              aRedeemId = aOrder?.redeemId ?? '';
            } catch (e) {
              aRedeemId = '';
            }
            try {
              final bOrder = orders?.firstWhere((order) => order.id == b.redeemId);
              bRedeemId = bOrder?.redeemId ?? '';
            } catch (e) {
              bRedeemId = '';
            }
            aValue = aRedeemId;
            bValue = bRedeemId;
            break;
          case 3: // Customer Name
            aValue = a.customerName ?? '';
            bValue = b.customerName ?? '';
            break;
          case 4: // Tax Number
            aValue = a.taxNumber ?? '';
            bValue = b.taxNumber ?? '';
            break;
          default:
            return 0;
        }

        if (aValue is String && bValue is String) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else if (aValue is num && bValue is num) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        }
        return 0;
      });
    });
  }

  void resetFilters() {
    resetFilter();
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
                  flex: 6,
                  child: Text("รายงานภาษีขายตามสัญญาขายฝาก",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 4,
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
            _buildFilterSection(),
            Expanded(
              child:
                  loading ? const LoadingProgress() : _buildEnhancedDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintButton() {
    return PopupMenuButton<int>(
      onSelected: (int value) {
        if (filterList!.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
          return;
        }
        List<RedeemModel> dailyList = [];
        if (value == 4) {
          dailyList = genDailyList(filterList!.reversed.toList());
          if (dailyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }
        }

        if (value == 4 && dailyList.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewRedeemSingleReportPage(
              orders: filterList!.reversed.toList(),
              daily: value == 4 ? dailyList.toList() : [],
              type: value,
              date:
                  '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
            ),
          ),
        );
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.print, size: 16.sp),
            title: Text('เรียงเลขที่ตั๋วสัญญาขายฝาก',
                style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.print, size: 16.sp),
            title: Text('เรียงเลขที่เอกสาร(รายตั๋ว)',
                style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: ListTile(
            leading: Icon(Icons.print, size: 16.sp),
            title: Text('เรียงเลขที่เอกสาร(สรุปยอด)',
                style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: ListTile(
            leading: Icon(Icons.print, size: 16.sp),
            title: Text('เรียงวันที่', style: TextStyle(fontSize: 14.sp)),
          ),
        ),
      ],
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
            const Icon(Icons.print_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 6),
            Text('พิมพ์',
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_outlined,
                color: Colors.white, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return CompactReportFilter(
      fromDateController: fromDateCtrl,
      toDateController: toDateCtrl,
      onSearch: search,
      onReset: resetFilters,
      filterSummary: _hasActiveFilters() ? _buildFilterSummary() : '',
      initiallyExpanded: false,
      autoCollapseOnSearch: true,
      additionalFilters: [
        // Month and Year row
        Row(
          children: [
            Expanded(
              child: _buildCompactDropdownField<ThaiMonth>(
                label: 'เดือน',
                icon: Icons.calendar_month,
                notifier: monthNotifier!,
                items: thaiMonths,
                onChanged: (ThaiMonth value) {
                  setState(() {
                    monthCtrl.text = value.value.toString();
                    monthNotifier!.value = value;

                    // Set date range to selected month
                    int year = yearCtrl.text.isEmpty
                        ? DateTime.now().year
                        : int.parse(yearCtrl.text);
                    DateTime firstDay = DateTime(year, value.value, 1);
                    DateTime lastDay = DateTime(year, value.value + 1, 0);

                    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDay);
                    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(lastDay);
                  });
                  search();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactDropdownField<int>(
                label: 'ปี',
                icon: Icons.date_range,
                notifier: yearNotifier!,
                items: Global.genYear(),
                onChanged: (int value) {
                  setState(() {
                    yearCtrl.text = value.toString();
                    yearNotifier!.value = value;

                    // Set date range to selected year
                    DateTime firstDay = DateTime(value, 1, 1);
                    DateTime lastDay = DateTime(value, 12, 31);

                    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDay);
                    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(lastDay);

                    // Clear month selection when year changes
                    monthCtrl.text = "";
                    monthNotifier!.value = null;
                  });
                  search();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedDataTable() {
    if (filterList!.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 0),
        child: const NoDataFoundWidget(),
      );
    }

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
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รายงานภาษีขายตามสัญญาขายฝาก (${detailsList!.length} รายการ)',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo[700]),
                  ),
                ),
              ],
            ),
          ),

          // Responsive DataTable
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width -
                      32, // Full width minus margins
                ),
                child: IntrinsicWidth(
                  child: Column(
                    children: [
                      // Sticky Header
                      Container(
                        color: Colors.grey[50],
                        height: 56,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Row number - Fixed small width
                              Container(
                                width: 60,
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.tag,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 2),
                                    const Flexible(
                                      child: Text(
                                        'ลำดับ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Date - Small flex
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(0, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'วัน/เดือน/ปี',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 0)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Reference No (Ticket Number) - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(1, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.confirmation_number,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'เลขที่ตั๋ว',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 1)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Redeem ID (Tax Invoice) - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(2, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.receipt_rounded,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'เลขที่ใบกำกับภาษี',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 2)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Customer Name - Medium flex for names
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(3, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.person,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'ลูกค้า',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 3)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Tax Number - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(4, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.badge,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'เลขประจำตัวผู้เสียภาษี',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 4)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Redemption VAT - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.receipt,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ราคาตามจำนวนสินไถ่ รวมภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Redemption Value - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.price_check,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ราคาตามจำนวนสินไถ่',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Deposit Amount - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.account_balance_wallet,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ราคาขายฝากที่กำหนดในสัญญา',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tax Base - Small flex
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.calculate,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ฐานภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tax Amount - Small flex
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.monetization_on_rounded,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Data Rows
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...detailsList!.asMap().entries.map((entry) {
                                int index = entry.key;
                                RedeemDetailModel detail = entry.value;

                                // Find the parent redeem order for this detail (for redeemId lookup and cancelled status)
                                String? redeemIdFromParent;
                                bool isCancelled = false;
                                try {
                                  final parentOrder = orders?.firstWhere(
                                    (order) => order.id == detail.redeemId
                                  );
                                  redeemIdFromParent = parentOrder?.redeemId;
                                  isCancelled = parentOrder?.redeemStatus == 'CANCEL';
                                } catch (e) {
                                  redeemIdFromParent = '';
                                }

                                // Set text color based on cancelled status (matching PDF)
                                final textColor = isCancelled ? Colors.red[900] : Colors.black;

                                return Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0
                                        ? Colors.white
                                        : Colors.grey[50],
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[200]!,
                                            width: 0.5)),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        // Row number
                                        Container(
                                          width: 60,
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isCancelled
                                                  ? Colors.red.withOpacity(0.1)
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // Date
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.dateOnly(
                                                  detail.redeemDate.toString()),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: textColor),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Reference No (Ticket Number)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              detail.referenceNo ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 11,
                                                color: textColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // Redeem ID (Tax Invoice)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isCancelled
                                                    ? Colors.red.withOpacity(0.1)
                                                    : Colors.blue.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                redeemIdFromParent ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 11,
                                                  color: isCancelled ? Colors.red[900] : Colors.blue[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Customer Name
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              detail.customerName ?? '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 11,
                                                  color: textColor),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // Tax Number
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              detail.taxNumber ?? '',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isCancelled ? Colors.red[900] : Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // Redemption VAT
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(detail.redemptionVat ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Redemption Value
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(detail.redemptionValue ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Deposit Amount
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(detail.depositAmount ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Tax Base
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(detail.taxBase ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Tax Amount
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(detail.taxAmount ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: isCancelled ? Colors.red[900] : Colors.green,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              // Total Row
                              Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.indigo[50],
                                  border: Border(
                                      top: BorderSide(
                                          color: Colors.indigo[200]!,
                                          width: 2)),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      // Empty cells for alignment
                                      Container(
                                          width: 60,
                                          padding: const EdgeInsets.all(8)),
                                      Expanded(flex: 1, child: Container()), // Date
                                      Expanded(flex: 2, child: Container()), // Reference No
                                      Expanded(flex: 2, child: Container()), // Redeem ID
                                      Expanded(flex: 2, child: Container()), // Customer
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            'รวมทั้งหมด',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Total Redemption VAT
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(detailsList!.fold(0.0, (sum, d) => sum + (d.redemptionVat ?? 0))),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Total Redemption Value
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(detailsList!.fold(0.0, (sum, d) => sum + (d.redemptionValue ?? 0))),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Total Deposit Amount
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(detailsList!.fold(0.0, (sum, d) => sum + (d.depositAmount ?? 0))),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Total Tax Base
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(detailsList!.fold(0.0, (sum, d) => sum + (d.taxBase ?? 0))),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Total Tax Amount
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(detailsList!.fold(0.0, (sum, d) => sum + (d.taxAmount ?? 0))),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.green[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.calendar_today, size: 18),
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: onClear, child: const Icon(Icons.clear, size: 18))
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
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
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(date);
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

  Widget _buildCompactDropdownField<T>({
    required String label,
    required IconData icon,
    required ValueNotifier notifier,
    required List<T> items,
    required Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: MiraiDropDownMenu<T>(
            key: UniqueKey(),
            children: items,
            space: 4,
            maxHeight: 300,
            showSearchTextField: true,
            selectedItemBackgroundColor: Colors.transparent,
            emptyListMessage: 'ไม่มีข้อมูล',
            showSelectedItemBackgroundColor: true,
            itemWidgetBuilder: (int index, T? project,
                {bool isItemSelected = false}) {
              return DropDownItemWidget(
                project: project,
                isItemSelected: isItemSelected,
                firstSpace: 8,
                fontSize: 14.sp,
              );
            },
            onChanged: onChanged,
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 14.sp,
              projectValueNotifier: notifier,
            ),
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return fromDateCtrl.text.isNotEmpty ||
        toDateCtrl.text.isNotEmpty ||
        monthCtrl.text.isNotEmpty ||
        yearCtrl.text.isNotEmpty;
  }

  String _buildFilterSummary() {
    List<String> filters = [];
    if (monthNotifier?.value != null && monthNotifier?.value is ThaiMonth) {
      ThaiMonth month = monthNotifier!.value as ThaiMonth;
      filters.add('เดือน: ${month.name}');
    }
    if (yearCtrl.text.isNotEmpty) {
      filters.add('ปี: ${yearCtrl.text}');
    }
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      filters.add(
          'ช่วงวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }

  void resetFilter() {
    yearCtrl.text = "";
    monthCtrl.text = "";
    yearNotifier = ValueNotifier<dynamic>(null);
    monthNotifier = ValueNotifier<dynamic>(null);
    fromDateNotifier = ValueNotifier<dynamic>("");
    toDateNotifier = ValueNotifier<dynamic>("");

    // Set default date range: 1st of current month to today
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(now);

    fromDate = null;
    toDate = null;
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    search();
    setState(() {});
  }

  List<RedeemModel> genDailyList2(List<RedeemModel?>? filterList) {
    List<RedeemModel> orderList = [];
    int days = Global.daysBetween(fromDate!, toDate!);
    for (int i = 0; i <= days; i++) {
      DateTime? monthDate = fromDate!.add(Duration(days: i));
      var dateList = filterList
          ?.where((element) =>
              Global.dateOnly(element!.redeemDate.toString()) ==
              Global.dateOnly(monthDate.toString()))
          .toList();
      // motivePrint(dateList?.length);
      if (dateList!.isNotEmpty) {
        var order = RedeemModel(
          redeemId: '${dateList.first?.redeemId} - ${dateList.last?.redeemId}',
          redeemDate: dateList.first?.redeemDate,
          createdDate: monthDate,
          customerId: 0,
          weight: getWeightTotal(dateList),
          redemptionVat: getRedemptionVatTotal(dateList),
          redemptionValue: getRedemptionValueTotal(dateList),
          depositAmount: getDepositAmountTotal(dateList),
          taxBase: taxBaseTotal(dateList),
          taxAmount: taxAmountTotal(dateList),
          status: dateList.any((element) => element!.status == 2) ? 2 : 1,
          redeemStatus:
              dateList.any((element) => element!.redeemStatus == "CANCEL")
                  ? "CANCEL"
                  : "",
        );
        orderList.add(order);
      }
    }
    return orderList;
  }

  List<RedeemModel> genDailyList(List<RedeemModel?>? filterList, {int? value}) {
    List<RedeemModel> orderList = [];

    int days = Global.daysBetween(fromDate!, toDate!);

    for (int i = 0; i <= days; i++) {
      DateTime monthDate = fromDate!.add(Duration(days: i));

      // Get all orders for this specific date
      var dateList = filterList
          ?.where((element) =>
              element != null &&
              Global.dateOnly(element.redeemDate.toString()) ==
                  Global.dateOnly(monthDate.toString()))
          .cast<RedeemModel>() // Cast to non-nullable RedeemModel
          .toList();

      if (dateList != null && dateList.isNotEmpty) {
        // Sort by redeemId to get correct first and last
        dateList.sort((a, b) {
          final redeemIdA = a.redeemId ?? '';
          final redeemIdB = b.redeemId ?? '';
          return redeemIdA.compareTo(redeemIdB);
        });

        // Create order ID from first and last order
        String combinedOrderId = dateList.length == 1
            ? dateList.first.redeemId!
            : '${dateList.first.redeemId} - ${dateList.last.redeemId}';

        var order = RedeemModel(
          redeemId:
              combinedOrderId, //'${dateList.first.redeemId} - ${dateList.last.redeemId}',
          redeemDate: dateList.first.redeemDate,
          referenceNo: 'รวมใบกำกับภาษีประจำวัน',
          createdDate: monthDate,
          customerId: 0,
          weight: getWeightTotal(dateList),
          redemptionVat: getRedemptionVatTotal(dateList),
          redemptionValue: getRedemptionValueTotal(dateList),
          depositAmount: getDepositAmountTotal(dateList),
          taxBase: taxBaseTotal(dateList),
          taxAmount: taxAmountTotal(dateList),
          status: dateList.any((element) => element.status == 2) ? 2 : 1,
          redeemStatus:
              dateList.any((element) => element.redeemStatus == "CANCEL")
                  ? "CANCEL"
                  : "",
        );

        orderList.add(order);
      } else {
        // Optional: Add "no sales" entry for days with no orders

        var noSalesOrder = RedeemModel(
          redeemId: 'ไม่มียอดไถ่ถอน',
          redeemDate: monthDate,
          createdDate: monthDate,
          customerId: 0,
          weight: 0.0,
          redemptionVat: 0.0,
          redemptionValue: 0.0,
          depositAmount: 0.0,
          taxBase: 0.0,
          taxAmount: 0.0,
        );

        orderList.add(noSalesOrder);
      }
    }
    return orderList;
  }
}
