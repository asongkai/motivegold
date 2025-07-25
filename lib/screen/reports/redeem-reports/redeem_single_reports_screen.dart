import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/buy-used-gold-gov-reports/preview.dart';
import 'package:motivegold/screen/reports/redeem-reports/preview_redeem_single.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:quiver/time.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

class RedeemSingleReportScreen extends StatefulWidget {
  const RedeemSingleReportScreen({super.key});

  @override
  State<RedeemSingleReportScreen> createState() =>
      _RedeemSingleReportScreenState();
}

class _RedeemSingleReportScreenState
    extends State<RedeemSingleReportScreen> {
  bool loading = false;
  List<RedeemModel>? orders = [];
  List<RedeemModel?>? filterList = [];
  Screen? size;
  bool isFilterExpanded = true;

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
      fromDate = Global.convertDate(
          '${twoDigit(Global.toNumber(fromDateCtrl.text).toInt())}-${twoDigit(month)}-$year');
    } else {
      fromDate = null;
    }

    if (toDateCtrl.text.isNotEmpty) {
      toDate = Global.convertDate(
          '${twoDigit(Global.toNumber(toDateCtrl.text).toInt())}-${twoDigit(month)}-$year');
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

      filterList!.sort((a, b) {
        dynamic aValue, bValue;

        switch (columnIndex) {
          case 0: // Date
            aValue = a?.redeemDate ?? DateTime.now();
            bValue = b?.redeemDate ?? DateTime.now();
            break;
          case 1: // Redeem ID
            aValue = a?.redeemId ?? '';
            bValue = b?.redeemId ?? '';
            break;
          case 2: // Customer Name
            aValue = '${a?.customer?.firstName ?? ''} ${a?.customer?.lastName ?? ''}';
            bValue = '${b?.customer?.firstName ?? ''} ${b?.customer?.lastName ?? ''}';
            break;
          case 3: // Tax Number
            aValue = Global.company?.taxNumber ?? '';
            bValue = Global.company?.taxNumber ?? '';
            break;
          case 4: // Weight
            aValue = getWeight(a);
            bValue = getWeight(b);
            break;
          case 5: // Payment Amount
            aValue = a?.paymentAmount ?? 0;
            bValue = b?.paymentAmount ?? 0;
            break;
          default:
            return 0;
        }

        if (aValue is String && bValue is String) {
          return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else if (aValue is num && bValue is num) {
          return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
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
              child: loading ? const LoadingProgress() : _buildEnhancedDataTable(),
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
          List<RedeemModel> daily = genDailyList(filterList!.reversed.toList());
          if (daily.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }

          int days = Global.daysBetween(fromDate!, toDate!);

          for (int j = 0; j <= days; j++) {
            var indexDay = fromDate?.add(Duration(days: j));
            for (int i = 0; i < daily.length; i++) {
              if (daily[i].createdDate == indexDay) {
                daily[i].referenceNo = 'รวมใบกำกับภาษีประจำวัน';
                dailyList.add(daily[i]);
              } else {
                var checkExisting = dailyList.where((e) => e.createdDate == indexDay).toList();
                if (checkExisting.isEmpty) {
                  dailyList.add(RedeemModel(
                      redeemId: 'ไม่มียอดไถ่ถอน',
                      redeemDate: indexDay,
                      referenceNo: '',
                      customer: daily[i].customer));
                }
              }
            }
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
              date: '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
            ),
          ),
        );
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.print, size: 16.sp),
            title: Text('เรียงเลขที่ตั๋วสัญญาขายฝาก', style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.print, size: 16.sp),
            title: Text('เรียงเลขที่เอกสาร(รายตั๋ว)', style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: ListTile(
            leading: Icon(Icons.print, size: 16.sp),
            title: Text('เรียงเลขที่เอกสาร(สรุปยอด)', style: TextStyle(fontSize: 14.sp)),
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
            Text('พิมพ์', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_outlined, color: Colors.white, size: 16.sp),
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
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.filter_alt_rounded, color: Colors.indigo[600], size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ตัวกรองข้อมูล', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                        if (_hasActiveFilters())
                          Text(_buildFilterSummary(), style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isFilterExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600], size: 24),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isFilterExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isFilterExpanded ? 1.0 : 0.0,
              child: isFilterExpanded ? Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Container(width: double.infinity, height: 1, color: Colors.grey[200]),
                        const SizedBox(height: 20),

                        // Date range row
                        Row(
                          children: [
                            Expanded(child: _buildDateField(
                              label: 'จากวันที่',
                              icon: Icons.calendar_today,
                              controller: fromDateCtrl,
                              onClear: () {
                                setState(() {
                                  fromDateCtrl.text = "";
                                });
                              },
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDateField(
                              label: 'ถึงวันที่',
                              icon: Icons.calendar_today,
                              controller: toDateCtrl,
                              onClear: () {
                                setState(() {
                                  toDateCtrl.text = "";
                                });
                              },
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Month and Year row
                        Row(
                          children: [
                            Expanded(child: _buildDropdownField(
                              label: 'เดือน',
                              icon: Icons.calendar_month,
                              children: Global.genMonth(),
                              controller: monthCtrl,
                              notifier: monthNotifier!,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDropdownField(
                              label: 'ปี',
                              icon: Icons.date_range,
                              children: Global.genYear(),
                              controller: yearCtrl,
                              notifier: yearNotifier!,
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action buttons
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
                                  onPressed: search,
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
                                    side: BorderSide(color: Colors.red, width: 1.5),
                                    foregroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: resetFilters,
                                  icon: const Icon(Icons.clear_rounded, size: 20),
                                  label: const Text('Reset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ) : const SizedBox(),
            ),
          ),
        ],
      ),
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
                Icon(Icons.receipt_long_rounded, color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รายงานภาษีขายตามสัญญาขายฝาก (${filterList!.length} รายการ)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo[700]),
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
                  minWidth: MediaQuery.of(context).size.width - 32, // Full width minus margins
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
                                    Icon(Icons.tag, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 2),
                                    const Flexible(
                                      child: Text(
                                        'ลำดับ',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
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
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'วัน/เดือน/ปี',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 0)
                                          Icon(
                                            isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Redeem ID - Large flex for receipt numbers
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(1, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.receipt_rounded, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'เลขที่ใบสำคัญรับเงิน',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 1)
                                          Icon(
                                            isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Customer Name - Large flex for names
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(2, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'ผู้ซื้อ',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 2)
                                          Icon(
                                            isAscending ? Icons.arrow_upward : Icons.arrow_downward,
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
                                    onTap: () => _sortData(3, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'เลขประจำตัวผู้เสียภาษี',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 3)
                                          Icon(
                                            isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Product Type - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.category, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'รายการสินค้า',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Weight - Small flex for numbers
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(4, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.scale_rounded, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'น้ำหนัก (กรัม)',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        if (sortColumnIndex == 4)
                                          Icon(
                                            isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Payment Amount - Medium flex for currency
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(5, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.monetization_on_rounded, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'จำนวนเงิน (บาท)',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        if (sortColumnIndex == 5)
                                          Icon(
                                            isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
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
                              ...filterList!.asMap().entries.map((entry) {
                                int index = entry.key;
                                RedeemModel? item = entry.value;

                                return Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                                    border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        // Row number
                                        Container(
                                          width: 60,
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: Colors.grey,
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
                                              Global.dateOnly(item!.redeemDate.toString()),
                                              style: const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Redeem ID
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.redeemId ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 11,
                                                  color: Colors.blue[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Customer Name
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Icon(Icons.person, size: 12, color: Colors.green[600]),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    '${item.customer?.firstName ?? ''} ${item.customer?.lastName ?? ''}',
                                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Tax Number
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.company?.taxNumber ?? '',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // Product Type
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'ทองคำรูปพรรณ 96.5%',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.purple[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Weight
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(getWeight(item)),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.orange,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Payment Amount
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(item.paymentAmount ?? 0),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.green,
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
                                  border: Border(top: BorderSide(color: Colors.indigo[200]!, width: 2)),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      // Empty cells for alignment
                                      Container(width: 60, padding: const EdgeInsets.all(8)),
                                      Expanded(flex: 1, child: Container()),
                                      Expanded(flex: 3, child: Container()),
                                      Expanded(flex: 3, child: Container()),
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
                                      Expanded(flex: 2, child: Container()),
                                      // Total Weight
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(getWeightTotal(filterList as dynamic)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.orange[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Total Payment Amount
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(getPaymentAmountTotal(filterList as dynamic)),
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
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
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

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required List<dynamic> children,
    required TextEditingController controller,
    required ValueNotifier<dynamic> notifier,
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
          child: MiraiDropDownMenu<dynamic>(
            key: UniqueKey(),
            children: children,
            space: 4,
            maxHeight: 360,
            showSearchTextField: true,
            selectedItemBackgroundColor: Colors.transparent,
            emptyListMessage: 'ไม่มีข้อมูล',
            showSelectedItemBackgroundColor: true,
            itemWidgetBuilder: (int index, dynamic project, {bool isItemSelected = false}) {
              return DropDownItemWidget(
                project: project,
                isItemSelected: isItemSelected,
                firstSpace: 10,
                fontSize: 14,
              );
            },
            onChanged: (dynamic value) {
              controller.text = value.toString();
              notifier.value = value;
              search();
            },
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 14,
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
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      filters.add('ช่วงวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    if (monthCtrl.text.isNotEmpty) {
      filters.add('เดือน: ${monthCtrl.text}');
    }
    if (yearCtrl.text.isNotEmpty) {
      filters.add('ปี: ${yearCtrl.text}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }

  void resetFilter() {
    yearNotifier = ValueNotifier<dynamic>("");
    monthNotifier = ValueNotifier<dynamic>("");
    fromDateNotifier = ValueNotifier<dynamic>("");
    toDateNotifier = ValueNotifier<dynamic>("");
    yearCtrl.text = "";
    monthCtrl.text = "";
    fromDateCtrl.text = "";
    toDateCtrl.text = "";
    fromDate = null;
    toDate = null;
    productNotifier = ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    search();
    setState(() {});
  }

  List<RedeemModel> genDailyList(List<RedeemModel?>? filterList) {
    List<RedeemModel> orderList = [];
    int days = Global.daysBetween(fromDate!, toDate!);
    for (int i = 0; i <= days; i++) {
      DateTime? monthDate = fromDate!.add(Duration(days: i));
      var dateList = filterList
          ?.where((element) =>
      Global.dateOnly(element!.createdDate.toString()) ==
          Global.dateOnly(monthDate.toString()))
          .toList();
      motivePrint(dateList?.length);
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
          taxAmount: taxAmountTotal(dateList),);
        orderList.add(order);
      }
    }
    return orderList;
  }
}