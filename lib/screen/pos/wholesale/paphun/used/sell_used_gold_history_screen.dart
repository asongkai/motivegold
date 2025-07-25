import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';
import 'preview.dart';

class SellUsedGoldHistoryScreen extends StatefulWidget {
  const SellUsedGoldHistoryScreen({super.key});

  @override
  State<SellUsedGoldHistoryScreen> createState() =>
      _SellUsedGoldHistoryScreenState();
}

class _SellUsedGoldHistoryScreenState extends State<SellUsedGoldHistoryScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;
  TextEditingController productEntryWeightCtrl = TextEditingController();
  TextEditingController productEntryWeightBahtCtrl = TextEditingController();
  TextEditingController sellIdCtrl = TextEditingController();
  TextEditingController dateCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  OrderModel? selectedSell;
  OrderDetailModel? selectedDetail;

  final TextEditingController yearCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  ValueNotifier<dynamic>? yearNotifier;
  ValueNotifier<dynamic>? monthNotifier;
  bool isFilterExpanded = true;

  @override
  void initState() {
    super.initState();
    yearNotifier = ValueNotifier<int>(DateTime.now().year);
    monthNotifier = ValueNotifier<int>(DateTime.now().month);
    yearCtrl.text = DateTime.now().year.toString();
    monthCtrl.text = DateTime.now().month.toString();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post('/order/all/type/6',
          Global.reportRequestObj({"year": yearCtrl.text, "month": monthCtrl.text}));
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

  void search() async {
    if (yearCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกปี', 'OK');
      return;
    }

    if (monthCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกเดือน', 'OK');
      return;
    }

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายการประวัติการขายทองเก่า",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Filter Section
            _buildFilterSection(),

            // Content Area
            Expanded(
              child: loading
                  ? const LoadingProgress()
                  : filterList!.isEmpty
                  ? const NoDataFoundWidget()
                  : Container(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  itemCount: filterList!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    return modernDataCard(filterList![index]!, index);
                  },
                ),
              ),
            ),
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
          // Collapsible Header
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
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.filter_alt_rounded,
                      color: Colors.purple[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ตัวกรองข้อมูล',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          '${_getThaiMonthName(int.parse(monthCtrl.text))} ${yearCtrl.text}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Collapse/Expand Icon
                  AnimatedRotation(
                    turns: isFilterExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isFilterExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isFilterExpanded ? 1.0 : 0.0,
              child: isFilterExpanded ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // Divider
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 20),

                    // Filter Controls
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'ปี',
                            icon: Icons.calendar_today_rounded,
                            notifier: yearNotifier!,
                            items: Global.genYear(),
                            onChanged: (int value) {
                              yearCtrl.text = value.toString();
                              yearNotifier!.value = value;
                              search();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'เดือน',
                            icon: Icons.date_range_rounded,
                            notifier: monthNotifier!,
                            items: Global.genMonth(),
                            onChanged: (int value) {
                              monthCtrl.text = value.toString();
                              monthNotifier!.value = value;
                              search();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: search,
                        icon: const Icon(Icons.search_rounded, size: 20),
                        label: Text(
                          'ค้นหา'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required ValueNotifier notifier,
    required List<int> items,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: MiraiDropDownMenu<int>(
            key: UniqueKey(),
            children: items,
            space: 4,
            maxHeight: 360,
            showSearchTextField: true,
            selectedItemBackgroundColor: Colors.transparent,
            emptyListMessage: 'ไม่มีข้อมูล',
            showSelectedItemBackgroundColor: true,
            itemWidgetBuilder: (
                int index,
                int? project, {
                  bool isItemSelected = false,
                }) {
              return DropDownItemWidget(
                project: project,
                isItemSelected: isItemSelected,
                firstSpace: 10,
                fontSize: 16.sp,
              );
            },
            onChanged: onChanged,
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 16.sp,
              projectValueNotifier: notifier,
            ),
          ),
        ),
      ],
    );
  }

  Widget modernDataCard(OrderModel sell, int index) {
    return GestureDetector(
      onTap: () async {
        final ProgressDialog pr = ProgressDialog(context,
            type: ProgressDialogType.normal,
            isDismissible: true,
            showLogs: true);
        await pr.show();
        pr.update(message: 'processing'.tr());

        try {
          var result = await ApiServices.post(
              '/order/print-order-list/${sell.pairId}',
              Global.requestObj(null));

          var data = jsonEncode(result?.data);
          List<OrderModel> orders = orderListModelFromJson(data);

          var payment = await ApiServices.post(
              '/order/payment/${sell.pairId}', Global.requestObj(null));
          Global.paymentList =
              paymentListModelFromJson(jsonEncode(payment?.data));

          await pr.hide();
          Invoice invoice = Invoice(
              order: sell,
              customer: sell.customer!,
              payments: Global.paymentList,
              orders: orders,
              items: sell.details!);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PreviewSellUsedGoldPage(
                    invoice: invoice,
                  )));
        } catch (e) {
          await pr.hide();
        }
      },
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with Status Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sell_rounded,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${sell.orderId.toString()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatThaiDate(sell.orderDate.toString()),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(sell.orderStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(sell.orderStatus),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(sell.orderStatus),
                          size: 14,
                          color: _getStatusColor(sell.orderStatus),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sell.orderStatus ?? 'N/A',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(sell.orderStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Product Details
              if (sell.details != null && sell.details!.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTableHeader('สินค้า', Icons.inventory_2_rounded),
                            ),
                            Expanded(
                              flex: 3,
                              child: _buildTableHeader('น้ำหนัก', Icons.scale_rounded),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildTableHeader('คลัง', Icons.warehouse_rounded),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildTableHeader('การจัดการ', Icons.settings_rounded),
                            ),
                          ],
                        ),
                      ),

                      // Product Rows
                      ...sell.details!.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var detail = entry.value;
                        bool canAdjust = detail.weightAdj == null || detail.weightAdj == 0;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: idx % 2 == 0 ? Colors.white : Colors.grey[25],
                            borderRadius: idx == sell.details!.length - 1
                                ? const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            )
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Product Name
                              Expanded(
                                flex: 3,
                                child: Text(
                                  detail.productName ?? '',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              // Weight Details
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildWeightInfo(
                                      'ขาย (กรัม)',
                                      Global.format(detail.weight ?? 0),
                                      Colors.blue,
                                    ),
                                    const SizedBox(height: 4),
                                    _buildWeightInfo(
                                      'สูญเสีย (กรัม)',
                                      Global.format(detail.weightAdj ?? 0),
                                      Colors.red,
                                    ),
                                  ],
                                ),
                              ),

                              // Warehouse
                              Expanded(
                                flex: 2,
                                child: Text(
                                  detail.binLocationName ?? '',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              // Action Button
                              Expanded(
                                flex: 2,
                                child: canAdjust
                                    ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSell = sell;
                                      sellIdCtrl.text = sell.orderId;
                                      dateCtrl.text = Global.formatDate(
                                          sell.orderDate!.toString());
                                      productWeightCtrl.text =
                                          formatter.format(detail.weight);
                                      productWeightBahtCtrl.text =
                                          formatter.format(detail.weightBath);
                                      productEntryWeightCtrl.text = "";
                                      productEntryWeightBahtCtrl.text =
                                      "";
                                      selectedDetail = detail;
                                    });
                                    modernAdjustWeightDialog(detail);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.tune_rounded,
                                          color: Colors.teal,
                                          size: 16,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'ปรับน้ำหนัก',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.teal,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'ปรับแล้ว',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightInfo(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return Icons.pending_actions_rounded;
      case 'COMPLETED':
        return Icons.check_circle_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  void modernAdjustWeightDialog(OrderDetailModel detail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ปรับน้ำหนักสูญเสีย',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Order Info Section
                        _buildFormSection(
                          title: 'ข้อมูลคำสั่งซื้อ',
                          icon: Icons.receipt_rounded,
                          color: Colors.blue,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'เลขที่',
                                    controller: sellIdCtrl,
                                    icon: Icons.tag_rounded,
                                    enabled: false,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'วันที่',
                                    controller: dateCtrl,
                                    icon: Icons.calendar_today_rounded,
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Current Weight Section
                        _buildFormSection(
                          title: 'น้ำหนักปัจจุบัน',
                          icon: Icons.scale_rounded,
                          color: Colors.green,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'น้ำหนัก (กรัม)',
                                    controller: productWeightCtrl,
                                    icon: Icons.monitor_weight_rounded,
                                    enabled: false,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'น้ำหนัก (บาททอง)',
                                    controller: productWeightBahtCtrl,
                                    icon: Icons.currency_exchange_rounded,
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Weight Loss Section
                        _buildFormSection(
                          title: 'น้ำหนักสูญเสีย',
                          icon: Icons.trending_down_rounded,
                          color: Colors.red,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'น้ำหนักสูญเสีย (กรัม)',
                                    controller: productEntryWeightCtrl,
                                    icon: Icons.remove_circle_outline_rounded,
                                    inputType: TextInputType.number,
                                    inputFormat: [ThousandsFormatter(allowFraction: true)],
                                    onChanged: (String value) {
                                      if (productEntryWeightCtrl.text.isNotEmpty) {
                                        productEntryWeightBahtCtrl.text =
                                            Global.format((Global.toNumber(
                                                productEntryWeightCtrl.text) /
                                                getUnitWeightValue()));
                                      } else {
                                        productEntryWeightBahtCtrl.text = "";
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'น้ำหนักสูญเสีย (บาททอง)',
                                    controller: productEntryWeightBahtCtrl,
                                    icon: Icons.remove_circle_outline_rounded,
                                    inputType: TextInputType.number,
                                    inputFormat: [ThousandsFormatter(allowFraction: true)],
                                    onChanged: (String value) {
                                      if (productEntryWeightBahtCtrl.text.isNotEmpty) {
                                        productEntryWeightCtrl.text =
                                            Global.format((Global.toNumber(
                                                productEntryWeightBahtCtrl.text) *
                                                getUnitWeightValue()));
                                      } else {
                                        productEntryWeightCtrl.text = "";
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _handleSaveAdjustment,
                            icon: const Icon(Icons.save_rounded, size: 24),
                            label: const Text(
                              'บันทึกการปรับน้ำหนัก',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
        );
      },
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormat,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        buildTextFieldBig(
          labelText: '',
          inputType: inputType,
          labelColor: Colors.orange,
          enabled: enabled,
          controller: controller,
          inputFormat: inputFormat,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _handleSaveAdjustment() async {
    if (productEntryWeightCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเพิ่มข้อมูลก่อน', 'OK');
      return;
    }

    if (selectedSell == null) {
      return;
    }

    selectedDetail?.weightAdj = Global.toNumber(productEntryWeightCtrl.text);
    selectedDetail?.weightBathAdj = Global.toNumber(productEntryWeightBahtCtrl.text);

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง', action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal,
          isDismissible: true,
          showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.post(
            '/order/confirm-adjust', Global.requestObj(selectedSell));
        if (result!.status == "success") {
          var detail = await ApiServices.post(
              '/orderdetail/adjust/sell', Global.requestObj(selectedDetail));
          await pr.hide();
          if (detail?.status == "success") {
            motivePrint("Confirm completed");
            if (mounted) {
              Alert.success(context, 'Success'.tr(), 'Success', 'OK'.tr(), action: () {
                Navigator.of(context).pop();
                loadData();
              });
            }
          }
        } else {
          await pr.hide();
        }
        setState(() {});
      } catch (e) {
        await pr.hide();
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(), action: () {});
        }
      }
    });
  }

  // Helper method to get Thai month names
  String _getThaiMonthName(int month) {
    const thaiMonths = [
      '', // Index 0 (not used)
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return month > 0 && month <= 12 ? thaiMonths[month] : 'ไม่ระบุ';
  }

  // Helper method to format Thai date
  String _formatThaiDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      String day = date.day.toString().padLeft(2, '0');
      String monthName = _getThaiMonthName(date.month);
      String year = (date.year + 543).toString(); // Convert to Buddhist year
      String time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

      return '$day $monthName $year เวลา $time น.';
    } catch (e) {
      return Global.formatDate(dateString); // Fallback to original format
    }
  }
}