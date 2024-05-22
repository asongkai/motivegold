import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/refill.dart';
import 'package:motivegold/model/sell.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../api/api_services.dart';
import '../../utils/alert.dart';
import '../../utils/global.dart';
import '../../utils/responsive_screen.dart';
import '../../utils/util.dart';
import '../../widget/empty.dart';
import '../../widget/loading/loading_progress.dart';
import '../pos/print_bill_screen.dart';

class PosOrderHistoryScreen extends StatefulWidget {
  const PosOrderHistoryScreen({super.key});

  @override
  State<PosOrderHistoryScreen> createState() => _PosOrderHistoryScreenState();
}

class _PosOrderHistoryScreenState extends State<PosOrderHistoryScreen> {
  bool loading = false;
  List<OrderModel>? list = [];
  Screen? size;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
          await ApiServices.post('/order/all', Global.requestObj(null));
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

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการประวัติการซื้อขายทองคำ'),
        actions: const [],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : list!.isEmpty
                ? const EmptyContent()
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
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: ListTile(
                  // leading: SizedBox(
                  //   width: 100,
                  //   child: Image.asset(
                  //     'assets/images/Gold-Chain-PNG.png',
                  //     fit: BoxFit.fitHeight,
                  //   ),
                  // ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${list.orderId.toString()}',
                        style: TextStyle(fontSize: size?.getWidthPx(8)),
                      ),
                      Text(
                        Global.formatDate(list.orderDate.toString()),
                        style: TextStyle(color: Colors.green, fontSize: size!.getWidthPx(5)),
                      ),
                    ],
                  ),
                  subtitle: Table(
                    children: [
                      TableRow(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('สินค้า',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(8),
                                      color: Colors.orange)),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('น้ำหนัก',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(8),
                                      color: Colors.orange)),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
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
                                style: TextStyle(fontSize: size?.getWidthPx(7))),
                            paddedText(formatter.format(e.weight!),
                                align: TextAlign.center,
                                style: TextStyle(fontSize: size?.getWidthPx(7))),
                            paddedText(e.toBinLocationName ?? '',
                                align: TextAlign.center,
                                style: TextStyle(fontSize: size?.getWidthPx(7))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded(
              //   flex: 1,
              //   child: Row(
              //     children: [
              //       GestureDetector(
              //         onTap: () {
              //           // Navigator.push(
              //           //     context,
              //           //     MaterialPageRoute(
              //           //         builder: (context) => EditProductScreen(
              //           //             showBackButton: true,
              //           //             product: refillList[index],
              //           //             index: index
              //           //         ),
              //           //         fullscreenDialog: true))
              //           //     .whenComplete(() {
              //           //   loadData();
              //           // });
              //         },
              //         child: Container(
              //           height: 50,
              //           width: 60,
              //           decoration: BoxDecoration(
              //               color: Colors.teal,
              //               borderRadius: BorderRadius.circular(8)),
              //           child: const Icon(
              //             Icons.edit,
              //             color: Colors.white,
              //           ),
              //         ),
              //       ),
              //       const Spacer(),
              //       GestureDetector(
              //         onTap: () {
              //           removeProduct(refillList[index].id!, index);
              //         },
              //         child: Container(
              //           height: 50,
              //           width: 60,
              //           decoration: BoxDecoration(
              //               color: Colors.red,
              //               borderRadius: BorderRadius.circular(8)),
              //           child: const Icon(
              //             Icons.delete,
              //             color: Colors.white,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // )
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: (list.orderTypeId == 1) ? Colors.teal : Colors.orange, borderRadius: BorderRadius.circular(10.0)),
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
                          (list.orderTypeId == 1) ? Icons.check : Icons.pending_actions,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Text(
                    list.orderTypeId == 1 ? 'ทองใหม่' : 'ทองเก่า',
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
}
