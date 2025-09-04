import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/vat-reports/papun/sell-new-gold/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:quiver/time.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

class SellVatReportScreen extends StatefulWidget {
  const SellVatReportScreen({super.key});

  @override
  State<SellVatReportScreen> createState() => _SellVatReportScreenState();
}

class _SellVatReportScreenState extends State<SellVatReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;
  bool isFilterExpanded = true;

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
    search();
  }

  void loadProducts() async {
    try {
      var result = await ApiServices.post(
          '/product/type/NEW/1', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/branch', Global.requestObj({"branchId": Global.branch?.id}));
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

    makeSearchDate();

    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/1',
          Global.reportRequestObj({
            "year": yearCtrl.text == "" ? null : yearCtrl.text,
            "month": monthCtrl.text == "" ? null : monthCtrl.text,
            "productId": selectedProduct?.id,
            "warehouseId": selectedWarehouse?.id,
            "fromDate": fromDate.toString(),
            "toDate": toDate.toString(),
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
                  child: Text("รายงานภาษีขายทองคำรูปพรรณใหม่ 96.5%",
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
              child: loading ? const LoadingProgress() : _buildEnhancedDataTable(),
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewSellVatReportPage(
                orders: filterList!.reversed.toList(),
                type: 1,
                fromDate: fromDate,
                toDate: toDate,
                date: '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
              ),
            ),
          );
        }

        if (value == 2 || value == 3) {
          List<OrderModel> dailyList = genDailyList(filterList);
          if (dailyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewSellVatReportPage(
                orders: dailyList,
                type: value,
                fromDate: fromDate,
                toDate: toDate,
                date: '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
              ),
            ),
          );
        }

        if (value == 4) {

          if (yearCtrl.text.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'กรุณาเลือกปี', 'OK');
            return;
          }

          DateTime now = DateTime.now();
          fromDate = DateTime(now.year, 1, 1);
          toDate = DateTime(now.year, 12, 31);

          await search();

          List<OrderModel> monthlyList = genMonthlyList(filterList);
          if (monthlyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewSellVatReportPage(
                orders: monthlyList,
                type: value,
                fromDate: fromDate,
                toDate: toDate,
                date: '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
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
            title: Text('เรียงเลขที่ใบกำกับภาษี', style: TextStyle(fontSize: 14)),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.print, size: 16),
            title: Text('สรุปรายวัน(แสดงทุกวัน)', style: TextStyle(fontSize: 14)),
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: ListTile(
            leading: Icon(Icons.print, size: 16),
            title: Text('สรุปรายวัน(แสดงวันที่มีรายการ)', style: TextStyle(fontSize: 14)),
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
            Text('พิมพ์', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_outlined, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
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
          GestureDetector(
            onTap: () {
              setState(() {
                isFilterExpanded = !isFilterExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.filter_alt_rounded, color: Colors.indigo[600], size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ตัวกรองข้อมูล', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                        Text(_buildFilterSummary(), style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isFilterExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600], size: 24),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isFilterExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isFilterExpanded ? 1.0 : 0.0,
              child: isFilterExpanded ? Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Container(width: double.infinity, height: 1, color: Colors.grey[200]),
                        const SizedBox(height: 16),

                        // First row - Product, Warehouse, From Date
                        Row(
                          children: [
                            Expanded(child: _buildCompactDropdownField(
                                label: 'สินค้า',
                                icon: Icons.inventory_2_rounded,
                                notifier: productNotifier!,
                                items: productList,
                                onChanged: (ProductModel value) {
                                  selectedProduct = value;
                                  productNotifier!.value = value;
                                  search();
                                }
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _buildCompactDropdownField(
                                label: 'คลังสินค้า',
                                icon: Icons.warehouse_rounded,
                                notifier: warehouseNotifier!,
                                items: warehouseList,
                                onChanged: (WarehouseModel value) {
                                  selectedWarehouse = value;
                                  warehouseNotifier!.value = value;
                                  search();
                                }
                            )),

                          ],
                        ),
                        const SizedBox(height: 16),

                        // Second row - To Date, Month, Year
                        Row(
                          children: [
                            Expanded(child: _buildCompactDropdownField(
                                label: 'จากวันที่',
                                icon: Icons.calendar_today,
                                notifier: fromDateNotifier!,
                                items: Global.genMonthDays(),
                                onChanged: (dynamic value) {
                                  fromDateCtrl.text = value.toString();
                                  fromDateNotifier!.value = value;
                                  search();
                                }
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _buildCompactDropdownField(
                                label: 'ถึงวันที่',
                                icon: Icons.calendar_today,
                                notifier: toDateNotifier!,
                                items: Global.genMonthDays(),
                                onChanged: (dynamic value) {
                                  toDateCtrl.text = value.toString();
                                  toDateNotifier!.value = value;
                                  search();
                                }
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _buildCompactDropdownField(
                                label: 'เดือน',
                                icon: Icons.calendar_month,
                                notifier: monthNotifier!,
                                items: Global.genMonth(),
                                onChanged: (dynamic value) {
                                  monthCtrl.text = value.toString();
                                  monthNotifier!.value = value;
                                  search();
                                }
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _buildCompactDropdownField(
                                label: 'ปี',
                                icon: Icons.date_range,
                                notifier: yearNotifier!,
                                items: Global.genYear(),
                                onChanged: (dynamic value) {
                                  yearCtrl.text = value.toString();
                                  yearNotifier!.value = value;
                                  search();
                                }
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red, width: 1.5),
                                    foregroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    resetFilter();
                                  },
                                  icon: const Icon(Icons.clear_rounded, size: 20),
                                  label: const Text('Reset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 7,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  onPressed: search,
                                  icon: const Icon(Icons.search_rounded, size: 20),
                                  label: const Text('ค้นหา', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ) : const SizedBox(),
            ),
          ),
        ],
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
                Icon(Icons.timeline_rounded, color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รายงานภาษีขายทองคำรูปพรรณใหม่ 96.5% (${filterList!.length} รายการ)',
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
                                    Icon(Icons.tag, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 2),
                                    const Flexible(
                                      child: Text(
                                        'ลำดับ',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
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
                                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'วัน/เดือน/ปี',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
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
                                      Icon(Icons.receipt_rounded, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'เลขที่ใบกํากับภาษี',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Name - Small flex
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ชื่อ',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Customer Tax ID - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'เลขประจําตัวลูกค้า',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
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
                                      Icon(Icons.scale_rounded, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'น้ําหนัก',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
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
                                      Icon(Icons.category, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'หน่วย',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
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
                                      Icon(Icons.monetization_on_rounded, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ยอดขายรวม\nภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
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
                                      Icon(Icons.attach_money_rounded, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'มูลค่ายกเว้น',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
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
                                      Icon(Icons.trending_up, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ผลต่างรวม\nภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
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
                                      Icon(Icons.calculate, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ฐานภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
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
                                      Icon(Icons.percent, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
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
                                      Icon(Icons.money_off, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ยอดขายที่ไม่รวม\nภาษีมูลค่าเพิ่ม',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
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
                                    color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                                    border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        // Row number
                                        Container(
                                          width: 60,
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
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
                                              Global.dateOnly(item!.orderDate.toString()),
                                              style: const TextStyle(fontSize: 11),
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
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
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
                                        // Name
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'เงินสด',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10,
                                                  color: Colors.green[700],
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Customer Tax ID
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              Global.company != null ? Global.company!.taxNumber ?? '' : '',
                                              style: const TextStyle(fontSize: 10),
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
                                              Global.format(getWeight(item)),
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
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
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
                                              Global.format(item.priceIncludeTax ?? 0),
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
                                              Global.format(item.purchasePrice ?? 0),
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
                                              Global.format(item.priceDiff ?? 0),
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
                                              Global.format(item.taxAmount ?? 0),
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
                                              Global.format(item.priceExcludeTax ?? 0),
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
                                  border: Border(top: BorderSide(color: Colors.indigo[200]!, width: 2)),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      // Empty for row number
                                      Container(width: 60, padding: const EdgeInsets.all(8)),
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
                                      // Empty for customer tax ID
                                      Expanded(flex: 2, child: Container()),
                                      // Weight total
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format(getWeightTotal(filterList!)),
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
                                            Global.format(priceIncludeTaxTotal(filterList!)),
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
                                            Global.format(purchasePriceTotal(filterList!)),
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
                                            Global.format(priceDiffTotal(filterList!)),
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
                                            Global.format(taxBaseTotal(filterList!)),
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
                                            Global.format(taxAmountTotal(filterList!)),
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
                                            Global.format(priceExcludeTaxTotal(filterList!)),
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
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700])),
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
            itemWidgetBuilder: (int index, T? project, {bool isItemSelected = false}) {
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
    if (selectedProduct != null && selectedProduct!.id != 0) {
      filters.add('สินค้า: ${selectedProduct!.name}');
    }
    if (selectedWarehouse != null && selectedWarehouse!.id != 0) {
      filters.add('คลัง: ${selectedWarehouse!.name}');
    }
    if (monthCtrl.text.isNotEmpty) {
      filters.add('เดือน: ${monthCtrl.text}');
    }
    if (yearCtrl.text.isNotEmpty) {
      filters.add('ปี: ${yearCtrl.text}');
    }
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      filters.add('วันที่: ${fromDateCtrl.text} - ${toDateCtrl.text}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }

  List<OrderModel> genDailyList(List<OrderModel?>? filterList, {int? value}) {
    List<OrderModel> orderList = [];
    int days = Global.daysBetween(fromDate!, toDate!);

    for (int i = 0; i <= days; i++) {
      DateTime monthDate = fromDate!.add(Duration(days: i));

      // Get all orders for this specific date
      var dateList = filterList
          ?.where((element) => element != null &&
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

  List<OrderModel> genMonthlyList(List<OrderModel?>? filterList) {
    List<OrderModel> orderList = [];

    // Calculate months between fromDate and toDate
    int monthsDiff = ((toDate!.year - fromDate!.year) * 12) + (toDate!.month - fromDate!.month);

    for (int i = 0; i <= monthsDiff; i++) {
      // Get the first day of each month
      DateTime monthDate = DateTime(fromDate!.year, fromDate!.month + i, 1);

      // Get all orders for this specific month and year
      var monthList = filterList
          ?.where((element) => element != null &&
          element.createdDate?.year == monthDate.year &&
          element.createdDate?.month == monthDate.month)
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

  makeSearchDate() {
    int month = 0;
    int year = 0;

    if (monthCtrl.text.isEmpty) {
      month = DateTime.now().month;
    } else {
      month = Global.toNumber(monthCtrl.text).toInt();
    }

    if (yearCtrl.text.isEmpty) {
      year = DateTime.now().year;
    } else {
      year = Global.toNumber(yearCtrl.text).toInt();
    }

    if (fromDateCtrl.text.isNotEmpty) {
      fromDate = Global.convertDate(
          '${twoDigit(Global.toNumber(fromDateCtrl.text).toInt())}-${twoDigit(month)}-$year');
    } else {
      fromDate = null;
    }

    if (toDateCtrl.text.isNotEmpty) {
      toDate = Global.convertDate(
          '${twoDigit(Global.toNumber(toDateCtrl.text).toInt())}-${twoDigit(month)}-$year');
    } else {
      toDate = null;
    }

    if (fromDate == null && toDate == null) {
      if (monthCtrl.text.isNotEmpty && yearCtrl.text.isEmpty) {
        fromDate = DateTime(year, month, 1);
        toDate = Jiffy.parseFromDateTime(fromDate!).endOf(Unit.month).dateTime;
      } else if (monthCtrl.text.isEmpty && yearCtrl.text.isNotEmpty) {
        fromDate = DateTime(year, 1, 1);
        toDate = Jiffy.parseFromDateTime(fromDate!)
            .add(months: 12, days: -1)
            .dateTime;
      } else {
        fromDate = DateTime(year, month, 1);
        toDate = Jiffy.parseFromDateTime(fromDate!).endOf(Unit.month).dateTime;
      }
    }
  }

  void resetFilter() {
    yearNotifier = ValueNotifier<dynamic>("");
    monthNotifier = ValueNotifier<dynamic>("");
    fromDateNotifier = ValueNotifier<dynamic>("");
    toDateNotifier = ValueNotifier<dynamic>("");
    yearCtrl.text = "";
    monthCtrl.text = "";
    fromDateCtrl.text = "";
    toDateCtrl.text = "";
    fromDate = null;
    toDate = null;
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    search();
    setState(() {});
  }
}