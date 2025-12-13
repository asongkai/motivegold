import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/theng/sell-new-theng-gold-reports/preview.dart';
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

class SellThengReportScreen extends StatefulWidget {
  const SellThengReportScreen({super.key});

  @override
  State<SellThengReportScreen> createState() =>
      _SellThengReportScreenState();
}

class _SellThengReportScreenState extends State<SellThengReportScreen> {
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
      var result =
          await ApiServices.post('/product/type/BAR', Global.requestObj(null));
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
          '/order/all/type/4',
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
                  child: Text("รายงานขายทองคำแท่ง",
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
            builder: (context) => PreviewSellThengReportPage(
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
                Icon(Icons.timeline_rounded,
                    color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รายงานขายทองคำแท่ง (${filterList!.length} รายการ)',
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
                      // Sticky Header - Matches PDF Type 1: ลําดับ, เลขที่ใบกํากับภาษี, วันที่, ชื่อผู้ซื้อ, เลขประจำตัวผู้เสียภาษี, น้ำหนักรวม(บาท), น้ำหนักรวม(กรัม), ฐานภาษีมูลค่ายกเว้น, ค่าบล็อกทอง, ค่าบรรจุภัณฑ์, รวมมูลค่าฐานภาษี, ภาษีมูลค่าเพิ่ม, ราคาขายรวมภาษีมูลค่าเพิ่ม
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
                              // 2. เลขที่ใบกํากับภาษี (orderId)
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
                              // 3. วันที่
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
                              // 4. ชื่อผู้ซื้อ
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
                              // 5. เลขประจําตัวผู้เสียภาษี
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
                              // 6. น้ำหนักรวม (บาท)
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
                              // 7. น้ำหนักรวม (กรัม)
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
                              // 8. ฐานภาษีมูลค่ายกเว้น (priceIncludeTax)
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
                              // 9. ค่าบล็อกทอง (commission)
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
                              // 10. ค่าบรรจุภัณฑ์ (packagePrice)
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
                              // 11. รวมมูลค่าฐานภาษี
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
                              // 12. ภาษีมูลค่าเพิ่ม
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
                              // 13. ราคาขายรวมภาษีมูลค่าเพิ่ม
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
                                        // 2. เลขที่ใบกํากับภาษี (orderId)
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
                                        // 3. วันที่
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
                                        // 4. ชื่อผู้ซื้อ
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled
                                                  ? 'ยกเลิกเอกสาร***'
                                                  : item.customer != null
                                                      ? getCustomerName(item.customer!)
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
                                        // 5. เลขประจําตัวผู้เสียภาษี
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
                                        // 6. น้ำหนักรวม (บาท)
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
                                        // 7. น้ำหนักรวม (กรัม)
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
                                        // 8. ฐานภาษีมูลค่ายกเว้น (priceIncludeTax)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format(item.priceIncludeTax ?? 0),
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
                                        // 9. ค่าบล็อกทอง (commission)
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
                                        // 10. ค่าบรรจุภัณฑ์ (packagePrice)
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
                                        // 11. รวมมูลค่าฐานภาษี (commission + packagePrice)
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
                                        // 12. ภาษีมูลค่าเพิ่ม
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
                                        // 13. ราคาขายรวมภาษีมูลค่าเพิ่ม
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              isCancelled ? '0.00' : Global.format((item.priceIncludeTax ?? 0) + taxBase + vatAmount),
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
                              }),

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
                                      Expanded(flex: 1, child: Container()),
                                      Expanded(flex: 2, child: Container()),
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
                                      // 6. Weight (บาท) total
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
                                      // 7. Weight (กรัม) total
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
                                      // 8. priceIncludeTax total (ฐานภาษีมูลค่ายกเว้น)
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
                                      // 9. Commission total (ค่าบล็อกทอง)
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
                                      // 10. Package price total (ค่าบรรจุภัณฑ์)
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
                                      // 11. Tax base total (รวมมูลค่าฐานภาษี)
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
                                      // 12. VAT amount total (ภาษีมูลค่าเพิ่ม)
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
                                      // 13. Price include tax total (ราคาขายรวมภาษีมูลค่าเพิ่ม)
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
