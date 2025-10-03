import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/screen/pos/checkout_wholesale_summary_history_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/bill/preview_buy_theng_pdf.dart';
import 'package:motivegold/screen/pos/storefront/theng/bill/preview_pdf.dart';
import 'package:motivegold/screen/pos/storefront/theng/bill/preview_sell_theng_pdf.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/refill/preview.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/used/preview.dart';
import 'package:motivegold/screen/pos/wholesale/theng/refill/preview.dart';
import 'package:motivegold/screen/pos/wholesale/theng/used/preview.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/dropdown/CustomerDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/CustomerDropDownObjectChildWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sizer/sizer.dart';

import 'checkout_summary_history_screen.dart';
import 'storefront/paphun/bill/preview_pdf.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.productType});

  final ProductTypeModel? productType;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool loading = false;
  List<OrderModel>? list = [];
  List<OrderModel?>? filterList = [];
  Screen? size;
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController customerFilterCtrl = TextEditingController();

  ProductTypeModel? selectedOrderType;
  static ValueNotifier<dynamic>? orderTypeNotifier;

  CustomerModel? selectedCustomer;
  static ValueNotifier<dynamic>? customerNotifier;

  List<CustomerModel>? customers = [];
  bool loadingCustomer = false;
  bool isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    selectedOrderType = widget.productType;
    orderTypeNotifier = ValueNotifier<ProductTypeModel>(selectedOrderType ??
        ProductTypeModel(id: 0, code: '', name: 'เลือกประเภทธุรกรรม'));
    customerNotifier = ValueNotifier<CustomerModel?>(null);
  }

  void search() async {
    if (selectedOrderType == null &&
        customerFilterCtrl.text.isEmpty &&
        toDateCtrl.text.isEmpty &&
        fromDateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเลือกตัวกรองข้อมูลก่อน'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
      filterList?.clear();
      Global.pairId = null;
      Global.orderIds!.clear();
    });

    try {
      var result = await ApiServices.post(
          '/order/all/search',
          Global.requestObj({
            "year": 0,
            "month": 0,
            "fromDate": fromDateCtrl.text.isNotEmpty
                ? DateTime.parse(fromDateCtrl.text).toString()
                : null,
            "toDate": toDateCtrl.text.isNotEmpty
                ? DateTime.parse(toDateCtrl.text).toString()
                : null,
            "orderTypeId": selectedOrderType?.id,
            "customerId": selectedCustomer?.id,
            "customerFilter": customerFilterCtrl.text,
          }));

      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> products = orderListModelFromJson(data);
        setState(() {
          list = products;
          filterList = products;
        });
      } else {
        list = [];
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

  void _resetFilters() {
    setState(() {
      selectedOrderType = null;
      selectedCustomer = null;
      fromDateCtrl.clear();
      toDateCtrl.clear();
      customerFilterCtrl.clear();
      orderTypeNotifier = ValueNotifier<ProductTypeModel?>(null);
      customerNotifier = ValueNotifier<CustomerModel?>(null);
      filterList?.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.productType != null ? true : false,
          title: Text("รายการประวัติการซื้อขายทองคำ",
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: loadingCustomer
            ? Center(child: LoadingProgress())
            : Column(
                children: [
                  // Modern Filter Section
                  Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Filter Header
                        InkWell(
                          onTap: () {
                            setState(() {
                              isFilterExpanded = !isFilterExpanded;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.filter_list,
                                    color: Colors.indigo[700], size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'ตัวกรองข้อมูล',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Spacer(),
                                AnimatedRotation(
                                  turns: isFilterExpanded ? 0.5 : 0,
                                  duration: Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Filter Content
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: isFilterExpanded ? null : 0,
                          child: isFilterExpanded
                              ? Padding(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    children: [
                                      Divider(height: 1),
                                      SizedBox(height: 16),

                                      // Transaction Type & Customer Search
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'ประเภทธุรกรรม',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]!),
                                                  ),
                                                  child: MiraiDropDownMenu<
                                                      ProductTypeModel>(
                                                    key: ValueKey(
                                                        'order_type_dropdown'),
                                                    children: orderTypes()
                                                        .where((e) => e.id != 7)
                                                        .toList(),
                                                    space: 4,
                                                    maxHeight: 300,
                                                    showSearchTextField: true,
                                                    selectedItemBackgroundColor:
                                                        Colors.transparent,
                                                    emptyListMessage:
                                                        'ไม่มีข้อมูล',
                                                    showSelectedItemBackgroundColor:
                                                        true,
                                                    itemWidgetBuilder: (int
                                                            index,
                                                        ProductTypeModel?
                                                            project,
                                                        {bool isItemSelected =
                                                            false}) {
                                                      return DropDownItemWidget(
                                                        project: project,
                                                        isItemSelected:
                                                            isItemSelected,
                                                        firstSpace: 10,
                                                        fontSize: 12.sp,
                                                      );
                                                    },
                                                    onChanged: (ProductTypeModel
                                                        value) async {
                                                      selectedOrderType = value;
                                                      orderTypeNotifier!.value =
                                                          value;
                                                      search();
                                                    },
                                                    child:
                                                        DropDownObjectChildWidget(
                                                      key: GlobalKey(),
                                                      fontSize: 12.sp,
                                                      projectValueNotifier:
                                                          orderTypeNotifier!,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'ค้นหาลูกค้า',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                SizedBox(
                                                  height: 48,
                                                  child: TextField(
                                                    controller:
                                                        customerFilterCtrl,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'ชื่อ, ID, อีเมล, เบอร์โทร',
                                                      hintStyle: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: Colors.grey[500],
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300]!),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300]!),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .indigo[700]!),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8),
                                                      suffixIcon:
                                                          customerFilterCtrl
                                                                  .text
                                                                  .isNotEmpty
                                                              ? IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .clear,
                                                                      size: 18),
                                                                  onPressed:
                                                                      () {
                                                                    customerFilterCtrl
                                                                        .clear();
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                )
                                                              : null,
                                                    ),
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 16),

                                      // Date Range
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'จากวันที่',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                SizedBox(
                                                  height: 48,
                                                  child: TextField(
                                                    controller: fromDateCtrl,
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      hintText: 'เลือกวันที่',
                                                      prefixIcon: Icon(
                                                          Icons.calendar_today,
                                                          size: 18,
                                                          color:
                                                              Colors.grey[600]),
                                                      suffixIcon: fromDateCtrl
                                                              .text.isNotEmpty
                                                          ? IconButton(
                                                              icon: Icon(
                                                                  Icons.clear,
                                                                  size: 18),
                                                              onPressed: () {
                                                                setState(() {
                                                                  fromDateCtrl
                                                                      .clear();
                                                                  toDateCtrl
                                                                      .clear();
                                                                });
                                                              },
                                                            )
                                                          : null,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300]!),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300]!),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .indigo[700]!),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8),
                                                    ),
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                    onTap: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            SfDatePickerDialog(
                                                          initialDate:
                                                              DateTime.now(),
                                                          onDateSelected:
                                                              (date) {
                                                            String
                                                                formattedDate =
                                                                DateFormat(
                                                                        'yyyy-MM-dd')
                                                                    .format(
                                                                        date);
                                                            setState(() {
                                                              fromDateCtrl
                                                                      .text =
                                                                  formattedDate;
                                                            });
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'ถึงวันที่',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                SizedBox(
                                                  height: 48,
                                                  child: TextField(
                                                    controller: toDateCtrl,
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      hintText: 'เลือกวันที่',
                                                      prefixIcon: Icon(
                                                          Icons.calendar_today,
                                                          size: 18,
                                                          color:
                                                              Colors.grey[600]),
                                                      suffixIcon: toDateCtrl
                                                              .text.isNotEmpty
                                                          ? IconButton(
                                                              icon: Icon(
                                                                  Icons.clear,
                                                                  size: 18),
                                                              onPressed: () {
                                                                setState(() {
                                                                  toDateCtrl
                                                                      .clear();
                                                                  fromDateCtrl
                                                                      .clear();
                                                                });
                                                              },
                                                            )
                                                          : null,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300]!),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300]!),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .indigo[700]!),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8),
                                                    ),
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                    onTap: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            SfDatePickerDialog(
                                                          initialDate:
                                                              DateTime.now(),
                                                          onDateSelected:
                                                              (date) {
                                                            String
                                                                formattedDate =
                                                                DateFormat(
                                                                        'yyyy-MM-dd')
                                                                    .format(
                                                                        date);
                                                            setState(() {
                                                              toDateCtrl.text =
                                                                  formattedDate;
                                                            });
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 16),

                                      // Action Buttons - Custom Compact Design
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Reset Button
                                          GestureDetector(
                                            onTap: _resetFilters,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.refresh,
                                                      color: Colors.white,
                                                      size: 16),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    'รีเซ็ต',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Search Button
                                          GestureDetector(
                                            onTap: search,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.indigo[700],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.search,
                                                      color: Colors.white,
                                                      size: 16),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    'ค้นหา',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                        ),
                      ],
                    ),
                  ),

                  // Results Section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: loading
                          ? Center(child: LoadingProgress())
                          : filterList!.isEmpty
                              ? Center(child: NoDataFoundWidget())
                              : ListView.builder(
                                  itemCount: filterList!.length,
                                  itemBuilder: (context, index) {
                                    return _buildModernOrderCard(
                                        filterList![index]!, index);
                                  },
                                ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildModernOrderCard(OrderModel order, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.indigo[700],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#${order.orderId}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorType(order).withOpacity(0.1),
                                  border: Border.all(color: colorType(order)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  dataType(order),
                                  style: TextStyle(
                                    color: colorType(order),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              if (order.orderStatus != 'CANCEL')
                              GestureDetector(
                                onTap: () {
                                  cancelOrder(order);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ยกเลิก',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              if (order.orderStatus == 'CANCEL')
                                GestureDetector(
                                  onTap: () {
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'ถูกยกเลิก',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'ลูกค้า: ${getCustomerName(order.customer!)}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.event,
                                  size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                'วันที่เอกสาร: ${Global.formatDate(order.orderDate.toString())}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                'วันที่บันทึกรายการ: ${Global.formatDate(order.createdDate.toString())}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Column(
                      children: [
                        _buildActionButton(
                          icon: Icons.receipt_long,
                          label: 'สรุป',
                          color: Colors.indigo[700]!,
                          onTap: () {
                            Global.pairId = order.pairId;
                            if (order.orderTypeId == 5 ||
                                order.orderTypeId == 6 ||
                                order.orderTypeId == 10 ||
                                order.orderTypeId == 11) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CheckOutWholesaleSummaryHistoryScreen(),
                                  fullscreenDialog: true,
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CheckOutSummaryHistoryScreen(),
                                  fullscreenDialog: true,
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(height: 8),
                        // Conditional print button - dropdown for order types 1 and 4
                        (order.orderTypeId == 1 || order.orderTypeId == 4)
                            ? _buildPrintButtons(order)
                            : _buildActionButton(
                                icon: Icons.print,
                                label: 'พิมพ์',
                                color: Colors.green[700]!,
                                onTap: () => _handlePrint(order),
                              ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Products Table
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
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'สินค้า',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'น้ำหนัก',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'คลัง',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Rows
                      ...order.details!.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var detail = entry.value;
                        return Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            border: idx < order.details!.length - 1
                                ? Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[200]!))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  detail.productName ?? '',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  Global.format(detail.weight!),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  detail.binLocationName ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintButtons(OrderModel order) {
    return Column(
      children: [
        // Full Tax Invoice Button
        GestureDetector(
          onTap: () => _handlePrintWithType(order, 'full_tax'),
          child: Container(
            height: 36,
            width: 200,
            margin: EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.green[700]!.withOpacity(0.2),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.print, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'ใบกำกับภาษีเต็มรูป',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Simple Tax Invoice Button
        GestureDetector(
          onTap: () => _handlePrintWithType(order, 'simple_tax'),
          child: Container(
            height: 36,
            width: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF0288d1),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0288d1).withOpacity(0.2),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.print, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'ใบกำกับภาษีอย่างย่อ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePrintWithType(OrderModel order, String printType) async {
    Global.orderIds!.add(order.orderId);

    if (Global.branch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเลือกสาขาก่อนพิมพ์'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ProgressDialog pr = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: true,
      showLogs: true,
    );
    await pr.show();
    pr.update(message: 'กำลังประมวลผล...');

    try {
      var result = await ApiServices.post(
          '/order/print-order-list/${order.pairId}', Global.requestObj(null));

      var data = jsonEncode(result?.data);
      List<OrderModel> orders = orderListModelFromJson(data);

      var payment = await ApiServices.post(
          '/order/payment/${order.pairId}', Global.requestObj(null));
      Global.paymentList = paymentListModelFromJson(jsonEncode(payment?.data));

      await pr.hide();
      Invoice invoice = Invoice(
        order: order,
        customer: order.customer!,
        payments: Global.paymentList,
        orders: orders,
        items: order.details!,
      );

      // Navigate to appropriate preview based on print type and order type
      _navigateToPreviewWithType(order, invoice, printType);
    } catch (e) {
      await pr.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToPreviewWithType(
      OrderModel order, Invoice invoice, String printType) {
    // Handle order type 1 separately
    if (order.orderTypeId == 1) {
      if (printType == 'full_tax') {
        // Navigate to full tax invoice preview for order type 1
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PdfPreviewPage(
            invoice: invoice,
            billType: 'full',
          ),
        ));
      } else if (printType == 'simple_tax') {
        // Navigate to simple tax invoice preview for order type 1
        // You may need to create a different preview page or pass a parameter
        // to differentiate between full and simple tax invoice for type 1
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PdfPreviewPage(
            invoice: invoice,
            billType: 'short',
          ),
        ));
      }
    }
    // Handle order type 4 separately
    else if (order.orderTypeId == 4) {
      if (printType == 'full_tax') {
        // Navigate to full tax invoice preview for order type 4
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PreviewSellThengPdfPage(
            invoice: invoice,
            billType: 'full',
          ),
        ));
      } else if (printType == 'simple_tax') {
        // Navigate to simple tax invoice preview for order type 4
        // You may need to create a different preview page or pass a parameter
        // to differentiate between full and simple tax invoice for type 4
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PreviewSellThengPdfPage(
            invoice: invoice,
            billType: 'short',
          ),
        ));
      }
    } else {
      // For other order types, use the original navigation logic
      _navigateToPreview(order, invoice);
    }
  }

  Future<void> _handlePrint(OrderModel order) async {
    Global.orderIds!.add(order.orderId);

    if (Global.branch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเลือกสาขาก่อนพิมพ์'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ProgressDialog pr = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: true,
      showLogs: true,
    );
    await pr.show();
    pr.update(message: 'กำลังประมวลผล...');

    try {
      var result = await ApiServices.post(
          '/order/print-order-list/${order.pairId}', Global.requestObj(null));

      var data = jsonEncode(result?.data);
      List<OrderModel> orders = orderListModelFromJson(data);

      var payment = await ApiServices.post(
          '/order/payment/${order.pairId}', Global.requestObj(null));
      Global.paymentList = paymentListModelFromJson(jsonEncode(payment?.data));

      await pr.hide();
      Invoice invoice = Invoice(
        order: order,
        customer: order.customer!,
        payments: Global.paymentList,
        orders: orders,
        items: order.details!,
      );

      // Navigate to appropriate preview based on order type
      _navigateToPreview(order, invoice);
    } catch (e) {
      await pr.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToPreview(OrderModel order, Invoice invoice) {
    switch (order.orderTypeId) {
      case 2:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PdfPreviewPage(
            invoice: invoice,
            billType: 'full',
          ),
        ));
        break;
      case 5:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewRefillGoldPage(invoice: invoice),
            ));
        break;
      case 6:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewSellUsedGoldPage(invoice: invoice),
            ));
        break;
      case 3:
      case 33:
      case 8:
      case 9:
        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PdfThengPreviewPage(invoice: invoice),
          ));
        }
        break;
      case 10:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PreviewRefillThengGoldPage(invoice: invoice),
        ));
        break;
      case 11:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PreviewSellUsedThengGoldPage(invoice: invoice),
        ));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PreviewSellThengPdfPage(
            invoice: invoice,
            billType: 'full',
          ),
        ));
        break;
      case 44:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PreviewBuyThengPdfPage(
            invoice: invoice,
            shop: false,
          ),
        ));
        break;
    }
  }

  cancelOrder(OrderModel order) async {
    // Get current date and order date
    // DateTime currentDate = DateTime.now();
    // DateTime orderDate = DateTime.parse(order.orderDate.toString());
    //
    // // Check if current date is the same as order date
    // if (currentDate.year == orderDate.year &&
    //     currentDate.month == orderDate.month &&
    //     currentDate.day == orderDate.day) {
    //   // Check if time has not passed 00:00 at midnight
    //   if (currentDate.hour < 24 && currentDate.minute < 60) {
        // Call API to cancel order
        try {

          Alert.info(context, 'คุณแน่ใจที่จะยกเลิกคำสั่งซื้อใช่ไหม?', '', 'ตกลง',
              action: () async {

          var result = await ApiServices.post(
            '/order/cancel',
            Global.requestObj({
              "Id": order.id,
            }),
          );

          if (result?.status == "success") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ยกเลิกคำสั่งซื้อสำเร็จแล้ว'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Update the order list
            search();
            setState(() {
              // filterList?.remove(order);

            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ไม่สามารถยกเลิกคำสั่งซื้อได้'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
              });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่สามารถยกเลิกคำสั่งซื้อได้'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
    //   } else {
    //     Alert.warning(context, 'ยกเลิกคำสั่งซื้อ',
    //         'คุณสามารถยกเลิกคำสั่งซื้อได้เฉพาะภายในวันเดียวกันก่อนเวลาเที่ยงคืน', 'OK',
    //         action: () {});
    //   }
    // } else {
    //   Alert.warning(context, 'ยกเลิกคำสั่งซื้อ',
    //       'คุณสามารถยกเลิกคำสั่งซื้อได้เฉพาะภายในวันที่ทำรายการเท่านั้น', 'OK',
    //       action: () {});
    // }
  }
}
