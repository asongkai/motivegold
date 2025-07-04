import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/responsive_screen.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';

class RefillGoldHistoryScreen extends StatefulWidget {
  const RefillGoldHistoryScreen({super.key});

  @override
  State<RefillGoldHistoryScreen> createState() =>
      _RefillGoldHistoryScreenState();
}

class _RefillGoldHistoryScreenState extends State<RefillGoldHistoryScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;
  final TextEditingController yearCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  ValueNotifier<dynamic>? yearNotifier;
  ValueNotifier<dynamic>? monthNotifier;

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
      var result =
          await ApiServices.post('/order/all/type/5', Global.reportRequestObj({"year": yearCtrl.text, "month": monthCtrl.text}));
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
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายการประวัติการเติมทอง",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    getProportionateScreenWidth(
                      8,
                    ),
                  ),
                  topRight: Radius.circular(
                    getProportionateScreenWidth(
                      8,
                    ),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: getProportionateScreenWidth(0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ปี',
                                      style: TextStyle(
                                          fontSize: 16.sp),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: MiraiDropDownMenu<int>(
                                        key: UniqueKey(),
                                        children: Global.genYear(),
                                        space: 4,
                                        maxHeight: 360,
                                        showSearchTextField: true,
                                        selectedItemBackgroundColor:
                                        Colors.transparent,
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
                                        onChanged: (int value) {
                                          yearCtrl.text = value.toString();
                                          yearNotifier!.value = value;
                                          search();
                                        },
                                        child: DropDownObjectChildWidget(
                                          key: GlobalKey(),
                                          fontSize: 16.sp,
                                          projectValueNotifier: yearNotifier!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'เดือน',
                                      style: TextStyle(
                                          fontSize: 16.sp),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: MiraiDropDownMenu<int>(
                                        key: UniqueKey(),
                                        children: Global.genMonth(),
                                        space: 4,
                                        maxHeight: 360,
                                        showSearchTextField: true,
                                        selectedItemBackgroundColor:
                                        Colors.transparent,
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
                                        onChanged: (int value) {
                                          monthCtrl.text = value.toString();
                                          monthNotifier!.value = value;
                                          search();
                                        },
                                        child: DropDownObjectChildWidget(
                                          key: GlobalKey(),
                                          fontSize: 16.sp,
                                          projectValueNotifier:
                                          monthNotifier!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(3.0),
                        vertical: getProportionateScreenHeight(5.0),
                      ),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(bgColor3)),
                        onPressed: search,
                        child: Text(
                          'ค้นหา'.tr(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            loading
                ? Container(
                margin: const EdgeInsets.only(top: 100),
                child: const LoadingProgress())
                : filterList!.isEmpty
                ? const NoDataFoundWidget()
                : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                        itemCount: orders!.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return dataCard(orders![index], index);
                        }),
                  ),
                ),
          ],
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
                          paddedText('${e.binLocationName}',
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
