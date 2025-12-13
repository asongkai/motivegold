import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/theng/theng-money-movement-reports/preview.dart';
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

class ThengMoneyMovementReportScreen extends StatefulWidget {
  const ThengMoneyMovementReportScreen({super.key});

  @override
  State<ThengMoneyMovementReportScreen> createState() =>
      _ThengMoneyMovementReportScreenState();
}

class _ThengMoneyMovementReportScreenState extends State<ThengMoneyMovementReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel>? filterList = [];
  Screen? size;

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
          '/order/all/theng-money-movement',
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
      // motivePrint(result?.toJson());
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
                  child: Text("รายงานเส้นทางการเงินทองคำแท่ง",
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
            builder: (context) => PreviewThengMoneyMovementReportPage(
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
                      // Sticky Header - 17 columns matching PDF
                      Container(
                        color: Colors.grey[50],
                        height: 56,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // 1. ลำดับ
                              Container(
                                width: 40,
                                padding: const EdgeInsets.all(4),
                                child: const Text('ลำดับ',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.center),
                              ),
                              // 2. เลขที่ใบกํากับภาษี
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('เลขที่\nใบกํากับภาษี',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 3. ชื่อลูกค้า
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('ชื่อลูกค้า',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 4. วันที่
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('วันที่',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 5. นน.ทองคำแท่งขายออก (กรัม)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('นน.ขายออก\n(กรัม)',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 6. นน.ทองคำแท่งรับซื้อ (กรัม)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('นน.รับซื้อ\n(กรัม)',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 7. จำนวนเงินสุทธิ (บาท)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('จำนวนเงิน\nสุทธิ (บาท)',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 8. เลขที่อ้างอิง
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('เลขที่อ้างอิง',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 9. ร้านทองรับ/จ่ายเงิน
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('ร้านทอง\nรับ/จ่ายเงิน',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              // 10. ยอดรับเงิน
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('ยอด\nรับเงิน',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 11. ยอดจ่ายเงิน
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('ยอด\nจ่ายเงิน',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 12. ร้านทองรับ(จ่าย)เงินสุทธิ
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('รับ(จ่าย)\nเงินสุทธิ',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 13. ร้านทองเพิ่ม/ลดให้
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('เพิ่ม/\nลดให้',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 14. เงินสดรับ(จ่าย)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('เงินสด',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 15. เงินโอน/ฝากธนาคาร
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('เงินโอน',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 16. บัตรเครดิต
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('บัตร\nเครดิต',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                              // 17. อื่นๆ
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text('อื่นๆ',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                      textAlign: TextAlign.right),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Data Rows - 17 columns matching PDF
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: filterList!.asMap().entries.map((entry) {
                              int index = entry.key;
                              OrderModel item = entry.value;

                              // Calculate values matching PDF logic
                              double weightSellOut = (item.orderTypeId == 4) ? getWeight(item) : 0;
                              double weightBuyIn = (item.orderTypeId == 44) ? getWeight(item) : 0;
                              double netAmount = item.priceIncludeTax ?? 0;
                              String netAmountStr = (item.orderTypeId == 44)
                                  ? '(${Global.format(netAmount)})'
                                  : Global.format(netAmount);

                              // Reference number from paired order
                              String refNo = _getReferenceNumber(filterList!, item);

                              // Pay to customer or shop value
                              double payValue = _payToCustomerOrShopValue(filterList!, item);
                              String payTitle = Global.getPayTittle(payValue);

                              // Receive/Pay amounts
                              String receiveAmount = (item.orderTypeId == 4) ? Global.format(netAmount) : "";
                              String payAmount = (item.orderTypeId == 44) ? '(${Global.format(netAmount)})' : "";

                              // Net receive/pay
                              String netReceivePay = payValue > 0
                                  ? Global.format(payValue)
                                  : '(${Global.format(-payValue)})';

                              // Discount/Add price
                              double addDis = _addDisValue(item.discount ?? 0, item.addPrice ?? 0);
                              String addDisStr = addDis == 0 ? "" : (item.orderTypeId == 4)
                                  ? (addDis < 0 ? "(${Global.format(-addDis)})" : Global.format(addDis))
                                  : "";

                              // Payment methods
                              double cashPay = _getCashPayment(filterList!, item);
                              double transferPay = _getTransferPayment(filterList!, item);
                              double creditPay = _getCreditPayment(filterList!, item);
                              double otherPay = _getOtherPayment(filterList!, item);

                              String cashStr = cashPay == 0 ? "" : (item.orderTypeId == 4)
                                  ? Global.format(cashPay)
                                  : '(${Global.format(cashPay)})';
                              String transferStr = transferPay == 0 ? "" : (item.orderTypeId == 4)
                                  ? Global.format(transferPay)
                                  : '(${Global.format(transferPay)})';
                              String creditStr = creditPay == 0 ? "" : (item.orderTypeId == 4)
                                  ? Global.format(creditPay)
                                  : '(${Global.format(creditPay)})';
                              String otherStr = otherPay == 0 ? "" : (item.orderTypeId == 4)
                                  ? Global.format(otherPay)
                                  : '(${Global.format(otherPay)})';

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
                                        width: 40,
                                        padding: const EdgeInsets.all(4),
                                        child: Text('${index + 1}',
                                            style: const TextStyle(fontSize: 9),
                                            textAlign: TextAlign.center),
                                      ),
                                      // 2. เลขที่ใบกํากับภาษี
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(item.orderId,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      // 3. ชื่อลูกค้า
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(getCustomerName(item.customer!),
                                              style: const TextStyle(fontSize: 8),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      // 4. วันที่
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(Global.dateOnly(item.orderDate.toString()),
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                      // 5. นน.ขายออก (กรัม)
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(weightSellOut > 0 ? Global.format4(weightSellOut) : "",
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 6. นน.รับซื้อ (กรัม)
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(weightBuyIn > 0 ? Global.format4(weightBuyIn) : "",
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 7. จำนวนเงินสุทธิ (บาท)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(netAmountStr,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 8. เลขที่อ้างอิง
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(refNo,
                                              style: const TextStyle(fontSize: 8),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      // 9. ร้านทองรับ/จ่ายเงิน
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(payTitle,
                                              style: const TextStyle(fontSize: 8)),
                                        ),
                                      ),
                                      // 10. ยอดรับเงิน
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(receiveAmount,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 11. ยอดจ่ายเงิน
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(payAmount,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 12. รับ(จ่าย)เงินสุทธิ
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(netReceivePay,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 13. เพิ่ม/ลดให้
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(addDisStr,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 14. เงินสด
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(cashStr,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 15. เงินโอน
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(transferStr,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 16. บัตรเครดิต
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(creditStr,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                      // 17. อื่นๆ
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(otherStr,
                                              style: const TextStyle(fontSize: 8),
                                              textAlign: TextAlign.right),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Summary Footer
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
                  'น้ำหนักรวม: ${Global.format(filterList!.fold(0.0, (sum, item) => sum + getWeight(item)))} กรัม',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'มูลค่ารวม: ${Global.format(filterList!.fold(0.0, (sum, item) => sum + (item.priceIncludeTax ?? 0)))}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
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

  // Helper methods matching PDF logic
  String _getReferenceNumber(List<OrderModel> orders, OrderModel order) {
    var pairedOrders = orders
        .where((e) => e.pairId == order.pairId && e.orderId != order.orderId)
        .toList();
    if (pairedOrders.isNotEmpty) {
      return pairedOrders.first.orderId;
    }
    return "";
  }

  double _payToCustomerOrShopValue(List<OrderModel> orders, OrderModel order) {
    var pairedOrders = orders
        .where((e) => e.pairId == order.pairId && e.orderId != order.orderId)
        .toList();
    double buy = 0;
    double sell = 0;
    if (pairedOrders.isNotEmpty) {
      pairedOrders.add(order);
      for (var o in pairedOrders) {
        for (var d in o.details!) {
          int type = o.orderTypeId!;
          double price = d.priceIncludeTax!;
          if (type == 2 || type == 44) {
            buy += -price;
          }
          if (type == 1 || type == 4) {
            sell += price;
          }
        }
      }
      double discount = order.discount ?? 0;
      double amount = sell + buy;
      amount = amount < 0 ? -amount : amount;
      amount = discount != 0 ? amount - discount : amount;
      amount = (sell + buy) < 0 ? -amount : amount;
      return amount;
    }
    return order.priceIncludeTax ?? 0;
  }

  double _addDisValue(double discount, double addPrice) {
    return addPrice - discount;
  }

  double _getCashPayment(List<OrderModel> orders, OrderModel order) {
    if (_payToCustomerOrShopValue(orders, order) > 0) {
      if (order.orderTypeId == 4) {
        return order.cashPayment ?? 0;
      }
      return 0;
    } else {
      if (order.orderTypeId == 44) {
        return order.cashPayment ?? 0;
      }
      return 0;
    }
  }

  double _getTransferPayment(List<OrderModel> orders, OrderModel order) {
    if (_payToCustomerOrShopValue(orders, order) > 0) {
      if (order.orderTypeId == 4) {
        return (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
      }
      return 0;
    } else {
      if (order.orderTypeId == 44) {
        return (order.transferPayment ?? 0) + (order.depositPayment ?? 0);
      }
      return 0;
    }
  }

  double _getCreditPayment(List<OrderModel> orders, OrderModel order) {
    if (_payToCustomerOrShopValue(orders, order) > 0) {
      if (order.orderTypeId == 4) {
        return order.creditPayment ?? 0;
      }
      return 0;
    } else {
      if (order.orderTypeId == 44) {
        return order.creditPayment ?? 0;
      }
      return 0;
    }
  }

  double _getOtherPayment(List<OrderModel> orders, OrderModel order) {
    if (_payToCustomerOrShopValue(orders, order) > 0) {
      if (order.orderTypeId == 4) {
        return order.otherPayment ?? 0;
      }
      return 0;
    } else {
      if (order.orderTypeId == 44) {
        return order.otherPayment ?? 0;
      }
      return 0;
    }
  }
}