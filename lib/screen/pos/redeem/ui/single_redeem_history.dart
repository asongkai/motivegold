import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/screen/pos/checkout_summary_history_screen.dart';
import 'package:motivegold/screen/pos/redeem/bill/preview.dart';
import 'package:motivegold/screen/pos/redeem/ui/redeem_summary_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sizer/sizer.dart';

class SingleRedeemHistoryScreen extends StatefulWidget {
  const SingleRedeemHistoryScreen({super.key, this.productType});

  final ProductTypeModel? productType;

  @override
  State<SingleRedeemHistoryScreen> createState() =>
      _SingleRedeemHistoryScreenState();
}

class _SingleRedeemHistoryScreenState extends State<SingleRedeemHistoryScreen> {
  bool loading = false;
  List<RedeemModel>? list = [];
  List<RedeemModel?>? filterList = [];
  Screen? size;
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController customerFilterCtrl = TextEditingController();

  ProductTypeModel? selectedRedeemType;
  static ValueNotifier<dynamic>? redeemTypeNotifier;

  CustomerModel? selectedCustomer;
  static ValueNotifier<dynamic>? customerNotifier;

  List<CustomerModel>? customers = [];
  bool loadingCustomer = false;
  bool isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    selectedRedeemType = widget.productType;
    redeemTypeNotifier = ValueNotifier<ProductTypeModel>(selectedRedeemType ??
        ProductTypeModel(id: 0, code: '', name: 'เลือกประเภทธุรกรรม'));
    customerNotifier = ValueNotifier<CustomerModel?>(null);
    if (widget.productType != null) {
      search();
    }
  }

  void search() async {
    if (selectedRedeemType == null &&
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
          '/redeem/all/search',
          Global.requestObj({
            "year": 0,
            "month": 0,
            "fromDate": fromDateCtrl.text.isNotEmpty
                ? DateTime.parse(fromDateCtrl.text).toString()
                : null,
            "toDate": toDateCtrl.text.isNotEmpty
                ? DateTime.parse(toDateCtrl.text).toString()
                : null,
            "orderTypeId": selectedRedeemType?.id,
            "customerId": selectedCustomer?.id,
            "customerFilter": customerFilterCtrl.text,
          }));

      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<RedeemModel> products = redeemListModelFromJson(data);
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
      selectedRedeemType = null;
      selectedCustomer = null;
      fromDateCtrl.clear();
      toDateCtrl.clear();
      customerFilterCtrl.clear();
      redeemTypeNotifier = ValueNotifier<ProductTypeModel?>(null);
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
          title: Text("รายการประวัติธุรกรรมไถ่ถอน - ขายฝาก",
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
                                                        'redeem_type_dropdown'),
                                                    children: redeemTypes(),
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
                                                      selectedRedeemType =
                                                          value;
                                                      redeemTypeNotifier!
                                                          .value = value;
                                                      search();
                                                    },
                                                    child:
                                                        DropDownObjectChildWidget(
                                                      key: GlobalKey(),
                                                      fontSize: 12.sp,
                                                      projectValueNotifier:
                                                          redeemTypeNotifier!,
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

  Widget _buildModernOrderCard(RedeemModel order, int index) {
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
                                  '#${order.redeemId}',
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
                                  color:
                                      colorTypeRedeem(order).withOpacity(0.1),
                                  border:
                                      Border.all(color: colorTypeRedeem(order)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  dataTypeRedeem(order),
                                  style: TextStyle(
                                    color: colorTypeRedeem(order),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              if (order.redeemStatus != 'CANCEL')
                                GestureDetector(
                                  onTap: () => _cancelRedeem(order),
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
                              if (order.redeemStatus == 'CANCEL')
                                GestureDetector(
                                  onTap: () {},
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
                                'วันที่เอกสาร: ${Global.formatDate(order.redeemDate.toString())}',
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
                          color: Colors.blue[700]!,
                          onTap: () {
                            Global.pairId = order.pairId;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RedeemSummaryHistoryScreen(),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        _buildActionButton(
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
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                'จำนวนเงินรวมที่ลูกค้าต้องชำระ (บาท)',
                                textAlign: TextAlign.right,
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
                                  'ทองคำรูปพรรณ 96.5%', //detail.productName ?? '',
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
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  '${Global.format(detail.paymentAmount)}', //detail.binLocationName ?? '',
                                  textAlign: TextAlign.right,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              label,
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

  Future<void> _handlePrint(RedeemModel order) async {
    Global.orderIds!.add(order.redeemId ?? '');

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
          '/redeem/redeem-list/${order.pairId}', Global.requestObj(null));

      var data = jsonEncode(result?.data);
      List<RedeemModel> redeems = redeemListModelFromJson(data);

      var payment = await ApiServices.post(
          '/order/payment/${order.pairId}', Global.requestObj(null));
      await pr.hide();
      Global.paymentList = paymentListModelFromJson(jsonEncode(payment?.data));

      InvoiceRedeem invoice = InvoiceRedeem(
          order: order,
          customer: order.customer!,
          payments: Global.paymentList,
          orders: redeems,
          items: order.details!);

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

  void _navigateToPreview(RedeemModel order, InvoiceRedeem invoice) {
    switch (order.redeemTypeId) {
      case 1:
      case 2:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PdfPreviewRedeemPage(invoice: invoice),
        ));
        break;
    }
  }

  Future<void> _cancelRedeem(RedeemModel redeem) async {
    try {
      Alert.info(
        context,
        'คุณแน่ใจที่จะยกเลิกรายการไถ่ถอนใช่ไหม?',
        'การดำเนินการนี้จะยกเลิกรายการไถ่ถอนและไม่สามารถย้อนกลับได้',
        'ตกลง',
        action: () async {
          try {
            var result = await ApiServices.post(
              '/redeem/cancel',
              Global.requestObj({
                "Id": redeem.id,
              }),
            );

            if (result?.status == "success") {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ยกเลิกรายการไถ่ถอนสำเร็จแล้ว'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Refresh the list to show updated status
                search();
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result?.message ?? 'ไม่สามารถยกเลิกรายการไถ่ถอนได้'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถยกเลิกรายการไถ่ถอนได้'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
