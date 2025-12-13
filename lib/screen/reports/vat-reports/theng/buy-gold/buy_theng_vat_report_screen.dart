import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/vat-reports/theng/buy-gold/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/filter/compact_report_filter.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

// Simple class for Thai month
class ThaiMonth {
  final int value;
  final String name;

  ThaiMonth(this.value, this.name);

  @override
  String toString() => name;

  Map<String, dynamic> toJson() => {'value': value, 'name': name};
}

class BuyThengVatReportScreen extends StatefulWidget {
  const BuyThengVatReportScreen({super.key});

  @override
  State<BuyThengVatReportScreen> createState() =>
      _BuyThengVatReportScreenState();
}

class _BuyThengVatReportScreenState extends State<BuyThengVatReportScreen> {
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
  DateTime? fromDate;
  DateTime? toDate;

  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  late List<ThaiMonth> thaiMonths;

  @override
  void initState() {
    super.initState();

    // Initialize Thai months list
    thaiMonths = [
      ThaiMonth(1, 'มกราคม'),
      ThaiMonth(2, 'กุมภาพันธ์'),
      ThaiMonth(3, 'มีนาคม'),
      ThaiMonth(4, 'เมษายน'),
      ThaiMonth(5, 'พฤษภาคม'),
      ThaiMonth(6, 'มิถุนายน'),
      ThaiMonth(7, 'กรกฎาคม'),
      ThaiMonth(8, 'สิงหาคม'),
      ThaiMonth(9, 'กันยายน'),
      ThaiMonth(10, 'ตุลาคม'),
      ThaiMonth(11, 'พฤศจิกายน'),
      ThaiMonth(12, 'ธันวาคม'),
    ];

    yearNotifier = ValueNotifier<dynamic>(null);
    monthNotifier = ValueNotifier<dynamic>(null);
    productNotifier = ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));

    // Set default date range: 1st of current month to today
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    fromDateCtrl.text = firstDayOfMonth.toString().split(' ')[0];
    toDateCtrl.text = now.toString().split(' ')[0];

    loadProducts();
    // Load data with default dates
    search();
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
    // Parse dates from text controllers
    if (fromDateCtrl.text.isNotEmpty) {
      fromDate = DateTime.parse(fromDateCtrl.text);
    } else {
      fromDate = null;
    }

    if (toDateCtrl.text.isNotEmpty) {
      toDate = DateTime.parse(toDateCtrl.text);
    } else {
      toDate = null;
    }

    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/10',
          Global.reportRequestObj({
            "year": yearCtrl.text == "" ? 0 : yearCtrl.text,
            "month": monthCtrl.text == "" ? 0 : monthCtrl.text,
            "productId": selectedProduct?.id,
            "warehouseId": selectedWarehouse?.id,
            "fromDate": fromDate?.toString(),
            "toDate": toDate?.toString(),
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
                  child: Text("รายงานภาษีซื้อทองคำแท่ง",
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
          if (filterList!.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }

          // Set default dates to current month if not set
          DateTime printFromDate;
          DateTime printToDate;
          if (fromDate == null || toDate == null) {
            DateTime now = DateTime.now();
            printFromDate = DateTime(now.year, now.month, 1);
            printToDate = DateTime(now.year, now.month + 1, 0);
          } else {
            printFromDate = fromDate!;
            printToDate = toDate!;
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewBuyThengVatReportPage(
                orders: filterList!.reversed.toList(),
                type: 1,
                fromDate: printFromDate,
                toDate: printToDate,
                date:
                    '${Global.formatDateNT(printFromDate.toString())} - ${Global.formatDateNT(printToDate.toString())}',
              ),
            ),
          );
        }

        if (value == 4) {
          if (filterList!.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }

          // Use the actual selected date range for the monthly summary
          // This ensures the report only includes the months within the search criteria
          DateTime printFromDate;
          DateTime printToDate;
          if (fromDate == null || toDate == null) {
            // If no date range selected, default to current year
            DateTime now = DateTime.now();
            printFromDate = DateTime(now.year, 1, 1);
            printToDate = DateTime(now.year, 12, 31);
          } else {
            printFromDate = fromDate!;
            printToDate = toDate!;
          }

          // Temporarily set the date range for genMonthlyList to use
          // genMonthlyList uses instance variables fromDate/toDate to determine month range
          DateTime? savedFromDate = fromDate;
          DateTime? savedToDate = toDate;
          fromDate = printFromDate;
          toDate = printToDate;

          List<OrderModel> monthlyList =
              genMonthlyList(filterList!.reversed.toList());

          // Restore original dates
          fromDate = savedFromDate;
          toDate = savedToDate;

          if (monthlyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewBuyThengVatReportPage(
                orders: monthlyList,
                type: 4,
                fromDate: printFromDate,
                toDate: printToDate,
                date:
                    '${Global.formatDateNT(printFromDate.toString())} - ${Global.formatDateNT(printToDate.toString())}',
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
          value: 4,
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
      onSearch: search,
      onReset: resetFilter,
      filterSummary: _buildFilterSummary(),
      initiallyExpanded: false,
      autoCollapseOnSearch: true,
      additionalFilters: [
        // Product and Warehouse row
        Row(
          children: [
            Expanded(
              child: _buildCompactDropdownField(
                label: 'สินค้า',
                icon: Icons.inventory_2_rounded,
                notifier: productNotifier!,
                items: productList,
                onChanged: (ProductModel value) {
                  selectedProduct = value;
                  productNotifier!.value = value;
                  search();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactDropdownField(
                label: 'คลังสินค้า',
                icon: Icons.warehouse_rounded,
                notifier: warehouseNotifier!,
                items: warehouseList,
                onChanged: (WarehouseModel value) {
                  selectedWarehouse = value;
                  warehouseNotifier!.value = value;
                  search();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Month and Year row
        Row(
          children: [
            Expanded(
              child: _buildCompactDropdownField<ThaiMonth>(
                label: 'เดือน',
                icon: Icons.calendar_month,
                notifier: monthNotifier!,
                items: thaiMonths,
                onChanged: (ThaiMonth value) {
                  setState(() {
                    monthCtrl.text = value.value.toString();
                    monthNotifier!.value = value;

                    // Set date range to selected month
                    int year = yearCtrl.text.isEmpty
                        ? DateTime.now().year
                        : int.parse(yearCtrl.text);
                    DateTime firstDay = DateTime(year, value.value, 1);
                    DateTime lastDay = DateTime(year, value.value + 1, 0);

                    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDay);
                    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(lastDay);
                  });
                  search();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactDropdownField<int>(
                label: 'ปี',
                icon: Icons.date_range,
                notifier: yearNotifier!,
                items: Global.genYear(),
                onChanged: (int value) {
                  setState(() {
                    yearCtrl.text = value.toString();
                    yearNotifier!.value = value;

                    // Set date range to selected year
                    DateTime firstDay = DateTime(value, 1, 1);
                    DateTime lastDay = DateTime(value, 12, 31);

                    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDay);
                    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(lastDay);

                    // Clear month selection when year changes
                    monthCtrl.text = "";
                    monthNotifier!.value = null;
                  });
                  search();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactDropdownField<T>({
    required String label,
    required IconData icon,
    required ValueNotifier notifier,
    required List<T> items,
    required Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: MiraiDropDownMenu<T>(
            key: UniqueKey(),
            children: items,
            space: 4,
            maxHeight: 300,
            showSearchTextField: true,
            selectedItemBackgroundColor: Colors.transparent,
            emptyListMessage: 'ไม่มีข้อมูล',
            showSelectedItemBackgroundColor: true,
            itemWidgetBuilder: (int index, T? project,
                {bool isItemSelected = false}) {
              return DropDownItemWidget(
                project: project,
                isItemSelected: isItemSelected,
                firstSpace: 8,
                fontSize: 14.sp,
              );
            },
            onChanged: onChanged,
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 14.sp,
              projectValueNotifier: notifier,
            ),
          ),
        ),
      ],
    );
  }

  String _buildFilterSummary() {
    List<String> filters = [];
    if (monthNotifier?.value != null && monthNotifier?.value is ThaiMonth) {
      ThaiMonth month = monthNotifier!.value as ThaiMonth;
      filters.add('เดือน: ${month.name}');
    }
    if (yearCtrl.text.isNotEmpty) {
      filters.add('ปี: ${yearCtrl.text}');
    }
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      filters.add(
          'วันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }

  void resetFilter() {
    yearNotifier?.value = null;
    monthNotifier?.value = null;
    yearCtrl.text = "";
    monthCtrl.text = "";

    // Set default date range: 1st of current month to today
    DateTime now = DateTime.now();
    fromDate = DateTime(now.year, now.month, 1);
    toDate = now;
    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(fromDate!);
    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(toDate!);

    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    search();
    setState(() {});
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
                    'รายงานภาษีซื้อทองคำรูปพรรณใหม่ 96.5% (${filterList!.length} รายการ)',
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
                      // Sticky Header - 15 columns matching PDF Type 1
                      Container(
                        color: Colors.grey[50],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            // 1. ลำดับ
                            Container(
                              width: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: const Text('ลำดับ',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                  textAlign: TextAlign.center),
                            ),
                            // 2. เลขที่ใบกํากับภาษี
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('เลขที่ใบกํากับภาษี',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            // 3. เลขที่ใบรับทอง
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('เลขที่ใบรับทอง',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            // 4. วันที่
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('วันที่',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            // 5. ชื่อผู้ซื้อ
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('ชื่อผู้ซื้อ',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            // 6. รหัสสำนักงานใหญ่/สาขา
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('รหัสสำนักงาน\nใหญ่/สาขา',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            // 7. เลขประจําตัวผู้เสียภาษี
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('เลขประจําตัว\nผู้เสียภาษี',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            // 8. น้ำหนักรวม (บาท)
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('น้ำหนักรวม\n(บาท)',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                            // 9. น้ำหนักรวม (กรัม)
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('น้ำหนักรวม\n(กรัม)',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                            // 10. ฐานภาษีมูลค่ายกเว้น
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('ฐานภาษีมูลค่า\nยกเว้น',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                            // 11. ค่าบล็อกทอง
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('ค่าบล็อกทอง',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                            // 12. ค่าบรรจุภัณฑ์
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('ค่าบรรจุภัณฑ์',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                            // 13. รวมมูลค่าฐานภาษี
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('รวมมูลค่า\nฐานภาษี',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                            // 14. ภาษีมูลค่าเพิ่ม
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('ภาษีมูลค่าเพิ่ม',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                            // 15. ราคาขายรวมภาษีมูลค่าเพิ่ม
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('ราคาขายรวม\nภาษีมูลค่าเพิ่ม',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Data Rows - 15 columns matching PDF Type 1
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Regular data rows
                              ...filterList!.asMap().entries.map((entry) {
                                int index = entry.key;
                                OrderModel? item = entry.value;
                                bool isCancelled = item!.status == "2";
                                Color? textColor = isCancelled ? Colors.red[900] : null;

                                // Calculate values for display
                                double commission = getCommissionDetailTotal(item);
                                double packagePrice = getPackagePriceDetailTotal(item);
                                double taxBase = commission + packagePrice;
                                double vatAmount = taxBase * getVatValue();

                                return Container(
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0
                                        ? Colors.grey[50]
                                        : Colors.white,
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[200]!,
                                            width: 0.5)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      // 1. ลำดับ
                                      Container(
                                        width: 50,
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(fontSize: 10, color: textColor),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // 2. เลขที่ใบกํากับภาษี
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            item.referenceNo ?? '',
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 3. เลขที่ใบรับทอง
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            item.orderId,
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 4. วันที่
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            Global.dateOnly(item.orderDate.toString()),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 5. ชื่อผู้ซื้อ
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled
                                                ? 'ยกเลิกเอกสาร***'
                                                : getCustomerNameForWholesaleReports(item.customer!),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 6. รหัสสำนักงานใหญ่/สาขา
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '' : getCustomerBranchCode(item.customer!),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 7. เลขประจําตัวผู้เสียภาษี
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '' : (item.customer?.taxNumber ?? ''),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 8. น้ำหนักรวม (บาท)
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '0.00' : Global.format(getWeightBaht(item)),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 9. น้ำหนักรวม (กรัม)
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '0.00' : Global.format4(getWeight(item)),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 10. ฐานภาษีมูลค่ายกเว้น
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '0.00' : Global.format(item.priceExcludeTax ?? 0),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 11. ค่าบล็อกทอง
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '0.00' : Global.format(commission),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 12. ค่าบรรจุภัณฑ์
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '0.00' : Global.format(packagePrice),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 13. รวมมูลค่าฐานภาษี
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '0.00' : Global.format(taxBase),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 14. ภาษีมูลค่าเพิ่ม
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '0.00' : Global.format(vatAmount),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // 15. ราคาขายรวมภาษีมูลค่าเพิ่ม
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            isCancelled ? '0.00' : Global.format(item.priceIncludeTax ?? 0),
                                            style: TextStyle(fontSize: 10, color: textColor),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              // Summary row - 15 columns matching PDF Type 1
                              Builder(
                                builder: (context) {
                                  // Calculate totals
                                  double totalWeightBaht = getWeightBahtTotal(filterList!);
                                  double totalWeightGram = getWeightTotal(filterList!);
                                  double totalPriceExcludeTax = priceExcludeTaxTotal(filterList!);
                                  double totalCommission = filterList!.fold<double>(
                                      0.0, (sum, order) => sum + getCommissionDetailTotal(order));
                                  double totalPackagePrice = filterList!.fold<double>(
                                      0.0, (sum, order) => sum + getPackagePriceDetailTotal(order));
                                  double totalTaxBase = totalCommission + totalPackagePrice;
                                  double totalVatAmount = totalTaxBase * getVatValue();
                                  double totalPriceIncludeTax = priceIncludeTaxTotal(filterList!);

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.indigo[50],
                                      border: Border(
                                          top: BorderSide(
                                              color: Colors.indigo[200]!,
                                              width: 2)),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      children: [
                                        // 1. Empty for ลำดับ
                                        Container(width: 50, padding: const EdgeInsets.symmetric(horizontal: 4)),
                                        // 2. Empty for เลขที่ใบกํากับภาษี
                                        Expanded(flex: 2, child: Container()),
                                        // 3. Empty for เลขที่ใบรับทอง
                                        Expanded(flex: 2, child: Container()),
                                        // 4. Empty for วันที่
                                        Expanded(flex: 1, child: Container()),
                                        // 5. Empty for ชื่อผู้ซื้อ
                                        Expanded(flex: 2, child: Container()),
                                        // 6. Empty for รหัสสำนักงานใหญ่/สาขา
                                        Expanded(flex: 1, child: Container()),
                                        // 7. รวมท้ังหมด label (in tax number column)
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              'รวมท้ังหมด',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.indigo[700],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        // 8. น้ำหนักรวม (บาท)
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              Global.format(totalWeightBaht),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.indigo[700],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        // 9. น้ำหนักรวม (กรัม)
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              Global.format4(totalWeightGram),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.indigo[700],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        // 10. ฐานภาษีมูลค่ายกเว้น
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              Global.format(totalPriceExcludeTax),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.indigo[700],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        // 11. ค่าบล็อกทอง
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              Global.format(totalCommission),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.indigo[700],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        // 12. ค่าบรรจุภัณฑ์
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              Global.format(totalPackagePrice),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.indigo[700],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        // 13. รวมมูลค่าฐานภาษี
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              Global.format(totalTaxBase),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.indigo[700],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        // 14. ภาษีมูลค่าเพิ่ม
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              Global.format(totalVatAmount),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.indigo[700],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        // 15. ราคาขายรวมภาษีมูลค่าเพิ่ม
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              Global.format(totalPriceIncludeTax),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.indigo[700],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

  List<OrderModel> genDailyList(List<OrderModel?>? filterList, {int? value}) {
    List<OrderModel> orderList = [];
    int days = Global.daysBetween(fromDate!, toDate!);

    for (int i = 0; i <= days; i++) {
      DateTime monthDate = fromDate!.add(Duration(days: i));

      // Get all orders for this specific date
      var dateList = filterList
          ?.where((element) =>
              element != null &&
              Global.dateOnly(element.createdDate.toString()) ==
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
          commissionAmount: dateList.fold<double>(
              0.0, (sum, order) => sum + getCommissionDetailTotal(order)),
          packageAmount: dateList.fold<double>(
              0.0, (sum, order) => sum + getPackagePriceDetailTotal(order)),
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
          createdDate: monthDate,
          // First day of the month
          customerId: 0,
          weight: getWeightTotal(monthList),
          weightBath: getWeightBahtTotal(monthList),
          // weightBath: getWeightTotal(monthList) /
          //     getUnitWeightValue(monthList.first.details!.first.productId),
          priceIncludeTax: priceIncludeTaxTotal(monthList),
          purchasePrice: purchasePriceTotal(monthList),
          priceDiff: priceDiffTotal(monthList),
          taxBase: taxBaseTotal(monthList),
          taxAmount: taxAmountTotal(monthList),
          priceExcludeTax: monthList.fold<double>(
              0.0, (sum, order) => sum + getPriceExcludeTaxDetailTotal(order)),
          commissionAmount: monthList.fold<double>(
              0.0, (sum, order) => sum + getCommissionDetailTotal(order)),
          packageAmount: monthList.fold<double>(
              0.0, (sum, order) => sum + getPackagePriceDetailTotal(order)),
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
          weightBath: 0.0,
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
}
