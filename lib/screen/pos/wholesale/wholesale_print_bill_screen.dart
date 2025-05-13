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

class WholeSalePrintBillScreen extends StatefulWidget {
  const WholeSalePrintBillScreen({super.key});

  @override
  State<WholeSalePrintBillScreen> createState() =>
      _WholeSalePrintBillScreenState();
}

class _WholeSalePrintBillScreenState extends State<WholeSalePrintBillScreen> {
  int currentIndex = 1;
  Screen? size;
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  bool loading = false;
  List<OrderModel> orders = [];

  @override
  void initState() {
    // implement initState
    super.initState();
    loadOrder();
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
      // motivePrint(payment?.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> dump = orderListModelFromJson(data);
        setState(() {
          orders = dump;
          Global.paymentList =
              paymentListModelFromJson(jsonEncode(payment?.data));
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
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: orders.isEmpty
                    ? const Center(
                        child: NoDataFoundWidget(),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          getProportionateScreenWidth(0.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SingleChildScrollView(
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              color: bgColor2,
                                            ),
                                            child: ListView.builder(
                                                itemCount: orders.length,
                                                itemBuilder: (context, index) {
                                                  return _itemOrderList(
                                                      order: orders[index],
                                                      index: index);
                                                }),
                                          ),
                                        ),
                                      ],
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
    );
  }

  void checkout() async {
    setState(() {});
  }

  Widget _itemOrderList({required OrderModel order, required index}) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    ProductListTileData(
                      orderId: order.orderId,
                      weight: null,
                      showTotal: false,
                      type: order.orderTypeName,
                    ),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      children: [
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('น้ำหนัก',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('ราคา',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                          ],
                        ),
                        ...order.details!.map(
                          (e) => TableRow(
                            decoration: const BoxDecoration(),
                            children: [
                              paddedTextBigXL(e.productName),
                              paddedText(Global.format(e.weight!),
                                  align: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                              paddedText(
                                  Global.format(order.orderTypeId == 5
                                      ? e.priceExcludeTax!
                                      : e.priceIncludeTax!),
                                  align: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ],
                          ),
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'ผลรวมย่อย',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: size?.getWidthPx(8)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  Global.format(
                                      Global.getOrderWeightTotalAmountApi(
                                          order.details)),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  Global.format(
                                      Global.getOrderSubTotalAmountApiWholeSale(
                                          order.orderTypeId!, order.details)),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'ส่วนลด',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: size?.getWidthPx(8)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(Global.format(order.discount ?? 0),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'ยอดรวมทั้งหมด',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: size?.getWidthPx(8)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  '${Global.format(Global.getOrderTotalWeight(order.details!))}',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  Global.format(
                                      Global.getOrderGrantTotalAmountApi(
                                          Global
                                              .getOrderSubTotalAmountApiWholeSale(
                                                  order.orderTypeId!,
                                                  order.details),
                                          order.discount)),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // loadOrder();
                        // return;
                        final ProgressDialog pr = ProgressDialog(context,
                            type: ProgressDialogType.normal,
                            isDismissible: true,
                            showLogs: true);
                        await pr.show();
                        pr.update(message: 'processing'.tr());

                        try {
                          var payment = await ApiServices.post(
                              '/order/payment/${order.pairId}',
                              Global.requestObj(null));
                          Global.paymentList = paymentListModelFromJson(
                              jsonEncode(payment?.data));

                          await pr.hide();
                          Invoice invoice = Invoice(
                              order: order,
                              customer: order.customer!,
                              payments: Global.paymentList,
                              orders: orders,
                              items: order.details!);

                          if (order.orderTypeId == 5) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PreviewRefillGoldPage(
                                          invoice: invoice,
                                        )));
                          }

                          if (order.orderTypeId == 6) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PreviewSellUsedGoldPage(
                                          invoice: invoice,
                                        )));
                          }

                          if (order.orderTypeId == 10) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PreviewRefillThengGoldPage(
                                      invoice: invoice,
                                    )));
                          }

                          if (order.orderTypeId == 11) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PreviewSellUsedThengGoldPage(
                                          invoice: invoice,
                                        )));
                          }
                        } catch (e) {
                          await pr.hide();
                        }
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(
                          Icons.print,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // const Divider(),
        ],
      ),
    );
  }
}
