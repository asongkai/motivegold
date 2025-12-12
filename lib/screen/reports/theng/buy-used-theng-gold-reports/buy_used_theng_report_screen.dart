import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/theng/buy-used-theng-gold-reports/preview.dart';
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
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

// ThaiMonth Class
class ThaiMonth {
  final int value;
  final String name;

  ThaiMonth(this.value, this.name);

  @override
  String toString() => name;

  Map<String, dynamic> toJson() => {'value': value, 'name': name};
}

class BuyUsedThengGoldReportScreen extends StatefulWidget {
  const BuyUsedThengGoldReportScreen({super.key});

  @override
  State<BuyUsedThengGoldReportScreen> createState() =>
      _BuyUsedThengGoldReportScreenState();
}

class _BuyUsedThengGoldReportScreenState
    extends State<BuyUsedThengGoldReportScreen> {
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

  // We use local variables for print logic, but UI relies on controllers
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

    // Initialize Thai months
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
          '/order/all/type/44',
          Global.reportRequestObj({
            "year": yearCtrl.text == "" ? 0 : yearCtrl.text,
            "month": monthCtrl.text == "" ? 0 : monthCtrl.text,
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
                  child: Text("รายงานซื้อทองคำแท่งเก่า",
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
        if (fromDateCtrl.text.isEmpty || toDateCtrl.text.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'กรุณาเลือกช่วงวันที่', 'OK');
          return;
        }

        // Parse dates from controllers for report generation
        DateTime start = DateTime.parse(fromDateCtrl.text);
        DateTime end = DateTime.parse(toDateCtrl.text);

        // Update state variables for genList functions
        fromDate = start;
        toDate = end;

        if (value == 1) {
          if (filterList!.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewBuyUsedThengGoldReportPage(
                orders: filterList!.reversed.toList(),
                type: 1,
                fromDate: start,
                toDate: end,
                date:
                    '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
              ),
            ),
          );
        }

        if (value == 2 || value == 3) {
          List<OrderModel> dailyList =
              genDailyList(filterList!.reversed.toList(), value: value);
          if (dailyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewBuyUsedThengGoldReportPage(
                orders: dailyList,
                type: value,
                fromDate: start,
                toDate: end,
                date:
                    '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
              ),
            ),
          );
        }

        if (value == 4) {
          // For monthly summary, we typically check year
          if (yearCtrl.text.isEmpty &&
              (fromDateCtrl.text.isEmpty || toDateCtrl.text.isEmpty)) {
            // If no specific year filter, ensure dates are set
            Alert.warning(
                context, 'คำเตือน', 'กรุณาเลือกปีหรือช่วงวันที่', 'OK');
            return;
          }

          List<OrderModel> monthlyList =
              genMonthlyList(filterList!.reversed.toList());
          if (monthlyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewBuyUsedThengGoldReportPage(
                orders: monthlyList,
                type: 4,
                fromDate: start,
                toDate: end,
                date:
                    '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
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
            title:
                Text('สรุปรายวัน(แสดงทุกวัน)', style: TextStyle(fontSize: 14)),
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: ListTile(
            leading: Icon(Icons.print, size: 16),
            title: Text('สรุปรายวัน(แสดงวันที่มีรายการ)',
                style: TextStyle(fontSize: 14)),
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

  String _buildFilterSummary() {
    List<String> filters = [];
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      filters.add('ช่วงวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }

  List<OrderModel> genDailyList(List<OrderModel?>? filterList, {int? value}) {
    List<OrderModel> orderList = [];
    // Use local variables for calculation
    int days = Global.daysBetween(fromDate!, toDate!);

    for (int i = 0; i <= days; i++) {
      DateTime monthDate = fromDate!.add(Duration(days: i));

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
          orderId: combinedOrderId,
          // Combined all order IDs
          orderDate: dateList.first.orderDate,
          createdDate: monthDate,
          customerId: 0,
          weight: getWeightTotal(dateList),
          weightBath: getWeightTotal(dateList) /
              getUnitWeightValue(dateList.first.details!.first.productId),
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
          weightBath: getWeightTotal(monthList) /
              getUnitWeightValue(monthList.first.details!.first.productId),
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

  void resetFilter() {
    yearNotifier = ValueNotifier<dynamic>(null);
    monthNotifier = ValueNotifier<dynamic>(null);
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

    selectedProduct = null;
    selectedWarehouse = null;

    setState(() {});
    loadProducts();
    search();
  }
}
