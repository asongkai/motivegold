import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/responsive_screen.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class RefillGoldHistoryScreen extends StatefulWidget {
  const RefillGoldHistoryScreen({super.key});

  @override
  State<RefillGoldHistoryScreen> createState() =>
      _RefillGoldHistoryScreenState();
}

class _RefillGoldHistoryScreenState extends State<RefillGoldHistoryScreen> {
  bool loading = false;
  List<OrderModel>? refillList = [];
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
          await ApiServices.post('/refill/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> products = orderListModelFromJson(data);
        setState(() {
          refillList = products;
        });
      } else {
        refillList = [];
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
        title: const Text('รายการประวัติการเติมทอง'),
        actions: const [],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : refillList!.isEmpty
                ? const EmptyContent()
                : SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: refillList!.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              return dataCard(refillList![index], index);
                            }),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget dataCard(OrderModel list, int index) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => PreviewRefillGoldPage(
        //           refill: list,
        //         )));
      },
      child: Card(
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: ListTile(
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
                      style: TextStyle(
                          color: Colors.green, fontSize: size?.getWidthPx(5)),
                    )
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
                          paddedText(Global.format(e.weight ?? 0),
                              align: TextAlign.center,
                              style: TextStyle(fontSize: size?.getWidthPx(7))),
                          paddedText('${e.toBinLocationName}',
                              align: TextAlign.center,
                              style: TextStyle(fontSize: size?.getWidthPx(7))),
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
    );
  }
}
