import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/response.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/refill/preview.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/used/preview.dart';
import 'package:motivegold/screen/pos/wholesale/theng/refill/preview.dart';
import 'package:motivegold/screen/pos/wholesale/theng/used/preview.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/widget/product_list_tile.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sizer/sizer.dart';

class WholeSalePrintBillScreen extends StatefulWidget {
  const WholeSalePrintBillScreen({super.key});

  @override
  State<WholeSalePrintBillScreen> createState() =>
      _WholeSalePrintBillScreenState();
}

class _WholeSalePrintBillScreenState extends State<WholeSalePrintBillScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 1;
  Screen? size;
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  bool loading = false;
  List<OrderModel> orders = [];
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    loadOrder();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    discountCtrl.dispose();
    super.dispose();
  }

  void loadOrder() async {
    setState(() {
      loading = true;
    });
    try {
      Response? result;
      Response? payment;
      if (Global.pairId == null) {
        result = await ApiServices.post(
            '/order/order-list', encoder.convert(Global.orderIds));
      } else {
        result = await ApiServices.post(
            '/order/print-order-list/${Global.pairId}',
            Global.requestObj(null));
        payment = await ApiServices.post(
            '/order/payment/${Global.pairId}', Global.requestObj(null));
      }

      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> dump = orderListModelFromJson(data);
        setState(() {
          orders = dump;
          Global.paymentList =
              paymentListModelFromJson(jsonEncode(payment?.data));
        });
        _animationController?.forward();
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
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("พิมพ์บิล",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: loading
            ? const ModernLoadingWidget()
            : GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: orders.isEmpty
              ? const ModernEmptyState()
              : _fadeAnimation != null
              ? FadeTransition(
            opacity: _fadeAnimation!,
            child: RefreshIndicator(
              onRefresh: () async => loadOrder(),
              child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.easeOutBack,
                      child: _itemOrderList(
                          order: orders[index],
                          index: index),
                    );
                  }),
            ),
          )
              : RefreshIndicator(
            onRefresh: () async => loadOrder(),
            child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _itemOrderList(
                      order: orders[index],
                      index: index);
                }),
          ),
        ),
      ),
    );
  }

  void checkout() async {
    setState(() {});
  }

  Widget _itemOrderList({required OrderModel order, required index}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: ProductListTileData(
                        orderId: order.orderId,
                        weight: null,
                        showTotal: false,
                        type: order.orderTypeName,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'น้ำหนัก',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'ราคา',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ...order.details!.asMap().entries.map(
                                (entry) {
                              int idx = entry.key;
                              var e = entry.value;
                              return TableRow(
                                decoration: BoxDecoration(
                                  color: idx % 2 == 0 ? Colors.white : const Color(0xFFFAFBFC),
                                ),
                                children: [
                                  paddedTextBigXL(e.productName),
                                  paddedText(order.orderTypeId == 4 || order.orderTypeId == 44 || order.orderTypeId == 10 || order.orderTypeId == 11 ?
                                  Global.format4(e.weight!) : Global.format(e.weight!),
                                    align: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                  paddedText(
                                    Global.format(order.orderTypeId == 5
                                        ? e.priceExcludeTax!
                                        : e.priceIncludeTax!),
                                    align: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'ผลรวมย่อย',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  order.orderTypeId == 4 || order.orderTypeId == 44 || order.orderTypeId == 10 || order.orderTypeId == 11 ?
                                  Global.format4(
                                      Global.getOrderWeightTotalAmountApi(
                                          order.details)) : Global.format(
                                      Global.getOrderWeightTotalAmountApi(
                                          order.details)),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  Global.format(
                                      Global.getOrderSubTotalAmountApiWholeSale(
                                          order.orderTypeId!, order.details)),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            decoration: const BoxDecoration(color: Colors.white),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'ส่วนลด',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  Global.format(order.discount ?? 0),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F766E).withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'ยอดรวมทั้งหมด',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: size?.getWidthPx(8),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  '${order.orderTypeId == 4 || order.orderTypeId == 44 || order.orderTypeId == 10 || order.orderTypeId == 11 ? Global.format4(Global.getOrderTotalWeight(order.details!)) : Global.format(Global.getOrderTotalWeight(order.details!))}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: size?.getWidthPx(8),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  Global.format(
                                      Global.getOrderGrantTotalAmountApi(
                                          Global
                                              .getOrderSubTotalAmountApiWholeSale(
                                              order.orderTypeId!,
                                              order.details),
                                          order.discount, order.addPrice ?? 0)),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: size?.getWidthPx(8),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _handlePrintOrder(order),
                      child: Container(
                        height: 80,
                        width: 80,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F766E).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.print,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePrintOrder(OrderModel order) async {
    final ProgressDialog pr = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: true,
      showLogs: true,
    );

    await pr.show();
    pr.update(message: 'กำลังเตรียมข้อมูล...');

    try {
      var payment = await ApiServices.post(
          '/order/payment/${order.pairId}', Global.requestObj(null));
      Global.paymentList =
          paymentListModelFromJson(jsonEncode(payment?.data));

      await pr.hide();
      Invoice invoice = Invoice(
          order: order,
          customer: order.customer!,
          payments: Global.paymentList,
          orders: orders,
          items: order.details!);

      _navigateToPreview(order, invoice);
    } catch (e) {
      await pr.hide();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToPreview(OrderModel order, Invoice invoice) {
    switch (order.orderTypeId) {
      case 5:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewRefillGoldPage(
                  invoice: invoice,
                  goHome: true,
                )));
        break;
      case 6:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewSellUsedGoldPage(
                  invoice: invoice,
                  goHome: true,
                )));
        break;
      case 10:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewRefillThengGoldPage(
                  invoice: invoice,
                  goHome: true,
                )));
        break;
      case 11:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewSellUsedThengGoldPage(
                  invoice: invoice,
                  goHome: true,
                )));
        break;
    }
  }
}

class ModernLoadingWidget extends StatelessWidget {
  const ModernLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'กำลังโหลดข้อมูล...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ModernEmptyState extends StatelessWidget {
  const ModernEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ไม่มีรายการบิลที่ต้องพิมพ์',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'เมื่อมีรายการใหม่จะแสดงที่นี่',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}