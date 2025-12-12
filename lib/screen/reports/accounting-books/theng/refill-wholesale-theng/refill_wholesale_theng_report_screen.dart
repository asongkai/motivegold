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
    double totalWeight = 0;
    double totalAmount = 0;
    for (var item in filterList!) {
      totalWeight += getWeight(item);
      totalAmount += item?.priceIncludeTax ?? 0;
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
                      // Sticky Header
                      Container(
                        color: Colors.grey[50],
                        height: 56,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Row number - Fixed width
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
                              // Date
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'วันที่',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Invoice number
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.receipt_rounded,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'เลขที่ใบกํากับภาษี',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Weight
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.scale_rounded,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'น้ำหนัก (กรัม)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Amount
                              Expanded(
                                flex: 2,
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
                                          'จำนวนเงิน',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11),
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
                              // Regular data rows
                              ...filterList!.asMap().entries.map((entry) {
                                int index = entry.key;
                                OrderModel? item = entry.value;

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
                                          width: 60,
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                              Global.dateOnly(
                                                  item!.orderDate.toString()),
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Invoice number
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.orderId ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Colors.blue[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Weight
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format4(getWeight(item)),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: Colors.orange,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Amount
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(
                                                  item.priceIncludeTax ?? 0),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
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

                              // Summary row
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
                                      Container(
                                          width: 60,
                                          padding: const EdgeInsets.all(8)),
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
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Weight total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format4(totalWeight),
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
                                      // Amount total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(totalAmount),
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
