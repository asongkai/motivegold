import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/sell-used-gold-reports/preview.dart';
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

class SellUsedGoldReportScreen extends StatefulWidget {
  const SellUsedGoldReportScreen({super.key});

  @override
  State<SellUsedGoldReportScreen> createState() =>
      _SellUsedGoldReportScreenState();
}

class _SellUsedGoldReportScreenState extends State<SellUsedGoldReportScreen> {
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

    // Load data with default dates
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/6',
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
                  child: Text("รายงานขายทองรูปพรรณเก่า",
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
              builder: (context) => PreviewSellUsedGoldReportPage(
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
              builder: (context) => PreviewSellUsedGoldReportPage(
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
                      // Sticky Header - Matches PDF Type 1: ลำดับ, วันที่, เลขที่ใบกำกับภาษี, เลขท่ีใบสําคัญรับเงิน, ชื่อผู้ซื้อ, รหัสสำนักงานใหญ่/สาขา, เลขประจําตัวผู้เสียภาษี, น้ําหนัก, ราคาขายรวมภาษี, มูลค่าฐานภาษียกเว้น, ผลต่างฐานภาษีต่ำกว่าราคารับซื้อ, ผลต่างฐานภาษีมูลค่าเพิ่ม, ภาษีมูลค่าเพิ่ม, ราคาขายไม่รวมภาษี
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
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // 2. วันที่
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'วันที่',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              // 3. เลขที่ใบกำกับภาษี (referenceNo)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'เลขที่\nใบกำกับภาษี',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 4. เลขท่ีใบสําคัญรับเงิน (orderId)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'เลขท่ีใบสําคัญ\nรับเงิน',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 5. ชื่อผู้ซื้อ
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'ชื่อผู้ซื้อ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 7. เลขประจําตัวผู้เสียภาษี
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'เลขประจําตัว\nผู้เสียภาษี',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 8. น้ําหนัก (กรัม)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'น้ําหนัก\n(กรัม)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 9. ราคาขายรวมภาษีมูลค่าเพิ่ม
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'ราคาขายรวม\nภาษีมูลค่าเพิ่ม',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 8),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 10. มูลค่าฐานภาษียกเว้น
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'มูลค่าฐานภาษี\nยกเว้น',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 8),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 11. ผลต่างฐานภาษีต่ำกว่าราคารับซื้อ (negative priceDiff)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'ผลต่างฐานภาษี\nต่ำกว่ารับซื้อ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 7),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 12. ผลต่างฐานภาษีมูลค่าเพิ่ม (positive priceDiff)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'ผลต่างฐาน\nภาษีมูลค่าเพิ่ม',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 7),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 13. ภาษีมูลค่าเพิ่ม
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'ภาษี\nมูลค่าเพิ่ม',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 8),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 14. ราคาขายไม่รวมภาษีมูลค่าเพิ่ม
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'ราคาขายไม่รวม\nภาษีมูลค่าเพิ่ม',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 7),
                                    overflow: TextOverflow.ellipsis,
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
                                OrderModel? item = entry.value;

                                // Check if order is cancelled (status == "2")
                                final isCancelled = item!.status == "2";
                                final textColor = isCancelled
                                    ? Colors.red[900]
                                    : Colors.black;

                                // Calculate values matching PDF logic
                                final priceDiff = item.priceDiff ?? 0;
                                final priceDiffNegative =
                                    priceDiff < 0 ? -priceDiff : 0.0;
                                final priceDiffPositive =
                                    priceDiff >= 0 ? priceDiff : 0.0;
                                final vatAmount = priceDiff < 0
                                    ? 0.0
                                    : priceDiff * getVatValue();
                                final priceExcludeVat =
                                    (item.priceIncludeTax ?? 0) - vatAmount;

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
                                        // 2. วันที่
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.dateOnly(
                                                  item.orderDate.toString()),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: textColor),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 3. เลขที่ใบกำกับภาษี (referenceNo)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              item.referenceNo ?? '',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: textColor),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // 4. เลขท่ีใบสําคัญรับเงิน (orderId)
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
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // 5. ชื่อผู้ซื้อ
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? 'ยกเลิกเอกสาร***'
                                                  : item.customer != null
                                                      ? getCustomerNameForWholesaleReports(
                                                          item.customer!)
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
                                        // 6. รหัสสำนักงานใหญ่/สาขา
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? ''
                                                  : item.customer != null
                                                      ? getCustomerBranchCode(
                                                          item.customer!)
                                                      : '',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: textColor),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // 7. เลขประจําตัวผู้เสียภาษี
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? ''
                                                  : item.customer?.taxNumber !=
                                                          ''
                                                      ? item.customer
                                                              ?.taxNumber ??
                                                          ''
                                                      : item.customer?.idCard ??
                                                          '',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: textColor),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // 8. น้ําหนัก (กรัม)
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : Global.format(
                                                      getWeight(item)),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: isCancelled
                                                    ? textColor
                                                    : Colors.orange,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 9. ราคาขายรวมภาษีมูลค่าเพิ่ม
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : Global.format(
                                                      item.priceIncludeTax ??
                                                          0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: isCancelled
                                                    ? textColor
                                                    : Colors.green,
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
                                              isCancelled
                                                  ? '0.00'
                                                  : Global.format(
                                                      item.purchasePrice ?? 0),
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
                                        // 11. ผลต่างฐานภาษีต่ำกว่าราคารับซื้อ (negative priceDiff)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : priceDiffNegative > 0
                                                      ? '(${Global.format(priceDiffNegative)})'
                                                      : '0.00',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: isCancelled
                                                    ? textColor
                                                    : priceDiffNegative > 0
                                                        ? Colors.red[900]
                                                        : textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 12. ผลต่างฐานภาษีมูลค่าเพิ่ม (positive priceDiff)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : priceDiffPositive > 0
                                                      ? Global.format(
                                                          priceDiffPositive)
                                                      : '0.00',
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
                                        // 13. ภาษีมูลค่าเพิ่ม
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : priceDiff < 0
                                                      ? '0.00'
                                                      : Global.format(
                                                          vatAmount),
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
                                        // 14. ราคาขายไม่รวมภาษีมูลค่าเพิ่ม
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              isCancelled
                                                  ? '0.00'
                                                  : Global.format(
                                                      priceExcludeVat),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: isCancelled
                                                    ? textColor
                                                    : Colors.indigo,
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

                              // Summary row - Matches PDF Type 1 structure
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
                                      // Empty cells for alignment (ลำดับ, วันที่, เลขที่ใบกำกับภาษี, เลขท่ีใบสําคัญรับเงิน, ชื่อผู้ซื้อ, รหัสสาขา)
                                      Container(
                                          width: 50,
                                          padding: const EdgeInsets.all(8)),
                                      Expanded(flex: 1, child: Container()),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 1, child: Container()),
                                      // รวมทั้งหมด label in tax number column
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
                                      // 8. Weight total
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(
                                                getWeightTotal(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                              color: Colors.orange[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 9. Price Include Tax total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(priceIncludeTaxTotal(
                                                filterList!)),
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
                                      // 10. Purchase Price total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(purchasePriceTotal(
                                                filterList!)),
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
                                      // 11. Price Diff Negative total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            '(${Global.format(priceDiffTotalM(filterList!))})',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                              color: Colors.red[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 12. Price Diff Positive total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(
                                                priceDiffTotalP(filterList!)),
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
                                      // 13. VAT Amount total
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Builder(
                                            builder: (context) {
                                              double vatTotal = 0;
                                              for (var order in filterList!) {
                                                if (order != null &&
                                                    (order.priceDiff ?? 0) >
                                                        0) {
                                                  vatTotal +=
                                                      (order.priceDiff ?? 0) *
                                                          getVatValue();
                                                }
                                              }
                                              return Text(
                                                Global.format(vatTotal),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 10,
                                                  color: Colors.indigo[700],
                                                ),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // 14. Price Exclude VAT total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Builder(
                                            builder: (context) {
                                              double total = 0;
                                              for (var order in filterList!) {
                                                if (order != null) {
                                                  double vatAmount =
                                                      (order.priceDiff ?? 0) < 0
                                                          ? 0
                                                          : (order.priceDiff ??
                                                                  0) *
                                                              getVatValue();
                                                  total +=
                                                      (order.priceIncludeTax ??
                                                              0) -
                                                          vatAmount;
                                                }
                                              }
                                              return Text(
                                                Global.format(total),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 10,
                                                  color: Colors.indigo[700],
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

      // Get all orders for this specific date (use orderDate, not createdDate)
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

        // Calculate values using the same logic as PDF display
        // taxBase = sum of abs(priceDiff) only when priceDiff < 0 (negative diff)
        // priceDiff = sum of priceDiff only when priceDiff >= 0 (positive diff)
        // taxAmount = sum of (priceDiff * vatValue) only when priceDiff >= 0
        // priceExcludeTax = sum of (priceIncludeTax - calculated VAT for each order)
        double negativePriceDiffSum = 0;
        double positivePriceDiffSum = 0;
        double vatSum = 0;
        double priceExcludeTaxSum = 0;

        for (var order in dateList) {
          if (order.status != "2") {
            // Skip cancelled orders
            double priceDiff = order.priceDiff ?? 0;
            double priceIncludeTax = order.priceIncludeTax ?? 0;

            if (priceDiff < 0) {
              negativePriceDiffSum += priceDiff.abs();
            } else {
              positivePriceDiffSum += priceDiff;
              vatSum += priceDiff * getVatValue();
            }

            // priceExcludeTax = priceIncludeTax - VAT (VAT is 0 if priceDiff < 0)
            double orderVat = priceDiff < 0 ? 0 : priceDiff * getVatValue();
            priceExcludeTaxSum += priceIncludeTax - orderVat;
          }
        }

        var order = OrderModel(
            orderId: combinedOrderId, // Combined all order IDs
            orderDate: dateList.first.orderDate,
            createdDate: monthDate,
            customerId: 0,
            weight: getWeightTotal(dateList),
            priceIncludeTax: priceIncludeTaxTotal(dateList),
            purchasePrice: purchasePriceTotal(dateList),
            priceDiff: positivePriceDiffSum, // Only positive priceDiff
            taxBase: negativePriceDiffSum, // Absolute value of negative priceDiff
            taxAmount: vatSum, // VAT calculated from positive priceDiff only
            priceExcludeTax: priceExcludeTaxSum);

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

      // Get all orders for this specific month and year (using orderDate for grouping)
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

        // Calculate values using the same logic as PDF display
        // taxBase = sum of abs(priceDiff) only when priceDiff < 0 (negative diff)
        // priceDiff = sum of priceDiff only when priceDiff >= 0 (positive diff)
        // taxAmount = sum of (priceDiff * vatValue) only when priceDiff >= 0
        // priceExcludeTax = sum of (priceIncludeTax - calculated VAT for each order)
        double negativePriceDiffSum = 0;
        double positivePriceDiffSum = 0;
        double vatSum = 0;
        double priceExcludeTaxSum = 0;

        for (var order in monthList) {
          if (order.status != "2") {
            // Skip cancelled orders
            double priceDiff = order.priceDiff ?? 0;
            double priceIncludeTax = order.priceIncludeTax ?? 0;

            if (priceDiff < 0) {
              negativePriceDiffSum += priceDiff.abs();
            } else {
              positivePriceDiffSum += priceDiff;
              vatSum += priceDiff * getVatValue();
            }

            // priceExcludeTax = priceIncludeTax - VAT (VAT is 0 if priceDiff < 0)
            double orderVat = priceDiff < 0 ? 0 : priceDiff * getVatValue();
            priceExcludeTaxSum += priceIncludeTax - orderVat;
          }
        }

        var order = OrderModel(
            orderId: combinedOrderId,
            orderDate: monthList.first.orderDate,
            createdDate: monthDate, // First day of the month
            customerId: 0,
            weight: getWeightTotal(monthList),
            priceIncludeTax: priceIncludeTaxTotal(monthList),
            purchasePrice: purchasePriceTotal(monthList),
            priceDiff: positivePriceDiffSum, // Only positive priceDiff
            taxBase: negativePriceDiffSum, // Absolute value of negative priceDiff
            taxAmount: vatSum, // VAT calculated from positive priceDiff only
            priceExcludeTax: priceExcludeTaxSum);

        orderList.add(order);
      } else {
        // Optional: Add "no sales" entry for months with no orders
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
    return orderList;
  }
}
