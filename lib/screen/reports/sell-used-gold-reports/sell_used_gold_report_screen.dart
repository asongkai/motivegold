import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/sell-used-gold-reports/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:sizer/sizer.dart';

class SellUsedGoldReportScreen extends StatefulWidget {
  const SellUsedGoldReportScreen({super.key});

  @override
  State<SellUsedGoldReportScreen> createState() =>
      _SellUsedGoldReportScreenState();
}

class _SellUsedGoldReportScreenState extends State<SellUsedGoldReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;
  bool isFilterExpanded = true;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadProducts() async {
    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/6',
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
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> products = orderListModelFromJson(data);
        if (products.isNotEmpty) {
          orders = products;
          filterList = products;
        } else {
          orders!.clear();
          filterList!.clear();
        }
        setState(() {});
      } else {
        orders = [];
      }
    } catch (e) {
      motivePrint(e.toString());
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
                  child: Text("รายงานขายทองรูปพรรณเก่า",
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
              builder: (context) => PreviewSellUsedGoldReportPage(
                orders: filterList!.reversed.toList(),
                type: 1,
                fromDate: DateTime.parse(fromDateCtrl.text),
                toDate: DateTime.parse(toDateCtrl.text),
                date: '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
              ),
            ),
          );
        }

        if (value == 2) {

          DateTime now = DateTime.now();
          DateTime fromDate = DateTime(now.year, 1, 1);
          DateTime toDate = DateTime(now.year, 12, 31);

          fromDateCtrl.text = Global.formatDateDD(fromDate.toString());
          toDateCtrl.text = Global.formatDateDD(toDate.toString());

          await loadProducts();

          if (filterList!.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }

          List<OrderModel> monthlyList = genMonthlyList(filterList!.reversed.toList(), fromDate, toDate);
          if (monthlyList.isEmpty) {
            Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewSellUsedGoldReportPage(
                orders: monthlyList,
                type: value,
                fromDate: fromDate,
                toDate: toDate,
                date:
                '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
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
                        if (fromDateCtrl.text.isNotEmpty || toDateCtrl.text.isNotEmpty)
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
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Container(width: double.infinity, height: 1, color: Colors.grey[200]),
                        const SizedBox(height: 20),

                        // Date range row
                        Row(
                          children: [
                            Expanded(child: _buildDateField(
                              label: 'จากวันที่',
                              icon: Icons.calendar_today,
                              controller: fromDateCtrl,
                              onClear: () {
                                setState(() {
                                  fromDateCtrl.text = "";
                                  toDateCtrl.text = "";
                                  filterList = orders;
                                });
                              },
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDateField(
                              label: 'ถึงวันที่',
                              icon: Icons.calendar_today,
                              controller: toDateCtrl,
                              onClear: () {
                                setState(() {
                                  fromDateCtrl.text = "";
                                  toDateCtrl.text = "";
                                  filterList = orders;
                                });
                              },
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  onPressed: loadProducts,
                                  icon: const Icon(Icons.search_rounded, size: 20),
                                  label: const Text('ค้นหา', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                  onPressed: resetFilters,
                                  icon: const Icon(Icons.clear_rounded, size: 20),
                                  label: const Text('Reset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                    'รายงานขายทองเก่า (${filterList!.length} รายการ)',
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
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Receipt ID - Large flex for receipt numbers
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
                                          'เลขที่ใบสำคัญรับเงิน',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Customer Name - Large flex for names
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'ผู้ซื้อ',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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
                                      Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'เลขประจำตัวผู้เสียภาษี',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Product Type - Medium flex
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.inventory_2_rounded, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      const Flexible(
                                        child: Text(
                                          'รายการสินค้า',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Weight - Small flex for numbers
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
                                          'น้ำหนัก (กรัม)',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Amount - Medium flex for currency
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
                                          'จำนวนเงิน (บาท)',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
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
                                        // Receipt ID
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
                                                    color: Colors.green.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Icon(Icons.person, size: 12, color: Colors.green[600]),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    '${item.customer?.firstName ?? ''} ${item.customer?.lastName ?? ''}',
                                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                                                    overflow: TextOverflow.ellipsis,
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
                                              item.customer?.taxNumber != ''
                                                  ? item.customer?.taxNumber ?? ''
                                                  : item.customer?.idCard ?? '',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
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
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
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
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Weight
                                        Expanded(
                                          flex: 1,
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
                                      // Empty cells for alignment
                                      Container(width: 60, padding: const EdgeInsets.all(8)),
                                      Expanded(flex: 1, child: Container()),
                                      Expanded(flex: 3, child: Container()),
                                      Expanded(flex: 3, child: Container()),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            'รวมทั้งหมด',
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
                                      Expanded(flex: 2, child: Container()),
                                      // Weight total
                                      Expanded(
                                        flex: 1,
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
                                            Global.format(priceIncludeTaxTotal(filterList!)),
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
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.calendar_today, size: 18),
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.clear, size: 18))
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
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
                    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                    setState(() {
                      controller.text = formattedDate;
                    });
                    loadProducts();
                  },
                ),
              );
            },
          ),
        ),
      ],
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

    int days = Global.daysBetween(DateTime.parse(fromDateCtrl.text), DateTime.parse(toDateCtrl.text));

    for (int i = 0; i <= days; i++) {
      DateTime monthDate = DateTime.parse(fromDateCtrl.text).add(Duration(days: i));

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

  List<OrderModel> genMonthlyList(List<OrderModel?>? filterList, DateTime fromDate, DateTime toDate) {
    List<OrderModel> orderList = [];

    // Calculate months between fromDate and toDate
    int monthsDiff = ((toDate.year - fromDate.year) * 12) + (toDate.month - fromDate.month);

    for (int i = 0; i <= monthsDiff; i++) {
      // Get the first day of each month
      DateTime monthDate = DateTime(fromDate.year, fromDate.month + i, 1);

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
}