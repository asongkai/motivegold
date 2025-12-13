import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/money-movement-reports/preview.dart';
import 'package:motivegold/screen/reports/sell-new-gold-reports/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/filter/compact_report_filter.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:sizer/sizer.dart';

import 'make_pdf.dart';

class MoneyMovementReportScreen extends StatefulWidget {
  const MoneyMovementReportScreen({super.key});

  @override
  State<MoneyMovementReportScreen> createState() =>
      _MoneyMovementReportScreenState();
}

class _MoneyMovementReportScreenState extends State<MoneyMovementReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel>? filterList = [];
  Screen? size;

  // Sorting
  int? sortColumnIndex;
  bool isAscending = true;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set default date range: 1st of current month to today
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    fromDateCtrl.text = firstDayOfMonth.toString().split(' ')[0];
    toDateCtrl.text = now.toString().split(' ')[0];

    // Load data with default dates
    loadProducts();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/money-movement',
          Global.reportRequestObj({
            "year": 0,
            "month": 0,
            "fromDate": fromDateCtrl.text.isNotEmpty
                ? DateTime.parse(fromDateCtrl.text).toString()
                : null,
            "toDate": toDateCtrl.text.isNotEmpty
                ? DateTime.parse(toDateCtrl.text).toString()
                : null,
          }));
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

  void _sortData(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;

      filterList!.sort((a, b) {
        dynamic aValue, bValue;

        switch (columnIndex) {
          case 0: // เลขที่ใบกำกับภาษี (orderId)
            aValue = a.orderId ?? '';
            bValue = b.orderId ?? '';
            break;
          case 1: // ชื่อลูกค้า
            aValue = '${a.customer?.firstName ?? ''} ${a.customer?.lastName ?? ''}';
            bValue = '${b.customer?.firstName ?? ''} ${b.customer?.lastName ?? ''}';
            break;
          case 2: // วันที่
            aValue = a.orderDate ?? DateTime.now();
            bValue = b.orderDate ?? DateTime.now();
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
    fromDateCtrl.text = "";
    toDateCtrl.text = "";
    filterList = orders;
    setState(() {});
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
                  child: Text("รายงานเส้นทางการเงินทองรูปพรรณ",
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
    return GestureDetector(
      onTap: () {
        if (fromDateCtrl.text.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'กรุณาเลือกจากวันที่', 'OK', action: () {});
          return;
        }
        if (toDateCtrl.text.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'กรุณาเลือกถึงวันที่', 'OK', action: () {});
          return;
        }
        if (filterList!.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK', action: () {});
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewMoneyMovementReportPage(
              orders: filterList!.reversed.toList(),
              type: 1,
              date: '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
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
            const Icon(Icons.print_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 6),
            Text('พิมพ์', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return CompactReportFilter(
      fromDateController: fromDateCtrl,
      toDateController: toDateCtrl,
      onSearch: loadProducts,
      onReset: resetFilters,
      filterSummary: _buildFilterSummary(),
      initiallyExpanded: false, // Start collapsed
      autoCollapseOnSearch: true, // Auto-collapse after search
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
                Icon(Icons.timeline_rounded, color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รายงานเส้นทางการเงินทองรูปพรรณ (${filterList!.length} รายการ)',
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
                      // Sticky Header - Matches PDF Type 1: ลำดับ, เลขที่ใบกำกับภาษี, ชื่อลูกค้า, วันที่, นน.ขายออก, นน.รับซื้อ, จำนวนเงินสุทธิ, ยอดรับเงิน, ยอดจ่ายเงิน, รับ(จ่าย)สุทธิ
                      Container(
                        color: Colors.grey[50],
                        height: 56,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // 1. ลำดับ
                              Container(
                                width: 50,
                                padding: const EdgeInsets.all(8),
                                child: const Text(
                                  'ลำดับ',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // 2. เลขที่ใบกำกับภาษี
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(0, !isAscending),
                                    child: Row(
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'เลขที่ใบกำกับภาษี',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
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
                              // 3. ชื่อลูกค้า
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(1, !isAscending),
                                    child: Row(
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'ชื่อลูกค้า',
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
                              // 4. วันที่
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(2, !isAscending),
                                    child: Row(
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'วันที่',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
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
                              // 5. นน.ทองขายออก (กรัม)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'นน.ขายออก\n(กรัม)',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              // 6. นน.ทองรับซื้อ (กรัม)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'นน.รับซื้อ\n(กรัม)',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              // 7. จำนวนเงินสุทธิ (บาท)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'จำนวนเงินสุทธิ\n(บาท)',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              // 8. ยอดรับเงิน
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'ยอดรับเงิน',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 9. ยอดจ่ายเงิน
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'ยอดจ่ายเงิน',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 10. ร้านทองรับ(จ่าย)สุทธิ
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'รับ(จ่าย)สุทธิ',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Data Rows - Matches PDF Type 1 structure
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Regular data rows
                              ...filterList!.asMap().entries.map((entry) {
                                int index = entry.key;
                                OrderModel item = entry.value;
                                final isCancelled = item.status == "2";
                                final textColor = isCancelled ? Colors.red[900] : Colors.black;

                                // Calculate values using PDF helper functions
                                final sellWeight = (item.orderTypeId == 1) ? getWeight(item) : 0.0;
                                final buyWeight = (item.orderTypeId == 2) ? getWeight(item) : 0.0;
                                final netValue = payToCustomerOrShopValue(filterList!, item);
                                final receiveAmount = (item.orderTypeId == 1) ? (item.priceIncludeTax ?? 0) : 0.0;
                                final payAmount = (item.orderTypeId == 2) ? (item.priceIncludeTax ?? 0) : 0.0;

                                return Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                                    border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        // 1. ลำดับ
                                        Container(
                                          width: 50,
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                              color: textColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // 2. เลขที่ใบกำกับภาษี
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              item.orderId ?? '',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: textColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // 3. ชื่อลูกค้า
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '***ยกเลิกเอกสาร'
                                                  : item.customer != null
                                                      ? getCustomerName(item.customer!)
                                                      : '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                color: textColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // 4. วันที่
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.dateOnly(item.orderDate.toString()),
                                              style: TextStyle(fontSize: 10, color: textColor),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 5. นน.ขายออก (กรัม) - orderTypeId == 1
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : sellWeight > 0
                                                      ? Global.format(sellWeight)
                                                      : '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 6. นน.รับซื้อ (กรัม) - orderTypeId == 2
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : buyWeight > 0
                                                      ? Global.format(buyWeight)
                                                      : '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 7. จำนวนเงินสุทธิ (บาท)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : item.orderTypeId == 1
                                                      ? Global.format(item.priceIncludeTax ?? 0)
                                                      : '(${Global.format(item.priceIncludeTax ?? 0)})',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: isCancelled
                                                    ? Colors.red[900]
                                                    : item.orderTypeId == 1
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 8. ยอดรับเงิน (orderTypeId == 1)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : receiveAmount > 0
                                                      ? Global.format(receiveAmount)
                                                      : '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: isCancelled ? Colors.red[900] : Colors.green,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 9. ยอดจ่ายเงิน (orderTypeId == 2)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : payAmount > 0
                                                      ? '(${Global.format(payAmount)})'
                                                      : '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: isCancelled ? Colors.red[900] : Colors.red,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 10. รับ(จ่าย)สุทธิ
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : netValue > 0
                                                      ? Global.format(netValue)
                                                      : netValue < 0
                                                          ? '(${Global.format(-netValue)})'
                                                          : '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: isCancelled
                                                    ? Colors.red[900]
                                                    : netValue > 0
                                                        ? Colors.green
                                                        : netValue < 0
                                                            ? Colors.red
                                                            : Colors.black,
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

                              // Summary row - Matches PDF structure
                              Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.indigo[50],
                                  border: Border(top: BorderSide(color: Colors.indigo[200]!, width: 2)),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      // 1. ลำดับ - empty
                                      Container(width: 50, padding: const EdgeInsets.all(8)),
                                      // 2. เลขที่ใบกำกับภาษี - empty
                                      Expanded(flex: 2, child: Container()),
                                      // 3. ชื่อลูกค้า - empty
                                      Expanded(flex: 2, child: Container()),
                                      // 4. วันที่ - "รวมทั้งหมด"
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            'รวมทั้งหมด',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 5. นน.ขายออก total
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(getWeightTotalSN(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 6. นน.รับซื้อ total
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(getWeightTotalBU(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 7. จำนวนเงินสุทธิ total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Builder(
                                            builder: (context) {
                                              final netTotal = priceIncludeTaxTotalMovement(filterList!);
                                              return Text(
                                                netTotal > 0
                                                    ? Global.format(netTotal)
                                                    : netTotal < 0
                                                        ? '(${Global.format(-netTotal)})'
                                                        : '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 10,
                                                  color: netTotal > 0
                                                      ? Colors.green[700]
                                                      : netTotal < 0
                                                          ? Colors.red[700]
                                                          : Colors.indigo[700],
                                                ),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // 8. ยอดรับเงิน total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(priceIncludeTaxTotalSN(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                              color: Colors.green[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 9. ยอดจ่ายเงิน total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Builder(
                                            builder: (context) {
                                              final payTotal = priceIncludeTaxTotalBU(filterList!);
                                              return Text(
                                                payTotal == 0 ? '' : '(${Global.format(payTotal)})',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 10,
                                                  color: Colors.red[700],
                                                ),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // 10. รับ(จ่าย)สุทธิ total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Builder(
                                            builder: (context) {
                                              final netShopTotal = payToCustomerOrShopValueTotalAlternative(filterList!);
                                              return Text(
                                                netShopTotal == 0
                                                    ? ''
                                                    : netShopTotal > 0
                                                        ? Global.format(netShopTotal)
                                                        : '(${Global.format(netShopTotal.abs())})',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 10,
                                                  color: netShopTotal > 0
                                                      ? Colors.green[700]
                                                      : netShopTotal < 0
                                                          ? Colors.red[700]
                                                          : Colors.indigo[700],
                                                ),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            },
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

          // Summary Footer - Matches PDF Type 1 structure
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รวม ${filterList!.length} รายการ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo[700],
                    ),
                  ),
                ),
                Text(
                  'ขายออก: ${Global.format(getWeightTotalSN(filterList!))} กรัม',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'รับซื้อ: ${Global.format(getWeightTotalBU(filterList!))} กรัม',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 16),
                Builder(
                  builder: (context) {
                    final netTotal = priceIncludeTaxTotalMovement(filterList!);
                    return Text(
                      'เงินสุทธิ: ${netTotal >= 0 ? Global.format(netTotal) : "(${Global.format(-netTotal)})"}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: netTotal >= 0 ? Colors.green[700] : Colors.red[700],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildFilterSummary() {
    List<String> filters = [];
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      filters.add('ช่วงวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }
}