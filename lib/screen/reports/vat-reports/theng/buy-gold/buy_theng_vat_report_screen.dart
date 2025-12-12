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
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/filter/compact_report_filter.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
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
                      // Sticky Header
                      Container(
                        color: Colors.grey[50],
                        height: 56,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Row number - Fixed small width
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
                              // Date - Small flex
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
                                          'วัน/เดือน/ปี',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Order ID - Large flex for order numbers
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
                                              fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Seller - Small flex
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.store,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ผู้ขาย',
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
                              // Tax Number - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.badge,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'เลขประจําตัวผู้เสียภาษี',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Weight - Small flex
                              Expanded(
                                flex: 1,
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
                                          'น้ําหนัก',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Unit - Small flex
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.category,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'หน่วย',
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
                              // Price Include Tax - Medium flex
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
                                          'ยอดขายรวม\nภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Purchase Price - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.attach_money_rounded,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'มูลค่ายกเว้น',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Price Diff - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.trending_up,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ผลต่างรวม\nภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tax Base - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.calculate,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ฐานภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tax Amount - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.percent,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Price Exclude Tax - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.money_off,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ยอดขายที่ไม่รวม\nภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9),
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
                                                  const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Order ID
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
                                                  fontSize: 11,
                                                  color: Colors.blue[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Seller
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'เงินสด',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10,
                                                  color: Colors.orange[700],
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Tax Number
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.company != null
                                                  ? Global.company!.taxNumber ??
                                                      ''
                                                  : '',
                                              style:
                                                  const TextStyle(fontSize: 10),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // Weight
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format4(getWeight(item)),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.orange,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Unit
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.purple
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'กรัม',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.purple[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Price Include Tax
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(
                                                  item.priceIncludeTax ?? 0),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.green,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Purchase Price
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(
                                                  item.purchasePrice ?? 0),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.blue,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Price Diff
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(
                                                  item.priceDiff ?? 0),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.red,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Tax Base
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(item.taxBase ?? 0),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.purple,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Tax Amount
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(
                                                  item.taxAmount ?? 0),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.amber,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Price Exclude Tax
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.format(
                                                  item.priceExcludeTax ?? 0),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.indigo,
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
                                      // Empty for order ID
                                      Expanded(flex: 3, child: Container()),
                                      // Total label
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            'รวมท้ังหมด',
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
                                      // Empty for tax number
                                      Expanded(flex: 2, child: Container()),
                                      // Weight total
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format4(
                                                getWeightTotal(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              color: Colors.orange[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Empty for unit
                                      Expanded(flex: 1, child: Container()),
                                      // Price Include Tax total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(priceIncludeTaxTotal(
                                                filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              color: Colors.green[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Purchase Price total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(purchasePriceTotal(
                                                filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              color: Colors.blue[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Price Diff total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(
                                                priceDiffTotal(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              color: Colors.red[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Tax Base total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(
                                                taxBaseTotal(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              color: Colors.purple[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Tax Amount total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(
                                                taxAmountTotal(filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              color: Colors.amber[700],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Price Exclude Tax total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(priceExcludeTaxTotal(
                                                filterList!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
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

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onClear,
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
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.calendar_today, size: 18),
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: onClear, child: const Icon(Icons.clear, size: 18))
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              hintText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.indigo[600]!),
              ),
            ),
            readOnly: true,
            onTap: () async {
              showDialog(
                context: context,
                builder: (_) => SfDatePickerDialog(
                  initialDate: DateTime.now(),
                  onDateSelected: (date) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(date);
                    setState(() {
                      controller.text = formattedDate;
                    });
                    search();
                  },
                ),
              );
            },
          ),
        ),
      ],
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
