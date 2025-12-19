import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/theng/buy-new-theng-gold-reports/preview.dart';
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

class BuyThengReportScreen extends StatefulWidget {
  const BuyThengReportScreen({super.key});

  @override
  State<BuyThengReportScreen> createState() => _BuyThengReportScreenState();
}

class _BuyThengReportScreenState extends State<BuyThengReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;

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
    loadProducts();
  }

  void loadProducts() async {
    try {
      var result = await ApiServices.post(
          '/product/type/BAR', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post('/binlocation/all/branch',
          Global.requestObj({"branchId": Global.branch?.id}));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
        });
      } else {
        warehouseList = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> search() async {

    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/10',
          Global.reportRequestObj({
            "year": yearCtrl.text == "" ? null : yearCtrl.text,
            "month": monthCtrl.text == "" ? null : monthCtrl.text,
            "productId": selectedProduct?.id,
            "warehouseId": selectedWarehouse?.id,
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
                  child: Text("รายงานซื้อทองคำแท่ง",
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
            builder: (context) => PreviewBuyThengReportPage(
              orders: filterList!.reversed.toList(),
              type: 1,
              fromDate: DateTime.parse(fromDateCtrl.text),
              toDate: DateTime.parse(toDateCtrl.text),
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
                    'รายงานภาษีซื้อทองคำรูปพรรณใหม่ 96.5% (${filterList!.length} รายการ)',
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
                      // Sticky Header - Matches PDF Type 1: ลําดับ, เลขที่ใบกํากับภาษี, เลขที่ใบรับทอง, วันที่, ชื่อผู้ซื้อ, รหัสสำนักงานใหญ่/สาขา, เลขประจําตัวผู้เสียภาษี, น้ำหนักรวม(บาท), น้ำหนักรวม(กรัม), ฐานภาษีมูลค่ายกเว้น, ค่าบล็อกทอง, ค่าบรรจุภัณฑ์, รวมมูลค่าฐานภาษี, ภาษีมูลค่าเพิ่ม, ราคาขายรวมภาษีมูลค่าเพิ่ม
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
                                child: const Text(
                                  'ลำดับ',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // 2. เลขที่ใบกํากับภาษี (referenceNo)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'เลขที่\nใบกํากับภาษี',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 3. เลขที่ใบรับทอง (orderId)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'เลขที่\nใบรับทอง',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 4. วันที่
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'วันที่',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 5. ชื่อผู้ซื้อ
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'ชื่อผู้ซื้อ',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 6. รหัสสำนักงานใหญ่/สาขา
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'รหัส\nสาขา',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 7. เลขประจําตัวผู้เสียภาษี
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'เลขประจําตัว\nผู้เสียภาษี',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 8. น้ำหนักรวม (บาท)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'น้ำหนัก\n(บาท)',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 9. น้ำหนักรวม (กรัม)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'น้ำหนัก\n(กรัม)',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 10. ฐานภาษีมูลค่ายกเว้น (priceExcludeTax)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'ฐานภาษี\nมูลค่ายกเว้น',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 7),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 11. ค่าบล็อกทอง (commission)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'ค่าบล็อก\nทอง',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 12. ค่าบรรจุภัณฑ์ (packagePrice)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'ค่าบรรจุ\nภัณฑ์',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 13. รวมมูลค่าฐานภาษี
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'รวมมูลค่า\nฐานภาษี',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 14. ภาษีมูลค่าเพิ่ม
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'ภาษี\nมูลค่าเพิ่ม',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              // 15. ราคาขายรวมภาษีมูลค่าเพิ่ม
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'ราคาขายรวม\nภาษีมูลค่าเพิ่ม',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 7),
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
                                final textColor = isCancelled ? Colors.red[900] : Colors.black;

                                // Calculate values matching PDF logic
                                final commission = getCommissionDetailTotal(item);
                                final packagePrice = getPackagePriceDetailTotal(item);
                                final taxBase = commission + packagePrice;
                                final vatAmount = taxBase * getVatValue();

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
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                              color: textColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // 2. เลขที่ใบกํากับภาษี (referenceNo)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              item.referenceNo ?? '',
                                              style: TextStyle(fontSize: 9, color: textColor),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 3. เลขที่ใบรับทอง (orderId)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              item.orderId,
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.red[900],
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 4. วันที่
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              Global.dateOnly(item.orderDate.toString()),
                                              style: TextStyle(fontSize: 9, color: textColor),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 5. ชื่อผู้ซื้อ
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled
                                                  ? 'ยกเลิกเอกสาร***'
                                                  : item.customer != null
                                                      ? getCustomerNameForWholesaleReports(item.customer!)
                                                      : '',
                                              style: TextStyle(
                                                fontSize: 9,
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
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled
                                                  ? ''
                                                  : item.customer != null
                                                      ? getCustomerBranchCode(item.customer!)
                                                      : '',
                                              style: TextStyle(fontSize: 8, color: textColor),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 7. เลขประจําตัวผู้เสียภาษี
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled
                                                  ? ''
                                                  : item.customer?.taxNumber ?? '',
                                              style: TextStyle(fontSize: 8, color: textColor),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 8. น้ำหนักรวม (บาท)
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(getWeightBaht(item)),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 9. น้ำหนักรวม (กรัม)
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format4(getWeight(item)),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                                color: isCancelled ? textColor : Colors.orange,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 10. ฐานภาษีมูลค่ายกเว้น (priceExcludeTax)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(item.priceExcludeTax ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 11. ค่าบล็อกทอง (commission)
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(commission),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 12. ค่าบรรจุภัณฑ์ (packagePrice)
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(packagePrice),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                                color: textColor,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 13. รวมมูลค่าฐานภาษี (commission + packagePrice)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(taxBase),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                                color: isCancelled ? textColor : Colors.purple,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 14. ภาษีมูลค่าเพิ่ม
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(vatAmount),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                                color: isCancelled ? textColor : Colors.amber[700],
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // 15. ราคาขายรวมภาษีมูลค่าเพิ่ม
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(item.priceIncludeTax ?? 0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                                color: isCancelled ? textColor : Colors.green,
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
                                  border: Border(top: BorderSide(color: Colors.indigo[200]!, width: 2)),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      // Empty cells for alignment
                                      Container(width: 40, padding: const EdgeInsets.all(4)),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 1, child: Container()),
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(flex: 1, child: Container()),
                                      // รวมท้ังหมด label in tax number column
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            'รวมท้ังหมด',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                      // 8. Weight (บาท) total
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            Global.format(getWeightBahtTotal(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                      // 9. Weight (กรัม) total
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            Global.format4(getWeightTotal(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9,
                                              color: Colors.orange[700],
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                      // 10. priceExcludeTax total (ฐานภาษีมูลค่ายกเว้น)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            Global.format(priceIncludeTaxTotal(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9,
                                              color: Colors.indigo[700],
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                      // 11. Commission total (ค่าบล็อกทอง)
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Builder(
                                            builder: (context) {
                                              double total = 0;
                                              for (var order in filterList!) {
                                                if (order != null) {
                                                  total += getCommissionDetailTotal(order);
                                                }
                                              }
                                              return Text(
                                                Global.format(total),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 9,
                                                  color: Colors.indigo[700],
                                                ),
                                                textAlign: TextAlign.right,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // 12. Package price total (ค่าบรรจุภัณฑ์)
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Builder(
                                            builder: (context) {
                                              double total = 0;
                                              for (var order in filterList!) {
                                                if (order != null) {
                                                  total += getPackagePriceDetailTotal(order);
                                                }
                                              }
                                              return Text(
                                                Global.format(total),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 9,
                                                  color: Colors.indigo[700],
                                                ),
                                                textAlign: TextAlign.right,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // 13. Tax base total (รวมมูลค่าฐานภาษี)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Builder(
                                            builder: (context) {
                                              double total = 0;
                                              for (var order in filterList!) {
                                                if (order != null) {
                                                  total += getCommissionDetailTotal(order) + getPackagePriceDetailTotal(order);
                                                }
                                              }
                                              return Text(
                                                Global.format(total),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 9,
                                                  color: Colors.purple[700],
                                                ),
                                                textAlign: TextAlign.right,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // 14. VAT amount total (ภาษีมูลค่าเพิ่ม)
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Builder(
                                            builder: (context) {
                                              double total = 0;
                                              for (var order in filterList!) {
                                                if (order != null) {
                                                  double taxBase = getCommissionDetailTotal(order) + getPackagePriceDetailTotal(order);
                                                  total += taxBase * getVatValue();
                                                }
                                              }
                                              return Text(
                                                Global.format(total),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 9,
                                                  color: Colors.amber[700],
                                                ),
                                                textAlign: TextAlign.right,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // 15. Price include tax total (ราคาขายรวมภาษีมูลค่าเพิ่ม)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Builder(
                                            builder: (context) {
                                              double total = 0;
                                              for (var order in filterList!) {
                                                if (order != null) {
                                                  double priceIncludeTax = order.priceIncludeTax ?? 0;
                                                  double commission = getCommissionDetailTotal(order);
                                                  double packagePrice = getPackagePriceDetailTotal(order);
                                                  double taxBase = commission + packagePrice;
                                                  double vatAmount = taxBase * getVatValue();
                                                  total += priceIncludeTax + taxBase + vatAmount;
                                                }
                                              }
                                              return Text(
                                                Global.format(total),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 9,
                                                  color: Colors.green[700],
                                                ),
                                                textAlign: TextAlign.right,
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
      filters.add('ช่วงวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }

  List<OrderModel> genDailyList(List<OrderModel?>? filterList, {int? value}) {
    List<OrderModel> orderList = [];
    int days = Global.daysBetween(fromDate!, toDate!);

    for (int i = 0; i <= days; i++) {
      DateTime monthDate = fromDate!.add(Duration(days: i));

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

        var order = OrderModel(
          orderId: combinedOrderId,
          // Combined all order IDs
          orderDate: dateList.first.orderDate,
          createdDate: monthDate,
          customerId: 0,
          weight: getWeightTotal(dateList),
          priceIncludeTax: priceIncludeTaxTotal(dateList),
          purchasePrice: purchasePriceTotal(dateList),
          priceDiff: priceDiffTotal(dateList),
          taxBase: taxBaseTotal(dateList),
          taxAmount: taxAmountTotal(dateList),
          priceExcludeTax: priceExcludeTaxTotal(dateList),
          commissionAmount: commissionHeadTotal(dateList),
          packageAmount: packageHeadTotal(dateList),
        );

        orderList.add(order);
      } else {
        // Optional: Add "no sales" entry for days with no orders
        if (value == 2) {
          var noSalesOrder = OrderModel(
            orderId: 'ไม่มียอดซื้อ',
            orderDate: monthDate,
            createdDate: monthDate,
            customerId: 0,
            weight: 0.0,
            priceIncludeTax: 0.0,
            purchasePrice: 0.0,
            priceDiff: 0.0,
            taxBase: 0.0,
            taxAmount: 0.0,
            priceExcludeTax: 0.0,
            commissionAmount: 0.0,
            packageAmount: 0.0,
          );

          orderList.add(noSalesOrder);
        }
      }
    }
    return orderList;
  }

  List<OrderModel> genMonthlyList(List<OrderModel?>? filterList) {
    List<OrderModel> orderList = [];

    // Calculate months between fromDate and toDate
    int monthsDiff = ((toDate!.year - fromDate!.year) * 12) +
        (toDate!.month - fromDate!.month);

    for (int i = 0; i <= monthsDiff; i++) {
      // Get the first day of each month
      DateTime monthDate = DateTime(fromDate!.year, fromDate!.month + i, 1);

      // Get all orders for this specific month and year (use orderDate, not createdDate)
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
          createdDate: monthDate,
          // First day of the month
          customerId: 0,
          weight: getWeightTotal(monthList),
          priceIncludeTax: priceIncludeTaxTotal(monthList),
          purchasePrice: purchasePriceTotal(monthList),
          priceDiff: priceDiffTotal(monthList),
          taxBase: taxBaseTotal(monthList),
          taxAmount: taxAmountTotal(monthList),
          priceExcludeTax: priceExcludeTaxTotal(monthList),
          commissionAmount: commissionHeadTotal(monthList),
          packageAmount: packageHeadTotal(monthList),
        );

        orderList.add(order);
      } else {
        // Optional: Add "no sales" entry for months with no orders
        var noSalesOrder = OrderModel(
          orderId: 'ไม่มียอดซื้อ',
          orderDate: monthDate,
          createdDate: monthDate,
          customerId: 0,
          weight: 0.0,
          priceIncludeTax: 0.0,
          purchasePrice: 0.0,
          priceDiff: 0.0,
          taxBase: 0.0,
          taxAmount: 0.0,
          priceExcludeTax: 0.0,
          commissionAmount: 0.0,
          packageAmount: 0.0,
        );

        orderList.add(noSalesOrder);
      }
    }
    return orderList;
  }

  void resetFilter() {
    yearNotifier = ValueNotifier<dynamic>("");
    monthNotifier = ValueNotifier<dynamic>("");
    fromDateNotifier = ValueNotifier<dynamic>("");
    toDateNotifier = ValueNotifier<dynamic>("");
    yearCtrl.text = "";
    monthCtrl.text = "";

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
    setState(() {});
    loadProducts();
    search();
  }
}
