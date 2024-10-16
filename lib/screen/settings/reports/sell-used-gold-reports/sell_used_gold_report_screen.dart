import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/settings/reports/sell-used-gold-reports/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:quiver/time.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';

class SellUsedGoldReportScreen extends StatefulWidget {
  const SellUsedGoldReportScreen({super.key});

  @override
  State<SellUsedGoldReportScreen> createState() => _SellUsedGoldReportScreenState();
}

class _SellUsedGoldReportScreenState extends State<SellUsedGoldReportScreen> {
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
    loadProducts();
    // search();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });

    // try {
      var result = await ApiServices.post('/order/all/type/6',
          Global.requestObj({"year": yearCtrl.text, "month": monthCtrl.text}));
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
    // } catch (e) {
    //   if (kDebugMode) {
    //     print(e.toString());
    //   }
    // }
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

    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายงานขายทองเก่า'),
        actions: [
          GestureDetector(
            onTap: () {
              if (filterList!.isEmpty) {
                Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PreviewSellUsedGoldReportPage(
                    orders: filterList!,
                    type: 1,
                    date: DateTime.parse("${yearCtrl.text}-${twoDigit(int.parse(monthCtrl.text))}-01"),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.print,
                  size: 50,
                ),
                Text(
                  'พิมพ์แบบเรียงเบอร์',
                  style: TextStyle(fontSize: size.getWidthPx(6)),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: () {
              List<OrderModel> dailyList = genDailyList(filterList);
              if (dailyList.isEmpty) {
                Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PreviewSellUsedGoldReportPage(
                    orders: dailyList,
                    type: 2,
                    date: DateTime.parse("${yearCtrl.text}-${twoDigit(int.parse(monthCtrl.text))}-01"),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.print,
                  size: 50,
                ),
                Text(
                  'พิมพ์แบบรายวัน',
                  style: TextStyle(fontSize: size.getWidthPx(6)),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
              child: Column(
            children: [
              SizedBox(
                child: Container(
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
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
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
                                              fontSize: size.getWidthPx(6)),
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
                                            showSelectedItemBackgroundColor:
                                                true,
                                            itemWidgetBuilder: (
                                              int index,
                                              int? project, {
                                              bool isItemSelected = false,
                                            }) {
                                              return DropDownItemWidget(
                                                project: project,
                                                isItemSelected: isItemSelected,
                                                firstSpace: 10,
                                                fontSize: size.getWidthPx(6),
                                              );
                                            },
                                            onChanged: (int value) {
                                              yearCtrl.text = value.toString();
                                              yearNotifier!.value = value;
                                              search();
                                            },
                                            child: DropDownObjectChildWidget(
                                              key: GlobalKey(),
                                              fontSize: size.getWidthPx(6),
                                              projectValueNotifier:
                                                  yearNotifier!,
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
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
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
                                              fontSize: size.getWidthPx(6)),
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
                                            showSelectedItemBackgroundColor:
                                                true,
                                            itemWidgetBuilder: (
                                              int index,
                                              int? project, {
                                              bool isItemSelected = false,
                                            }) {
                                              return DropDownItemWidget(
                                                project: project,
                                                isItemSelected: isItemSelected,
                                                firstSpace: 10,
                                                fontSize: size.getWidthPx(6),
                                              );
                                            },
                                            onChanged: (int value) {
                                              monthCtrl.text = value.toString();
                                              monthNotifier!.value = value;
                                              search();
                                            },
                                            child: DropDownObjectChildWidget(
                                              key: GlobalKey(),
                                              fontSize: size.getWidthPx(6),
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
              ),
              const Divider(
                thickness: 1.0,
              ),
              loading
                  ? Container(
                      margin: const EdgeInsets.only(top: 100),
                      child: const LoadingProgress())
                  : productCard(filterList!),
            ],
          )),
        ),
      ),
    );
  }

  Widget productCard(List<OrderModel?> ods) {
    return filterList!.isEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 100),
            child: const EmptyContent())
        : Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(color: Colors.grey[300]!),
                  children: [
                    TableRow(children: [
                      paddedTextBigL('วัน/เดือน/ปี', align: TextAlign.center),
                      paddedTextBigL('เลขท่ีใบสําคัญรับเงิน', align: TextAlign.center),
                      paddedTextBigL('ผู้ซื้อ', align: TextAlign.center),
                      paddedTextBigL('เลขประจําตัวผู้เสียภาษี', align: TextAlign.center),
                      paddedTextBigL('รายการสินค้า', align: TextAlign.center),
                      paddedTextBigL('น้ําหนัก (กรัม) \n(น.น.สินค้า/น.น.96.5)', align: TextAlign.center),
                      paddedTextBigL('จํานวนเงิน (บาท)', align: TextAlign.center),
                    ]),
                    ...ods.map((e) => TableRow(
                          decoration: const BoxDecoration(),
                          children: [
                            paddedTextBigL(
                                Global.dateOnly(e!.orderDate.toString()), align: TextAlign.center),
                            paddedTextBigL(e.orderId, align: TextAlign.center),
                            paddedTextBigL('${e.customer!.firstName!} ${e.customer!.lastName!}', align: TextAlign.center),
                            paddedTextBigL(Global.company != null
                                ? Global.company!.taxNumber ?? ''
                                : '', align: TextAlign.center),
                            paddedTextBigL('ทองเก่า', align: TextAlign.center),
                            paddedTextBigL('${Global.format(getWeight(e))}/${Global.format(getWeight(e))}', align: TextAlign.right),
                            paddedTextBigL(Global.format(e.priceIncludeTax ?? 0), align: TextAlign.right)
                          ],
                        )),
                    TableRow(children: [
                      paddedTextBigL('', style: const TextStyle(fontSize: 14)),
                      paddedTextBigL(''),
                      paddedTextBigL(''),
                      paddedTextBigL(''),
                      paddedTextBigL('รวมท้ังหมด', align: TextAlign.right),
                      paddedTextBigL('${Global.format(getWeightTotal(ods))}/${Global.format(getWeightTotal(ods))}', align: TextAlign.right),
                      paddedTextBigL(Global.format(priceIncludeTaxTotal(ods)), align: TextAlign.right),
                    ])
                  ],
                ),
              ),
            ),
          );
  }

  List<OrderModel> genDailyList(List<OrderModel?>? filterList) {
    List<OrderModel> orderList = [];
    int days = daysInMonth(int.parse(yearCtrl.text), int.parse(monthCtrl.text));
    for (int i = 1; i <= days; i++) {
      DateTime? monthDate = DateTime.tryParse(
          '${yearCtrl.text}-${twoDigit(int.parse(monthCtrl.text))}-${twoDigit(i)}');

      motivePrint(monthDate);

      var dateList = filterList
          ?.where((element) =>
              Global.dateOnly(element!.orderDate.toString()) ==
              Global.dateOnly(monthDate.toString()))
          .toList();
      if (dateList!.isNotEmpty) {
        var order = OrderModel(
            orderId: '${dateList.first?.orderId} - ${dateList.last?.orderId}',
            orderDate: monthDate,
            customerId: 0,
            weight: getWeightTotal(dateList),
            priceIncludeTax: priceIncludeTaxTotal(dateList),
            purchasePrice: purchasePriceTotal(dateList),
            priceDiff: priceDiffTotal(dateList),
            taxBase: taxBaseTotal(dateList),
            taxAmount: taxAmountTotal(dateList),
            priceExcludeTax: priceExcludeTaxTotal(dateList));
        orderList.add(order);
      }
    }

    // motivePrint(orderListModelToJson(orderList));

    return orderList;
  }
}
