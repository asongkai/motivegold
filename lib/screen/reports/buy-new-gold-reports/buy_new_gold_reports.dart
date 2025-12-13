import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/buy-new-gold-reports/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/filter/compact_report_filter.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:sizer/sizer.dart';

class BuyNewGoldReportScreen extends StatefulWidget {
  const BuyNewGoldReportScreen({super.key});

  @override
  State<BuyNewGoldReportScreen> createState() => _BuyNewGoldReportScreenState();
}

class _BuyNewGoldReportScreenState extends State<BuyNewGoldReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
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
          '/order/all/type/5',
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
          case 0: // เลขที่ใบกำกับภาษี (referenceNo)
            aValue = a!.referenceNo ?? '';
            bValue = b!.referenceNo ?? '';
            break;
          case 1: // เลขที่ใบรับทอง (orderId)
            aValue = a!.orderId ?? '';
            bValue = b!.orderId ?? '';
            break;
          case 2: // วันที่
            aValue = a!.orderDate ?? DateTime.now();
            bValue = b!.orderDate ?? DateTime.now();
            break;
          case 3: // ชื่อผู้ขาย
            aValue = '${a!.customer?.firstName ?? ''} ${a.customer?.lastName ?? ''}';
            bValue = '${b!.customer?.firstName ?? ''} ${b.customer?.lastName ?? ''}';
            break;
          case 4: // เลขประจำตัวผู้เสียภาษี
            aValue = a!.customer?.taxNumber ?? '';
            bValue = b!.customer?.taxNumber ?? '';
            break;
          case 5: // น้ำหนักรวม (กรัม)
            aValue = getWeight(a!);
            bValue = getWeight(b!);
            break;
          case 6: // ราคาซื้อไม่รวมภาษีมูลค่าเพิ่ม (priceExcludeTax)
            aValue = a!.priceExcludeTax ?? 0;
            bValue = b!.priceExcludeTax ?? 0;
            break;
          case 7: // มูลค่าฐานภาษียกเว้น (purchasePrice)
            aValue = a!.purchasePrice ?? 0;
            bValue = b!.purchasePrice ?? 0;
            break;
          case 8: // ผลต่างฐานภาษี (taxBase)
            aValue = a!.taxBase ?? 0;
            bValue = b!.taxBase ?? 0;
            break;
          case 9: // ภาษีมูลค่าเพิ่ม (taxAmount)
            aValue = a!.taxAmount ?? 0;
            bValue = b!.taxAmount ?? 0;
            break;
          case 10: // ราคาซื้อรวมภาษีมูลค่าเพิ่ม (priceIncludeTax)
            aValue = a!.priceIncludeTax ?? 0;
            bValue = b!.priceIncludeTax ?? 0;
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
                  child: Text("รายงานซื้อทองรูปพรรณใหม่",
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
            builder: (context) => PreviewBuyNewGoldReportPage(
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
                    'รายงานซื้อทองใหม่ (${filterList!.length} รายการ)',
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
                      // Sticky Header - Matching PDF structure
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
                              // 2. เลขที่ใบกำกับภาษี (referenceNo)
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
                              // 3. เลขที่ใบรับทอง (orderId)
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
                                            'เลขที่ใบรับทอง',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
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
                              // 5. ชื่อผู้ขาย
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(3, !isAscending),
                                    child: Row(
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'ชื่อผู้ขาย',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
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
                              // 6. รหัสสำนักงานใหญ่/สาขา
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'รหัสสาขา',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 7. เลขประจำตัวผู้เสียภาษี
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(4, !isAscending),
                                    child: Row(
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'เลขประจำตัว\nผู้เสียภาษี',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
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
                              // 8. น้ำหนักรวม (กรัม)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(5, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'น้ำหนักรวม\n(กรัม)',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            maxLines: 2,
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
                              // 9. ราคาซื้อไม่รวมภาษีมูลค่าเพิ่ม (priceExcludeTax)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(6, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'ราคาซื้อไม่รวม\nภาษีมูลค่าเพิ่ม',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            maxLines: 2,
                                          ),
                                        ),
                                        if (sortColumnIndex == 6)
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
                              // 10. มูลค่าฐานภาษียกเว้น (purchasePrice)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(7, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'มูลค่าฐานภาษี\nยกเว้น',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            maxLines: 2,
                                          ),
                                        ),
                                        if (sortColumnIndex == 7)
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
                              // 11. ผลต่างฐานภาษี (taxBase)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(8, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'ผลต่างฐานภาษี',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        if (sortColumnIndex == 8)
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
                              // 12. ภาษีมูลค่าเพิ่ม (taxAmount)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(9, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'ภาษีมูลค่าเพิ่ม',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        if (sortColumnIndex == 9)
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
                              // 13. ราคาซื้อรวมภาษีมูลค่าเพิ่ม (priceIncludeTax)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(10, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'ราคาซื้อรวม\nภาษีมูลค่าเพิ่ม',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            maxLines: 2,
                                          ),
                                        ),
                                        if (sortColumnIndex == 10)
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
                              // Regular data rows - Matching PDF structure
                              ...filterList!.asMap().entries.map((entry) {
                                int index = entry.key;
                                OrderModel? item = entry.value;
                                final isCancelled = item!.status == "2";
                                final textColor = isCancelled ? Colors.red[900] : Colors.black;

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
                                        // 2. เลขที่ใบกำกับภาษี (referenceNo)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              item.referenceNo ?? '',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: textColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // 3. เลขที่ใบรับทอง (orderId)
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
                                        // 5. ชื่อผู้ขาย
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? 'ยกเลิกเอกสาร***'
                                                  : getCustomerNameForWholesaleReports(item.customer!),
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
                                        // 6. รหัสสำนักงานใหญ่/สาขา
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled ? '' : getCustomerBranchCode(item.customer!),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 7. เลขประจำตัวผู้เสียภาษี
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled ? '' : item.customer?.taxNumber ?? '',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: textColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // 8. น้ำหนักรวม (กรัม)
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(getWeight(item)),
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
                                        // 9. ราคาซื้อไม่รวมภาษีมูลค่าเพิ่ม (priceExcludeTax)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(item.priceExcludeTax ?? 0),
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
                                        // 10. มูลค่าฐานภาษียกเว้น (purchasePrice)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(item.purchasePrice ?? 0),
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
                                        // 11. ผลต่างฐานภาษี (taxBase)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(item.taxBase ?? 0),
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
                                        // 12. ภาษีมูลค่าเพิ่ม (taxAmount)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(item.taxAmount ?? 0),
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
                                        // 13. ราคาซื้อรวมภาษีมูลค่าเพิ่ม (priceIncludeTax)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(item.priceIncludeTax ?? 0),
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
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),

                              // Summary row - Matching PDF structure
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
                                      // 3. เลขที่ใบรับทอง - empty
                                      Expanded(flex: 2, child: Container()),
                                      // 4. วันที่ - empty
                                      Expanded(flex: 1, child: Container()),
                                      // 5. ชื่อผู้ขาย - empty
                                      Expanded(flex: 2, child: Container()),
                                      // 6. รหัสสาขา - empty
                                      Expanded(flex: 1, child: Container()),
                                      // 7. เลขประจำตัวผู้เสียภาษี - "รวมทั้งหมด" label
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            'รวมทั้งหมด',
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
                                      // 8. น้ำหนักรวม (กรัม)
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(getWeightTotal(filterList as dynamic)),
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
                                      // 9. ราคาซื้อไม่รวมภาษีมูลค่าเพิ่ม (priceExcludeTax)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(priceExcludeTaxTotal(filterList as dynamic)),
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
                                      // 10. มูลค่าฐานภาษียกเว้น (purchasePrice)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(purchasePriceTotal(filterList as dynamic)),
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
                                      // 11. ผลต่างฐานภาษี (taxBase)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(taxBaseTotal(filterList as dynamic)),
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
                                      // 12. ภาษีมูลค่าเพิ่ม (taxAmount)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(taxAmountTotal(filterList as dynamic)),
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
                                      // 13. ราคาซื้อรวมภาษีมูลค่าเพิ่ม (priceIncludeTax)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(priceIncludeTaxTotal(filterList as dynamic)),
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

  String _buildFilterSummary() {
    List<String> filters = [];
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      filters.add('ช่วงวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }
}