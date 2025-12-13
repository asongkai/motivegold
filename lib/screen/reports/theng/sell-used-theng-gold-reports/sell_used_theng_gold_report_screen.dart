import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/theng/sell-used-theng-gold-reports/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
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

class SellUsedThengGoldReportScreen extends StatefulWidget {
  const SellUsedThengGoldReportScreen({super.key});

  @override
  State<SellUsedThengGoldReportScreen> createState() =>
      _SellUsedThengGoldReportScreenState();
}

class _SellUsedThengGoldReportScreenState
    extends State<SellUsedThengGoldReportScreen> {
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

    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/11',
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
        if (products.isNotEmpty) {
          orders = products;
          filterList = products;
        } else {
          orders!.clear();
          filterList!.clear();
        }
        setState(() {});
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
                  child: Text("รายงานขายทองคำแท่งเก่า",
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
                      _buildPrintButtons(),
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
              onSearch: loadProducts,
              onReset: resetFilters,
              filterSummary: _buildFilterSummary(),
              initiallyExpanded: false,
              autoCollapseOnSearch: true,
            ),
            Expanded(
              child:
                  loading ? const LoadingProgress() : _buildEnhancedDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintButtons() {
    return PopupMenuButton<int>(
      onSelected: (int value) async {
        if (value == 1) {
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
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK',
                action: () {});
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewSellUsedThengGoldReportPage(
                orders: filterList!.reversed.toList(),
                type: 1,
                fromDate: DateTime.parse(fromDateCtrl.text),
                toDate: DateTime.parse(toDateCtrl.text),
                date:
                    '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
              ),
            ),
          );
        }

        if (value == 2) {
          DateTime now = DateTime.now();
          DateTime fromDate = DateTime(now.year, 1, 1);
          DateTime toDate = DateTime(now.year, 12, 31);

          fromDateCtrl.text = Global.formatDateDD(fromDate.toString());
          toDateCtrl.text = Global.formatDateDD(toDate.toString());

          await loadProducts();

          if (filterList!.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }

          List<OrderModel> monthlyList =
              genMonthlyList(filterList!.reversed.toList(), fromDate, toDate);
          if (monthlyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewSellUsedThengGoldReportPage(
                orders: monthlyList,
                type: value,
                fromDate: fromDate,
                toDate: toDate,
                date:
                    '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
              ),
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.print, size: 16),
            title:
                Text('เรียงเลขที่ใบกำกับภาษี', style: TextStyle(fontSize: 14)),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.print, size: 16),
            title: Text('สรุปรายเดือน', style: TextStyle(fontSize: 14)),
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
            Icon(Icons.arrow_drop_down_outlined, color: Colors.white, size: 16),
          ],
        ),
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
                Icon(Icons.timeline_rounded,
                    color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รายงานขายทองเก่า (${filterList!.length} รายการ)',
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
                      // Sticky Header - 10 columns matching PDF Type 1
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
                                child: const Text('ลำดับ',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                    textAlign: TextAlign.center),
                              ),
                              // 2. วันที่
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text('วันที่',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 3. เลขที่ใบรับซื้อ
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text('เลขที่ใบรับซื้อ',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 4. เลขที่ใบสำคัญจ่าย
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text('เลขที่ใบสำคัญจ่าย',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 5. ชื่อผู้ซื้อ
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text('ชื่อผู้ซื้อ',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 6. รหัสสำนักงานใหญ่/สาขา
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text('รหัสสำนักงานใหญ่/สาขา',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 7. เลขประจําตัวผู้เสียภาษี
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text('เลขประจําตัว\nผู้เสียภาษี',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 8. น้ำหนัก (บาท)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text('น้ำหนัก\n(บาท)',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 9. น้ำหนัก (กรัม)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text('น้ำหนัก\n(กรัม)',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 10. จำนวนเงิน (บาท)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text('จำนวนเงิน\n(บาท)',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                      textAlign: TextAlign.right),
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
                              // Regular data rows - 10 columns matching PDF Type 1
                              ...filterList!.asMap().entries.map((entry) {
                                int index = entry.key;
                                OrderModel? item = entry.value;
                                bool isCancelled = item?.status == "2";
                                Color textColor = isCancelled ? Colors.red[900]! : Colors.black87;

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
                                          child: Text('${index + 1}',
                                              style: TextStyle(fontSize: 11, color: textColor),
                                              textAlign: TextAlign.center),
                                        ),
                                        // 2. วันที่
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(Global.dateOnly(item!.orderDate.toString()),
                                                style: TextStyle(fontSize: 11, color: textColor),
                                                textAlign: TextAlign.center),
                                          ),
                                        ),
                                        // 3. เลขที่ใบรับซื้อ
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(item.referenceNo ?? '',
                                                style: TextStyle(fontSize: 11, color: textColor),
                                                textAlign: TextAlign.center),
                                          ),
                                        ),
                                        // 4. เลขที่ใบสำคัญจ่าย
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(item.orderId,
                                                style: TextStyle(fontSize: 11, color: textColor),
                                                textAlign: TextAlign.center),
                                          ),
                                        ),
                                        // 5. ชื่อผู้ซื้อ
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                                isCancelled
                                                    ? "ยกเลิกเอกสาร***"
                                                    : getCustomerNameForWholesaleReports(item.customer!),
                                                style: TextStyle(fontSize: 11, color: textColor),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                        // 6. รหัสสำนักงานใหญ่/สาขา
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                                isCancelled ? "" : getCustomerBranchCode(item.customer!),
                                                style: TextStyle(fontSize: 11, color: textColor),
                                                textAlign: TextAlign.center),
                                          ),
                                        ),
                                        // 7. เลขประจําตัวผู้เสียภาษี
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                                isCancelled
                                                    ? ""
                                                    : (item.customer?.taxNumber != ''
                                                        ? item.customer?.taxNumber ?? ''
                                                        : item.customer?.idCard ?? ''),
                                                style: TextStyle(fontSize: 10, color: textColor),
                                                textAlign: TextAlign.center),
                                          ),
                                        ),
                                        // 8. น้ำหนัก (บาท)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                                isCancelled
                                                    ? "0.00"
                                                    : Global.format(getWeight(item) / getUnitWeightValue(item.details!.first.productId)),
                                                style: TextStyle(fontSize: 11, color: textColor),
                                                textAlign: TextAlign.right),
                                          ),
                                        ),
                                        // 9. น้ำหนัก (กรัม)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                                isCancelled ? "0.00" : Global.format4(getWeight(item)),
                                                style: TextStyle(fontSize: 11, color: textColor),
                                                textAlign: TextAlign.right),
                                          ),
                                        ),
                                        // 10. จำนวนเงิน (บาท)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                                isCancelled ? "0.00" : Global.format(item.priceIncludeTax ?? 0),
                                                style: TextStyle(fontSize: 11, color: textColor),
                                                textAlign: TextAlign.right),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              // Summary row - 10 columns matching PDF Type 1
                              Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.indigo[50],
                                  border: Border(top: BorderSide(color: Colors.indigo[200]!, width: 2)),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      // 1-6 empty
                                      Container(width: 50, padding: const EdgeInsets.all(8)),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 2, child: Container()),
                                      // 7. รวมทั้งหมด label
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text('รวมทั้งหมด',
                                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.indigo[700]),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 8. น้ำหนัก (บาท) total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Builder(builder: (context) {
                                            double totalWeightBaht = 0;
                                            for (var order in filterList!) {
                                              if (order != null && order.status != "2" && order.details != null && order.details!.isNotEmpty) {
                                                totalWeightBaht += getWeight(order) / getUnitWeightValue(order.details!.first.productId);
                                              }
                                            }
                                            return Text(Global.format(totalWeightBaht),
                                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.indigo[700]),
                                                textAlign: TextAlign.right);
                                          }),
                                        ),
                                      ),
                                      // 9. น้ำหนัก (กรัม) total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Builder(builder: (context) {
                                            double totalWeightGram = 0;
                                            for (var order in filterList!) {
                                              if (order != null && order.status != "2") {
                                                totalWeightGram += getWeight(order);
                                              }
                                            }
                                            return Text(Global.format4(totalWeightGram),
                                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.indigo[700]),
                                                textAlign: TextAlign.right);
                                          }),
                                        ),
                                      ),
                                      // 10. จำนวนเงิน (บาท) total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Builder(builder: (context) {
                                            double totalAmount = 0;
                                            for (var order in filterList!) {
                                              if (order != null && order.status != "2") {
                                                totalAmount += order.priceIncludeTax ?? 0;
                                              }
                                            }
                                            return Text(Global.format(totalAmount),
                                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.indigo[700]),
                                                textAlign: TextAlign.right);
                                          }),
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
      filters.add(
          'ช่วงวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }

  List<OrderModel> genDailyList(List<OrderModel?>? filterList, {int? value}) {
    List<OrderModel> orderList = [];

    int days = Global.daysBetween(
        DateTime.parse(fromDateCtrl.text), DateTime.parse(toDateCtrl.text));

    for (int i = 0; i <= days; i++) {
      DateTime monthDate =
          DateTime.parse(fromDateCtrl.text).add(Duration(days: i));

      // Get all orders for this specific date
      var dateList = filterList
          ?.where((element) =>
              element != null &&
              Global.dateOnly(element.orderDate.toString()) ==
                  Global.dateOnly(monthDate.toString()))
          .cast<OrderModel>() // Cast to non-nullable OrderModel
          .toList();

      if (dateList != null && dateList.isNotEmpty) {
        // Create order ID from first and last order
        String combinedOrderId = dateList.length == 1
            ? dateList.first.orderId
            : '${dateList.first.orderId} - ${dateList.last.orderId}';

        var order = OrderModel(
            orderId: combinedOrderId, // Combined all order IDs
            orderDate: dateList.first.orderDate,
            createdDate: monthDate,
            customerId: 0,
            weight: getWeightTotal(dateList),
            priceIncludeTax: priceIncludeTaxTotal(dateList),
            purchasePrice: purchasePriceTotal(dateList),
            priceDiff: priceDiffTotal(dateList),
            taxBase: taxBaseTotal(dateList),
            taxAmount: taxAmountTotal(dateList),
            priceExcludeTax: priceExcludeTaxTotal(dateList));

        orderList.add(order);
      } else {
        // Optional: Add "no sales" entry for days with no orders
        if (value == 2) {
          var noSalesOrder = OrderModel(
              orderId: 'ไม่มียอดขาย',
              orderDate: monthDate,
              createdDate: monthDate,
              customerId: 0,
              weight: 0.0,
              priceIncludeTax: 0.0,
              purchasePrice: 0.0,
              priceDiff: 0.0,
              taxBase: 0.0,
              taxAmount: 0.0,
              priceExcludeTax: 0.0);

          orderList.add(noSalesOrder);
        }
      }
    }
    return orderList;
  }

  List<OrderModel> genMonthlyList(
      List<OrderModel?>? filterList, DateTime fromDate, DateTime toDate) {
    List<OrderModel> orderList = [];

    // Calculate months between fromDate and toDate
    int monthsDiff =
        ((toDate.year - fromDate.year) * 12) + (toDate.month - fromDate.month);

    for (int i = 0; i <= monthsDiff; i++) {
      // Get the first day of each month
      DateTime monthDate = DateTime(fromDate.year, fromDate.month + i, 1);

      // Get all orders for this specific month and year
      var monthList = filterList
          ?.where((element) =>
              element != null &&
              element.orderDate?.year == monthDate.year &&
              element.orderDate?.month == monthDate.month)
          .cast<OrderModel>() // Cast to non-nullable OrderModel
          .toList();

      if (monthList != null && monthList.isNotEmpty) {
        // Create order ID from first and last order of the month
        String combinedOrderId = monthList.length == 1
            ? monthList.first.orderId
            : '${monthList.first.orderId} - ${monthList.last.orderId}';

        var order = OrderModel(
            orderId: combinedOrderId,
            orderDate: monthList.first.orderDate,
            createdDate: monthDate, // First day of the month
            customerId: 0,
            weight: getWeightTotal(monthList),
            weightBath: getWeightTotal(monthList) /
                getUnitWeightValue(monthList.first.details!.first.productId),
            priceIncludeTax: priceIncludeTaxTotal(monthList),
            purchasePrice: purchasePriceTotal(monthList),
            priceDiff: priceDiffTotal(monthList),
            taxBase: taxBaseTotal(monthList),
            taxAmount: taxAmountTotal(monthList),
            priceExcludeTax: priceExcludeTaxTotal(monthList));

        orderList.add(order);
      } else {
        // Optional: Add "no sales" entry for months with no orders
        var noSalesOrder = OrderModel(
            orderId: 'ไม่มียอดขาย',
            orderDate: monthDate,
            createdDate: monthDate,
            customerId: 0,
            weight: 0.0,
            weightBath: 0.0,
            priceIncludeTax: 0.0,
            purchasePrice: 0.0,
            priceDiff: 0.0,
            taxBase: 0.0,
            taxAmount: 0.0,
            priceExcludeTax: 0.0);

        orderList.add(noSalesOrder);
      }
    }
    return orderList;
  }
}
