import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/buy-used-gold-gov-reports/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart'; // Ensure this import exists or use material picker
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

// Simple class for Thai month (Copied from Source)
class ThaiMonth {
  final int value;
  final String name;

  ThaiMonth(this.value, this.name);

  @override
  String toString() => name;

  Map<String, dynamic> toJson() => {'value': value, 'name': name};
}

class BuyUsedGoldGovReportScreen extends StatefulWidget {
  const BuyUsedGoldGovReportScreen({super.key});

  @override
  State<BuyUsedGoldGovReportScreen> createState() =>
      _BuyUsedGoldGovReportScreenState();
}

class _BuyUsedGoldGovReportScreenState
    extends State<BuyUsedGoldGovReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;

  // Controllers matched to Source
  final TextEditingController yearCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  ValueNotifier<dynamic>? yearNotifier;
  ValueNotifier<dynamic>? monthNotifier;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  
  // Removed old day/month notifiers, using direct controllers like Source
  DateTime? fromDate;
  DateTime? toDate;

  late List<ThaiMonth> thaiMonths;

  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;

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
      var result = await ApiServices.post(
          '/product/type/USED/2', Global.requestObj(null));
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

  // Updated Search Logic to match Source
  Future<void> search() async {
    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/2',
          Global.reportRequestObj({
            "year": yearCtrl.text == "" ? 0 : yearCtrl.text,
            "month": monthCtrl.text == "" ? 0 : monthCtrl.text,
            "fromDate": fromDateCtrl.text.isNotEmpty
                ? DateTime.parse(fromDateCtrl.text).toString()
                : null,
            "toDate": toDateCtrl.text.isNotEmpty
                ? DateTime.parse(toDateCtrl.text).toString()
                : null,
            // Keep these if you want to support them in the backend, 
            // even if hidden in UI, or remove if not needed.
            "productId": selectedProduct?.id,
            "warehouseId": selectedWarehouse?.id,
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
                  child: Text("รายงานบัญชีสำหรับผู้ทำการค้าของเก่า",
                      style: TextStyle(
                          fontSize: 18,
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
              child: loading
                  ? const LoadingProgress()
                  : _buildEnhancedDataTable(),
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
          Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewBuyUsedGoldGovReportPage(
              orders: filterList!.reversed.toList(),
              type: 1,
              date:
                  '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
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
            Text('พิมพ์',
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // COMPACT FILTER SECTION
  Widget _buildFilterSection() {
    return CompactReportFilter(
      fromDateController: fromDateCtrl,
      toDateController: toDateCtrl,
      onSearch: search,
      onReset: resetFilter,
      filterSummary: _buildFilterSummary(),
      initiallyExpanded: false, // Start collapsed
      autoCollapseOnSearch: true, // Auto-collapse after search
      additionalFilters: [
        // Month and Year dropdowns
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

  // Enhanced Dropdown from Source
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
                    'รายงานบัญชีสำหรับผู้ทำการค้าของเก่า (${filterList!.length} รายการ)',
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
                              // Row number
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
                              // Receipt ID
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
                                          'เลขท่ีใบสําคัญรับเงิน',
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
                              // Customer Name
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ผู้ซื้อ',
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
                              // Tax Number
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
                              // Product
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.inventory_2_rounded,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'รายการสินค้า',
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
                              // Weight
                              Expanded(
                                flex: 3,
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
                                          'น้ําหนัก (กรัม)\n(น.น.สินค้า/น.น.96.5)',
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
                                          'จํานวนเงิน (บาท)',
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
                                        // Receipt ID
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
                                        // Customer Name
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Icon(Icons.person,
                                                      size: 12,
                                                      color: Colors.green[600]),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    '${item.customer?.firstName ?? ''} ${item.customer?.lastName ?? ''}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 11),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
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
                                        // Product
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'ทองเก่า',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.amber[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Weight
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              '${Global.format(getWeight(item))}/${Global.format(getWeight(item))}',
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
                                                fontSize: 11,
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
                                      // Empty for receipt ID
                                      Expanded(flex: 3, child: Container()),
                                      // Empty for customer name
                                      Expanded(flex: 3, child: Container()),
                                      // Total label
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            'รวมท้ังหมด',
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
                                      // Empty for product
                                      Expanded(flex: 2, child: Container()),
                                      // Weight total
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            '${Global.format(getWeightTotal(filterList!))}/${Global.format(getWeightTotal(filterList!))}',
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
                                            Global.format(priceIncludeTaxTotal(
                                                filterList!)),
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
    yearNotifier = ValueNotifier<dynamic>(null);
    monthNotifier = ValueNotifier<dynamic>(null);
    yearCtrl.text = "";
    monthCtrl.text = "";
    fromDateCtrl.text = "";
    toDateCtrl.text = "";
    fromDate = null;
    toDate = null;
    // If you re-add product filters later:
    // productNotifier = ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    // warehouseNotifier = ValueNotifier<WarehouseModel>(WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    search();
  }
}