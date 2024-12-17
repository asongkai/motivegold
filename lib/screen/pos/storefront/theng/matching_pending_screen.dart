import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/screen/pos/storefront/theng/buy_theng_matching_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/matching_menu_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/menu_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class MatchingPendingScreen extends StatefulWidget {
  const MatchingPendingScreen({super.key});

  @override
  State<MatchingPendingScreen> createState() => _MatchingPendingScreenState();
}

class _MatchingPendingScreenState extends State<MatchingPendingScreen> {
  bool loading = false;
  List<OrderModel>? list = [];
  Screen? size;
  int? cartCount;
  int? holdCount;

  @override
  void initState() {
    super.initState();
    loadData();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      interval();
    });

  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post(
          '/order/matching/PENDING', Global.requestObj(null));
      // motivePrint(result!.data);
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> products = orderListModelFromJson(data);
        setState(() {
          list = products;
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

  interval() async {
    var result = await ApiServices.post(
        '/order/matching/PENDING', Global.requestObj(null));
    // motivePrint(result!.data);
    if (result?.status == "success") {
      var data = jsonEncode(result?.data);
      List<OrderModel> products = orderListModelFromJson(data);
      if (mounted) {
        setState(() {
          list = products;
        });
      }
    } else {
      list = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการที่รอดำเนินการ'),
        actions: const [],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : list!.isEmpty
                ? const Center(child: NoDataFoundWidget())
                : SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: list!.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              return dataCard(list![index], index);
                            }),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget dataCard(OrderModel list, int index) {
    return Stack(
      children: [
        Card(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        '#${list.orderId.toString()}',
                        style: TextStyle(fontSize: size?.getWidthPx(8)),
                      ),
                      Text(
                        Global.formatDate(list.orderDate.toString()),
                        style: TextStyle(
                            color: Colors.green, fontSize: size!.getWidthPx(8)),
                      ),
                    ],
                  ),
                  subtitle: Table(
                    children: [
                      TableRow(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Text('สินค้า',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(8),
                                      color: Colors.orange)),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Text('น้ำหนัก',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(8),
                                      color: Colors.orange)),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Text('คลังสินค้า',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(8),
                                      color: Colors.orange)),
                            ),
                          ),
                        ],
                      ),
                      ...list.details!.map(
                        (e) => TableRow(
                          decoration: const BoxDecoration(),
                          children: [
                            paddedText(e.productName,
                                align: TextAlign.center,
                                style:
                                    TextStyle(fontSize: size?.getWidthPx(8))),
                            paddedText(formatter.format(e.weight!),
                                align: TextAlign.center,
                                style:
                                    TextStyle(fontSize: size?.getWidthPx(8))),
                            paddedText('${e.binLocationName}',
                                align: TextAlign.center,
                                style:
                                    TextStyle(fontSize: size?.getWidthPx(8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (list.orderStatus == 'PENDING')
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  width: 170,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            sellToShop(list);
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'ขายคืนร้าน',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size!.getWidthPx(8)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            customerTakeGold(list);
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.mobile_screen_share_outlined,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'รับทอง',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size!.getWidthPx(8)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
        Positioned(
          // right: 0,
          top: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: Global.checkMatchingOrder(list.orderDate!),
                  borderRadius: BorderRadius.circular(10.0)),
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: RawMaterialButton(
                        elevation: 10.0,
                        child: Icon(
                          (list.orderStatus == 'SUCCESS')
                              ? Icons.check
                              : Icons.pending_actions,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Text(
                    '${list.orderStatus!} (${Global.getMatchingOrderDays(list.orderDate!)} วัน)',
                    style: const TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );


  }

  void removeProduct(int id, int i) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result = await ApiServices.delete('/product', id);
      await pr.hide();
      if (result?.status == "success") {
        list!.removeAt(i);
        setState(() {});
      } else {
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
              action: () {});
        }
      }
    } catch (e) {
      await pr.hide();
      if (mounted) {
        Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
            action: () {});
      }
    }
  }

  void sellToShop(OrderModel order) async {
    Global.orders!.clear();
    int? typeId = 33;
    Global.posOrder = order;
    Global.posOrder?.orderTypeId = typeId;
    Global.customer = order.customer;
    Global.sellThengOrderDetail!.clear();
    Global.buyThengOrderDetail!.clear();
    if (order.orderTypeId == 1) {
      Global.posIndex = 0;
      Global.sellOrderDetail = order.details;
    } else if (order.orderTypeId == 2) {
      Global.posIndex = 1;
      Global.buyOrderDetail = order.details;
    } else if (order.orderTypeId == 3 || order.orderTypeId == 4) {
      Global.posIndex = 0;
      Global.sellThengOrderDetail =  orderDetailListModelFromJson(jsonEncode(order.details));
      // Global.buyThengOrderDetail = orderDetailListModelFromJson(jsonEncode(order.details));
    } else if (order.orderTypeId == 33 || order.orderTypeId == 44) {
      Global.posIndex = 1;
      Global.buyThengOrderDetail = orderDetailListModelFromJson(jsonEncode(order.details));
      // Global.sellThengOrderDetail = orderDetailListModelFromJson(jsonEncode(order.details));
    }
    // OrderModel _order = OrderModel(
    //     orderId: result.data,
    //     orderDate: DateTime.now().toUtc(),
    //     details: Global.sellThengOrderDetail!,
    //     orderTypeId: 3,
    //     orderStatus: 'PENDING');
    // final data = _order.toJson();
    // Global.orders?.add(OrderModel.fromJson(data));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ThengSaleMatchingMenuScreen(
                  title: 'Matching',
                ))).whenComplete(() {
      loadData();
      setState(() {});
    });
  }

  void customerTakeGold(OrderModel order) async {
    Global.orders!.clear();
    // order.orderTypeId = 4;
    int? typeId = 4;
    Global.posOrder = order;
    Global.posOrder?.orderTypeId = typeId;
    Global.customer = order.customer;

    if (order.orderTypeId == 1) {
      Global.posIndex = 0;
      Global.sellOrderDetail = order.details;
    } else if (order.orderTypeId == 2) {
      Global.posIndex = 1;
      Global.buyOrderDetail = order.details;
    } else if (order.orderTypeId == 3 || order.orderTypeId == 4) {
      Global.posIndex = 0;
      Global.sellThengOrderDetail = order.details;
      Global.buyThengOrderDetail = order.details;
    } else if (order.orderTypeId == 33 || order.orderTypeId == 44) {
      Global.posIndex = 1;
      Global.buyThengOrderDetail = order.details;
      Global.sellThengOrderDetail = order.details;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ThengSaleMenuScreen(
                  title: 'Matching',
                ))).whenComplete(() {
      loadData();
      setState(() {});
    });
  }

  void refreshCart(dynamic childValue) {
    setState(() {
      cartCount = int.parse(childValue);
    });
  }

  void refreshHold(dynamic childValue) {
    setState(() {
      holdCount = int.parse(childValue);
    });
  }
}
