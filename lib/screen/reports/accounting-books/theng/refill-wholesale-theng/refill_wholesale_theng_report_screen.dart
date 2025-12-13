import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/refill-wholesale-theng/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/filter/compact_report_filter.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:sizer/sizer.dart';

class RefillWholesaleThengReportScreen extends StatefulWidget {
  const RefillWholesaleThengReportScreen({super.key});

  @override
  State<RefillWholesaleThengReportScreen> createState() =>
      _RefillWholesaleThengReportScreenState();
}

class _RefillWholesaleThengReportScreenState
    extends State<RefillWholesaleThengReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set default date range: 1st of current month to today
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(now);

    // Auto-load data on init
    search();
  }

  Future<void> search() async {
    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/10',
          Global.reportRequestObj({
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
      motivePrint(e.toString());
    }

    setState(() {
      loading = false;
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
                  flex: 6,
                  child: Text("สมุดบัญชีซื้อทองคำแท่งจากร้านค้าส่ง",
                      style: TextStyle(
                          fontSize: 20,
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
        if (fromDateCtrl.text.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'กรุณาเลือกจากวันที่', 'OK',
              action: () {});
          return;
        }
        if (toDateCtrl.text.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'กรุณาเลือกถึงวันที่', 'OK',
              action: () {});
          return;
        }
        if (filterList!.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK', action: () {});
          return;
        }
        List<OrderModel?> ordersToPass = filterList!.reversed.toList();

        // For type 2 (daily summary), generate daily list
        if (value == 2) {
          List<OrderModel> dailyList =
              genDailyList(filterList!.reversed.toList());
          if (dailyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK',
                action: () {});
            return;
          }
          ordersToPass = dailyList;
        }

        // For type 3 (monthly summary), generate monthly list
        if (value == 3) {
          List<OrderModel> monthlyList =
              genMonthlyList(filterList!.reversed.toList());
          if (monthlyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK',
                action: () {});
            return;
          }
          ordersToPass = monthlyList;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewRefillWholesaleThengReportPage(
              orders: ordersToPass,
              type: value,
              fromDate: DateTime.parse(fromDateCtrl.text),
              toDate: DateTime.parse(toDateCtrl.text),
              date:
                  '[${Global.formatDateNT(fromDateCtrl.text)}] ถึง [${Global.formatDateNT(toDateCtrl.text)}]',
            ),
          ),
        );
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: const Icon(Icons.print, size: 16),
            title: Text('เรียงเลขที่ใบกำกับภาษี',
                style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: const Icon(Icons.print, size: 16),
            title: Text('สรุปรายวัน', style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: ListTile(
            leading: const Icon(Icons.print, size: 16),
            title: Text('สรุปรายเดือน', style: TextStyle(fontSize: 14.sp)),
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
            const Icon(Icons.arrow_drop_down_outlined,
                color: Colors.white, size: 16),
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
      onReset: resetFilter,
      filterSummary: _buildFilterSummary(),
      initiallyExpanded: false,
      autoCollapseOnSearch: true,
    );
  }

  Widget _buildEnhancedDataTable() {
    if (filterList!.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 0),
        child: const NoDataFoundWidget(),
      );
    }

    // Calculate totals
    double totalGoldValue = 0;
    double totalCommissionPackage = 0;
    double totalVatAmount = 0;
    double totalCashBank = 0;
    for (var item in filterList!) {
      if (item?.status != "2") {
        totalGoldValue += item?.priceExcludeTax ?? 0;
        totalCommissionPackage += _getCommissionPackage(item!);
        totalVatAmount += item.taxAmount ?? 0;
        totalCashBank += item.priceIncludeTax ?? 0;
      }
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
                Icon(Icons.timeline_rounded,
                    color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รายงานสมุดบัญชีทองแท่ง (${filterList!.length} รายการ)',
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
                  minWidth: MediaQuery.of(context).size.width - 32,
                ),
                child: IntrinsicWidth(
                  child: Column(
                    children: [
                      // Sticky Header - matches PDF Type 1 structure (BUY/REFILL report)
                      Container(
                        color: Colors.grey[50],
                        height: 56,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Row number - Fixed width
                              Container(
                                width: 50,
                                padding: const EdgeInsets.all(8),
                                child: const Center(
                                  child: Text(
                                    'ลำดับ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              // Order ID (เลขที่ใบรับทอง)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Center(
                                    child: Text(
                                      'เลขที่ใบรับทอง',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              // Date (วัน/เดือน/ปี)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Center(
                                    child: Text(
                                      'วัน/เดือน/ปี',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              // Customer Name (ชื่อผู้ขาย)
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Center(
                                    child: Text(
                                      'ชื่อผู้ขาย',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              // Debit: ซื้อทองคำแท่ง
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'เดบิต:\nซื้อทองคำแท่ง',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              // Debit: ต้นทุนค่าบล็อก/ค่าบรรจุภัณฑ์
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'เดบิต:\nต้นทุนบล็อก/บรรจุ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              // Debit: ภาษีซื้อ
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'เดบิต:\nภาษีซื้อ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              // Credit: เงินสด/ธนาคาร
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'เครดิต:\nเงินสด/ธนาคาร',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Data Rows - matches PDF Type 1 structure (BUY/REFILL report)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Regular data rows
                              ...filterList!.asMap().entries.map((entry) {
                                int index = entry.key;
                                OrderModel? item = entry.value;
                                final isCancel = item?.status == "2";

                                return Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0
                                        ? Colors.grey[50]
                                        : Colors.white,
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
                                          width: 50,
                                          padding: const EdgeInsets.all(8),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isCancel ? Colors.red : Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // Order ID (เลขที่ใบรับทอง)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Center(
                                              child: Text(
                                                item?.orderId ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: isCancel ? Colors.red : Colors.blue[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Date (วัน/เดือน/ปี)
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Center(
                                              child: Text(
                                                Global.dateOnly(item!.orderDate.toString()),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isCancel ? Colors.red : null,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Customer Name (ชื่อผู้ขาย)
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancel
                                                  ? "ยกเลิกเอกสาร***"
                                                  : (item.customer != null ? getCustomerName(item.customer!) : ''),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isCancel ? Colors.red : null,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        // Debit: ซื้อทองคำแท่ง (uses priceExcludeTax to match PDF)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancel ? "0.00" : Global.format(item.priceExcludeTax ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isCancel ? Colors.red : Colors.green,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Debit: ต้นทุนค่าบล็อก/ค่าบรรจุภัณฑ์
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancel ? "0.00" : Global.format(_getCommissionPackage(item)),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isCancel ? Colors.red : Colors.blue,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Debit: ภาษีซื้อ
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancel ? "0.00" : Global.format(item.taxAmount ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isCancel ? Colors.red : Colors.teal,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Credit: เงินสด/ธนาคาร
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancel ? "0.00" : Global.format(item.priceIncludeTax ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isCancel ? Colors.red : Colors.green,
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

                              // Summary row - matches PDF Type 1
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
                                      // Empty for row number
                                      Container(width: 50, padding: const EdgeInsets.all(8)),
                                      // Empty for order ID
                                      Expanded(flex: 2, child: Container()),
                                      // Empty for date
                                      Expanded(flex: 1, child: Container()),
                                      // Total label
                                      Expanded(
                                        flex: 3,
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
                                      // Debit - Gold Value total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(totalGoldValue),
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
                                      // Debit - Commission/Package total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(totalCommissionPackage),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.blue[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Debit - VAT total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(totalVatAmount),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.teal[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Credit - Cash/Bank total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(totalCashBank),
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

  // Helper method to calculate commission + package price
  double _getCommissionPackage(OrderModel order) {
    if (order.id == null || order.details == null || order.details!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (var detail in order.details!) {
      amount += (detail.commission ?? 0) + (detail.packagePrice ?? 0);
    }
    return amount;
  }

  String _buildFilterSummary() {
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      return 'ช่วงวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}';
    }
    return 'ทั้งหมด';
  }

  List<OrderModel> genDailyList(List<OrderModel?>? filterList) {
    List<OrderModel> orderList = [];

    DateTime startDate = DateTime.parse(fromDateCtrl.text);
    DateTime endDate = DateTime.parse(toDateCtrl.text);
    int days = Global.daysBetween(startDate, endDate);

    for (int i = 0; i <= days; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));

      // Get all orders for this specific date using orderDate
      var dateList = filterList
          ?.where((element) =>
              element != null &&
              element.orderDate?.year == currentDate.year &&
              element.orderDate?.month == currentDate.month &&
              element.orderDate?.day == currentDate.day)
          .cast<OrderModel>()
          .toList();

      if (dateList != null && dateList.isNotEmpty) {
        // Create order ID from first and last order
        String combinedOrderId = dateList.length == 1
            ? dateList.first.orderId
            : '${dateList.first.orderId} - ${dateList.last.orderId.split("-").last.trim()}';

        // Calculate commission and packagePrice from all order details
        double totalCommission = 0.0;
        double totalPackagePrice = 0.0;
        for (var item in dateList) {
          if (item.details != null) {
            for (var detail in item.details!) {
              totalCommission += (detail.commission ?? 0);
              totalPackagePrice += (detail.packagePrice ?? 0);
            }
          }
        }

        // Create aggregated details with totals
        var aggregatedDetail = OrderDetailModel(
          productName: '', // Aggregated detail, no specific product
          commission: totalCommission,
          packagePrice: totalPackagePrice,
        );

        // Import the helper functions from make_pdf.dart
        var order = OrderModel(
            id: 0, // Dummy id for aggregated order
            orderId: combinedOrderId,
            orderDate: dateList.first.orderDate,
            createdDate: currentDate,
            customerId: 0,
            weight: dateList.fold<double>(
                0.0, (sum, item) => sum + (item.weight ?? 0)),
            priceIncludeTax: dateList.fold<double>(
                0.0, (sum, item) => sum + (item.priceIncludeTax ?? 0)),
            purchasePrice: dateList.fold<double>(
                0.0, (sum, item) => sum + (item.purchasePrice ?? 0)),
            priceDiff: dateList.fold<double>(
                0.0, (sum, item) => sum + (item.priceDiff ?? 0)),
            taxBase: dateList.fold<double>(
                0.0, (sum, item) => sum + (item.taxBase ?? 0)),
            taxAmount: dateList.fold<double>(
                0.0, (sum, item) => sum + (item.taxAmount ?? 0)),
            priceExcludeTax: dateList.fold<double>(
                0.0, (sum, item) => sum + (item.priceExcludeTax ?? 0)),
            details: [aggregatedDetail]);

        orderList.add(order);
      }
    }
    return orderList;
  }

  List<OrderModel> genMonthlyList(List<OrderModel?>? filterList) {
    List<OrderModel> orderList = [];

    DateTime startDate = DateTime.parse(fromDateCtrl.text);
    DateTime endDate = DateTime.parse(toDateCtrl.text);

    // Calculate months between fromDate and toDate
    int monthsDiff = ((endDate.year - startDate.year) * 12) +
        (endDate.month - startDate.month);

    for (int i = 0; i <= monthsDiff; i++) {
      // Get the first day of each month
      DateTime monthDate = DateTime(startDate.year, startDate.month + i, 1);

      // Get all orders for this specific month and year using orderDate
      var monthList = filterList
          ?.where((element) =>
              element != null &&
              element.orderDate?.year == monthDate.year &&
              element.orderDate?.month == monthDate.month)
          .cast<OrderModel>()
          .toList();

      if (monthList != null && monthList.isNotEmpty) {
        // Create order ID from first and last order of the month
        String combinedOrderId = monthList.length == 1
            ? monthList.first.orderId
            : '${monthList.first.orderId} - ${monthList.last.orderId.split("-").last.trim()}';

        // Calculate commission and packagePrice from all order details
        double totalCommission = 0.0;
        double totalPackagePrice = 0.0;
        for (var item in monthList) {
          if (item.details != null) {
            for (var detail in item.details!) {
              totalCommission += (detail.commission ?? 0);
              totalPackagePrice += (detail.packagePrice ?? 0);
            }
          }
        }

        // Create aggregated details with totals
        var aggregatedDetail = OrderDetailModel(
          productName: '', // Aggregated detail, no specific product
          commission: totalCommission,
          packagePrice: totalPackagePrice,
        );

        var order = OrderModel(
            id: 0, // Dummy id for aggregated order
            orderId: combinedOrderId,
            orderDate: monthList.first.orderDate,
            createdDate: monthDate, // First day of the month
            customerId: 0,
            weight: monthList.fold<double>(
                0.0, (sum, item) => sum + (item.weight ?? 0)),
            priceIncludeTax: monthList.fold<double>(
                0.0, (sum, item) => sum + (item.priceIncludeTax ?? 0)),
            purchasePrice: monthList.fold<double>(
                0.0, (sum, item) => sum + (item.purchasePrice ?? 0)),
            priceDiff: monthList.fold<double>(
                0.0, (sum, item) => sum + (item.priceDiff ?? 0)),
            taxBase: monthList.fold<double>(
                0.0, (sum, item) => sum + (item.taxBase ?? 0)),
            taxAmount: monthList.fold<double>(
                0.0, (sum, item) => sum + (item.taxAmount ?? 0)),
            priceExcludeTax: monthList.fold<double>(
                0.0, (sum, item) => sum + (item.priceExcludeTax ?? 0)),
            details: [aggregatedDetail]);

        orderList.add(order);
      }
    }
    return orderList;
  }

  void resetFilter() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(now);
    search();
    setState(() {});
  }
}
