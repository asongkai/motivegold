import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/stockmovement.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/preview.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/preview_stock_card.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/filter/compact_report_filter.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

class StockMovementReportListScreen extends StatefulWidget {
  const StockMovementReportListScreen({super.key});

  @override
  State<StockMovementReportListScreen> createState() =>
      _StockMovementReportListScreenState();
}

class _StockMovementReportListScreenState
    extends State<StockMovementReportListScreen> {
  bool loading = false;
  List<StockMovementModel>? dataList = [];
  List<StockMovementModel>? filterList = [];
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  Screen? size;
  String searchQuery = '';

  final TextEditingController productCtrl = TextEditingController();
  final TextEditingController warehouseCtrl = TextEditingController();
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  // Sorting
  int? sortColumnIndex;
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));

    // Set default date range: 1st of current month to today
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    toDateCtrl.text = DateFormat('yyyy-MM-dd').format(now);

    loadProducts();
    search();
  }

  void loadProducts() async {
    try {
      var result =
          await ApiServices.post('/product/all', Global.requestObj(null));
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

  void search() async {
    setState(() {
      loading = true;
    });

    var location = await ApiServices.post(
        '/stockmovement/search',
        Global.reportRequestObj({
          "productId": selectedProduct?.id,
          "binLocationId": selectedWarehouse?.id,
          "fromDate": fromDateCtrl.text.isNotEmpty
              ? DateTime.parse(fromDateCtrl.text).toString()
              : null,
          "toDate": toDateCtrl.text.isNotEmpty
              ? DateTime.parse(toDateCtrl.text).toString()
              : null,
        }));

    if (location?.status == "success") {
      var data = jsonEncode(location?.data);
      List<StockMovementModel> products = stockMovementListModelFromJson(data);
      setState(() {
        dataList = products;
        filterList = products;
        _applySearchFilter();
      });
    } else {
      dataList = [];
      filterList!.clear();
    }

    setState(() {
      loading = false;
    });
  }

  void _applySearchFilter() {
    if (searchQuery.isEmpty) {
      filterList = List.from(dataList!);
    } else {
      filterList = dataList!.where((item) {
        return (item.product?.name
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (item.binLocation?.name
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (item.orderId?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false) ||
            (item.type?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false) ||
            (item.docType?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }
  }

  void _sortData(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;

      filterList!.sort((a, b) {
        dynamic aValue, bValue;

        switch (columnIndex) {
          case 0: // Order ID
            aValue = a.orderId ?? '';
            bValue = b.orderId ?? '';
            break;
          case 1: // Date
            aValue = a.createdDate ?? DateTime.now();
            bValue = b.createdDate ?? DateTime.now();
            break;
          case 2: // Product
            aValue = a.product?.name ?? '';
            bValue = b.product?.name ?? '';
            break;
          case 3: // Warehouse
            aValue = a.binLocation?.name ?? '';
            bValue = b.binLocation?.name ?? '';
            break;
          case 4: // Movement Type
            aValue = a.type ?? '';
            bValue = b.type ?? '';
            break;
          case 5: // Document Type
            aValue = a.docType ?? '';
            bValue = b.docType ?? '';
            break;
          case 6: // Weight
            aValue = a.weight ?? 0;
            bValue = b.weight ?? 0;
            break;
          case 7: // Unit Cost
            aValue = a.unitCost ?? 0;
            bValue = b.unitCost ?? 0;
            break;
          case 8: // Total Price
            aValue = a.price ?? 0;
            bValue = b.price ?? 0;
            break;
          default:
            return 0;
        }

        if (aValue is String && bValue is String) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else if (aValue is num && bValue is num) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        }
        return 0;
      });
    });
  }

  void resetFilters() {
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    productCtrl.text = "";
    warehouseCtrl.text = "";
    fromDateCtrl.text = "";
    toDateCtrl.text = "";
    searchCtrl.text = "";
    selectedProduct = null;
    selectedWarehouse = null;
    searchQuery = '';
    search();
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
                  child: Text("รายงานความเคลื่อนไหวสต๊อกสินค้า(รับ-จ่าย)",
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
        if (filterList!.isEmpty) {
          Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewStockMovementReportPage(
              list: filterList!.reversed.toList(),
              type: 1,
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

  Widget _buildFilterSection() {
    return CompactReportFilter(
      fromDateController: fromDateCtrl,
      toDateController: toDateCtrl,
      onSearch: search,
      onReset: resetFilters,
      filterSummary: _buildFilterSummary(),
      initiallyExpanded: false,
      autoCollapseOnSearch: true,
      additionalFilters: [
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'สินค้า',
                icon: Icons.inventory_2_rounded,
                notifier: productNotifier!,
                items: productList,
                onChanged: (ProductModel value) {
                  productCtrl.text = value.name;
                  selectedProduct = value;
                  productNotifier!.value = value;
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                label: 'คลังสินค้า',
                icon: Icons.warehouse_rounded,
                notifier: warehouseNotifier!,
                items: warehouseList,
                onChanged: (WarehouseModel value) {
                  warehouseCtrl.text = value.name.toString();
                  selectedWarehouse = value;
                  warehouseNotifier!.value = value;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to determine color based on movement type
  MaterialColor _getMovementTypeColor(String? type) {
    if (type == null) return Colors.grey;

    String lowerType = type.toLowerCase();
    if (lowerType.contains('in')) {
      return Colors.green;
    } else if (lowerType.contains('out') || lowerType.contains('sale')) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
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
                    'รายงานความเคลื่อนไหวสต๊อกสินค้า (${filterList!.length} รายการ)',
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
                              // Order ID - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(0, !isAscending),
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
                                        if (sortColumnIndex == 0)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Date - Small flex
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(1, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'วันที่',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 1)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Product - Large flex for longest content
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(2, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.inventory_2_rounded,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'สินค้า',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 2)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Warehouse - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(3, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warehouse_rounded,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'คลังสินค้า',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 3)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Movement Type - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(4, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.swap_horiz,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'ประเภทการเคลื่อนไหว',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 4)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Document Type - Small flex
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(5, !isAscending),
                                    child: Row(
                                      children: [
                                        Icon(Icons.description,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'ประเภทเอกสาร',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (sortColumnIndex == 5)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Weight - Small flex for numbers
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(6, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.scale_rounded,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'น้ำหนักรวม',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        if (sortColumnIndex == 6)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Unit Cost - Medium flex for price
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(7, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.attach_money_rounded,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'ราคาต่อหน่วย',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        if (sortColumnIndex == 7)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Total Price - Medium flex for price
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => _sortData(8, !isAscending),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.monetization_on_rounded,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'ราคารวม',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        if (sortColumnIndex == 8)
                                          Icon(
                                            isAscending
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: Colors.indigo[600],
                                          ),
                                      ],
                                    ),
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
                            children: filterList!.asMap().entries.map((entry) {
                              int index = entry.key;
                              StockMovementModel item = entry.value;

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
                                            color: Colors.grey.withOpacity(0.1),
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
                                      // Order ID
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.blue.withOpacity(0.1),
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
                                      // Date
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.dateOnly(
                                                item.createdDate.toString()),
                                            style:
                                                const TextStyle(fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Product
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(Icons.inventory_2,
                                                    size: 12,
                                                    color: Colors.green[600]),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  item.product?.name ?? '',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Warehouse
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.purple
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.binLocation?.name ?? '',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.purple[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Movement Type
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _getMovementTypeColor(
                                                      item.type)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.type ?? '',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _getMovementTypeColor(
                                                    item.type)[700],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Document Type
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            item.docType ?? '',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
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
                                            item.product?.type == 'BAR'
                                                ? Global.format4(
                                                    item.weight ?? 0)
                                                : Global.format(
                                                    item.weight ?? 0),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                              color: _getMovementTypeColor(
                                                  item.type)[600],
                                            ),
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Unit Cost
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format6(item.unitCost ?? 0),
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
                                      // Total Price
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            Global.format6(item.price ?? 0),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                              color: _getMovementTypeColor(
                                                  item.type)[600],
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
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.indigo[600]),
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
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                        'น้ำหนักรวม: ${Global.format6(filterList!.fold(0.0, (sum, item) => sum + (item.weight ?? 0)))}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'ราคาต่อหน่วยรวม: ${Global.format6(filterList!.fold(0.0, (sum, item) => sum + (item.unitCost ?? 0)))}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'มูลค่ารวม: ${Global.format6(filterList!.fold(0.0, (sum, item) => sum + (item.price ?? 0)))}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required ValueNotifier notifier,
    required List<T> items,
    required Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Row(
            children: [
              Icon(icon, size: 13, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: MiraiDropDownMenu<T>(
            key: UniqueKey(),
            children: items,
            space: 4,
            maxHeight: 360,
            showSearchTextField: true,
            selectedItemBackgroundColor: Colors.transparent,
            emptyListMessage: 'ไม่มีข้อมูล',
            showSelectedItemBackgroundColor: true,
            itemWidgetBuilder: (int index, T? project,
                {bool isItemSelected = false}) {
              return DropDownItemWidget(
                project: project,
                isItemSelected: isItemSelected,
                firstSpace: 10,
                fontSize: 13,
              );
            },
            onChanged: onChanged,
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 13,
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
    if (fromDateCtrl.text.isNotEmpty && toDateCtrl.text.isNotEmpty) {
      filters.add(
          'ช่วงวันที่: ${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}');
    }
    return filters.isEmpty ? 'ทั้งหมด' : filters.join(' | ');
  }
}
