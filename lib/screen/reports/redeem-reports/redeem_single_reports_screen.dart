import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/buy-used-gold-gov-reports/preview.dart';
import 'package:motivegold/screen/reports/redeem-reports/preview_redeem_single.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
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
import 'package:sizer/sizer.dart';
class RedeemSingleReportScreen extends StatefulWidget {
  const RedeemSingleReportScreen({super.key});

  @override
  State<RedeemSingleReportScreen> createState() =>
      _RedeemSingleReportScreenState();
}

class _RedeemSingleReportScreenState
    extends State<RedeemSingleReportScreen> {
  bool loading = false;
  List<RedeemModel>? orders = [];
  List<RedeemModel?>? filterList = [];
  Screen? size;

  final TextEditingController yearCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  ValueNotifier<dynamic>? yearNotifier;
  ValueNotifier<dynamic>? monthNotifier;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  ValueNotifier<dynamic>? fromDateNotifier;
  ValueNotifier<dynamic>? toDateNotifier;
  DateTime? fromDate;
  DateTime? toDate;

  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  @override
  void initState() {
    super.initState();
    resetFilter();
    search();
  }

  void search() async {

    makeSearchDate();

    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/redeem/all/reports',
          Global.reportRequestObj({
            "year": yearCtrl.text == "" ? null : yearCtrl.text,
            "month": monthCtrl.text == "" ? null : monthCtrl.text,
            "fromDate": fromDate.toString(),
            "toDate": toDate.toString(),
          }));
      // motivePrint(result?.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<RedeemModel> products = redeemListModelFromJson(data);
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

  makeSearchDate() {
    int month = 0;
    int year = 0;

    if (monthCtrl.text.isEmpty) {
      month = DateTime.now().month;
    } else {
      month = Global.toNumber(monthCtrl.text).toInt();
    }

    if (yearCtrl.text.isEmpty) {
      year = DateTime.now().year;
    } else {
      year = Global.toNumber(yearCtrl.text).toInt();
    }

    if (fromDateCtrl.text.isNotEmpty) {
      fromDate = Global.convertDate(
          '${twoDigit(Global.toNumber(fromDateCtrl.text).toInt())}-${twoDigit(month)}-$year');
    } else {
      fromDate = null;
    }

    if (toDateCtrl.text.isNotEmpty) {
      toDate = Global.convertDate(
          '${twoDigit(Global.toNumber(toDateCtrl.text).toInt())}-${twoDigit(month)}-$year');
    } else {
      toDate = null;
    }

    if (fromDate == null && toDate == null) {
      if (monthCtrl.text.isNotEmpty && yearCtrl.text.isEmpty) {
        fromDate = DateTime(year, month, 1);
        toDate = Jiffy.parseFromDateTime(fromDate!).endOf(Unit.month).dateTime;
      } else if (monthCtrl.text.isEmpty && yearCtrl.text.isNotEmpty) {
        fromDate = DateTime(year, 1, 1);
        toDate = Jiffy.parseFromDateTime(fromDate!)
            .add(months: 12, days: -1)
            .dateTime;
      } else {
        fromDate = DateTime(year, month, 1);
        toDate = Jiffy.parseFromDateTime(fromDate!).endOf(Unit.month).dateTime;
      }
    }

    motivePrint(fromDate.toString());
    motivePrint(toDate.toString());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  flex: 5,
                  child: Text("รายงานภาษีขายตามสัญญาขายฝาก",
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PopupMenuButton<int>(
                          onSelected: (int value) {
                                if (filterList!.isEmpty) {
                                  Alert.warning(
                                      context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                                  return;
                                }
                                List<RedeemModel> dailyList = [];
                                if (value == 4) {
                                  List<RedeemModel> daily =
                                  genDailyList(filterList!.reversed.toList());
                                  if (daily.isEmpty) {
                                    Alert.warning(
                                        context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                                    return;
                                  }

                                  int days = Global.daysBetween(fromDate!, toDate!);

                                  for (int j = 0; j <= days; j++) {
                                    var indexDay = fromDate?.add(Duration(days: j));
                                    // motivePrint(indexDay);
                                    for (int i = 0; i < daily.length; i++) {
                                      // motivePrint(orders[i]!.createdDate);
                                      if (daily[i].createdDate == indexDay) {
                                        daily[i].referenceNo = 'รวมใบกำกับภาษีประจำวัน';
                                        dailyList.add(daily[i]);
                                      } else {
                                        var checkExisting =
                                        dailyList.where((e) => e.createdDate == indexDay).toList();
                                        if (checkExisting.isEmpty) {
                                          dailyList.add(RedeemModel(
                                              redeemId: 'ไม่มียอดไถ่ถอน',
                                              redeemDate: indexDay,
                                              referenceNo: '',
                                              customer: daily[i].customer));
                                        }
                                      }
                                    }
                                  }
                                }

                                if (value == 4 && dailyList.isEmpty) {
                                  Alert.warning(
                                      context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                                  return;
                                }

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PreviewRedeemSingleReportPage(
                                          orders: filterList!.reversed.toList(),
                                          daily: value == 4 ? dailyList.toList() : [],
                                          type: value,
                                          date: '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
                                        ),
                                  ),
                                );
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 1,
                              child: ListTile(
                                leading: Icon(Icons.print, size: 16.sp),
                                title: Text('เรียงเลขที่ตั๋วสัญญาขายฝาก', style: TextStyle(fontSize: 16.sp),),
                              ),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: ListTile(
                                leading: Icon(Icons.print, size:16.sp),
                                title: Text('เรียงเลขที่เอกสาร(รายตั๋ว)', style: TextStyle(fontSize: 16.sp),),
                              ),
                            ),
                            PopupMenuItem(
                              value: 3,
                              child: ListTile(
                                leading: Icon(Icons.print, size: 16.sp),
                                title: Text('เรียงเลขที่เอกสาร(สรุปยอด)', style: TextStyle(fontSize: 16.sp),),
                              ),
                            ),
                            PopupMenuItem(
                              value: 4,
                              child: ListTile(
                                leading: Icon(Icons.print, size: 16.sp,),
                                title: Text('เรียงวันที่', style: TextStyle(fontSize: 16.sp),),
                              ),
                            ),
                          ],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'พิมพ์',
                                style: TextStyle(
                                    fontSize: 16.sp,       // Bigger font size
                                    color: Colors.white // White color
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down_outlined, color: Colors.white, size: 16.sp,),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
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
                                              'จากวันที่',
                                              style: TextStyle(
                                                  fontSize: 16.sp),
                                            ),
                                            SizedBox(
                                              height: 70,
                                              child: MiraiDropDownMenu<dynamic>(
                                                key: UniqueKey(),
                                                children: Global.genMonthDays(),
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
                                                    dynamic project, {
                                                      bool isItemSelected = false,
                                                    }) {
                                                  return DropDownItemWidget(
                                                    project: project,
                                                    isItemSelected: isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 16.sp,
                                                  );
                                                },
                                                onChanged: (dynamic value) {
                                                  fromDateCtrl.text =
                                                      value.toString();
                                                  fromDateNotifier!.value = value;
                                                  search();
                                                },
                                                child: DropDownObjectChildWidget(
                                                  key: GlobalKey(),
                                                  fontSize: 16.sp,
                                                  projectValueNotifier:
                                                  fromDateNotifier!,
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
                                              'ถึงวันที่',
                                              style: TextStyle(
                                                  fontSize: 16.sp),
                                            ),
                                            SizedBox(
                                              height: 70,
                                              child: MiraiDropDownMenu<dynamic>(
                                                key: UniqueKey(),
                                                children: Global.genMonthDays(),
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
                                                    dynamic project, {
                                                      bool isItemSelected = false,
                                                    }) {
                                                  return DropDownItemWidget(
                                                    project: project,
                                                    isItemSelected: isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 16.sp,
                                                  );
                                                },
                                                onChanged: (dynamic value) {
                                                  toDateCtrl.text =
                                                      value.toString();
                                                  toDateNotifier!.value = value;
                                                  search();
                                                },
                                                child: DropDownObjectChildWidget(
                                                  key: GlobalKey(),
                                                  fontSize: 16.sp,
                                                  projectValueNotifier:
                                                  toDateNotifier!,
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
                                              'เดือน',
                                              style: TextStyle(
                                                  fontSize: 16.sp),
                                            ),
                                            SizedBox(
                                              height: 70,
                                              child: MiraiDropDownMenu<dynamic>(
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
                                                    dynamic project, {
                                                      bool isItemSelected = false,
                                                    }) {
                                                  return DropDownItemWidget(
                                                    project: project,
                                                    isItemSelected: isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 16.sp,
                                                  );
                                                },
                                                onChanged: (dynamic value) {
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
                                                  fontSize: 16.sp),
                                            ),
                                            SizedBox(
                                              height: 70,
                                              child: MiraiDropDownMenu<dynamic>(
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
                                                    dynamic project, {
                                                      bool isItemSelected = false,
                                                    }) {
                                                  return DropDownItemWidget(
                                                    project: project,
                                                    isItemSelected: isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 16.sp,
                                                  );
                                                },
                                                onChanged: (dynamic value) {
                                                  yearCtrl.text = value.toString();
                                                  yearNotifier!.value = value;
                                                  search();
                                                },
                                                child: DropDownObjectChildWidget(
                                                  key: GlobalKey(),
                                                  fontSize: 16.sp,
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
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: getProportionateScreenWidth(3.0),
                                      vertical: getProportionateScreenHeight(5.0),
                                    ),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.red)),
                                      onPressed: () {
                                        resetFilter();
                                      },
                                      child: Text(
                                        'Reset'.tr(),
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: getProportionateScreenWidth(3.0),
                                      vertical: getProportionateScreenHeight(5.0),
                                    ),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              bgColor3)),
                                      onPressed: search,
                                      child: Text(
                                        'ค้นหา'.tr(),
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

  Widget productCard(List<RedeemModel?> ods) {
    return filterList!.isEmpty
        ? Container(
        margin: const EdgeInsets.only(top:50),
        child: const NoDataFoundWidget())
        : Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder.all(color: Colors.grey[300]!),
            children: [
              TableRow(children: [
                paddedTextBigL('วัน/เดือน/ปี', align: TextAlign.center),
                paddedTextBigL('เลขท่ีใบสําคัญรับเงิน',
                    align: TextAlign.center),
                paddedTextBigL('ผู้ซื้อ', align: TextAlign.center),
                paddedTextBigL('เลขประจําตัวผู้เสียภาษี',
                    align: TextAlign.center),
                paddedTextBigL('รายการสินค้า', align: TextAlign.center),
                paddedTextBigL('น้ําหนัก (กรัม)',
                    align: TextAlign.center),
                paddedTextBigL('จํานวนเงิน (บาท)',
                    align: TextAlign.center),
              ]),
              ...ods.map((e) => TableRow(
                decoration: const BoxDecoration(),
                children: [
                  paddedTextBigL(
                      Global.dateOnly(e!.redeemDate.toString()),
                      align: TextAlign.center),
                  paddedTextBigL(e.redeemId ?? '', align: TextAlign.center),
                  paddedTextBigL(
                      '${e.customer!.firstName!} ${e.customer!.lastName!}',
                      align: TextAlign.center),
                  paddedTextBigL(
                      Global.company != null
                          ? Global.company!.taxNumber ?? ''
                          : '',
                      align: TextAlign.center),
                  paddedTextBigL('ทองคำรูปพรรณ 96.5%', align: TextAlign.center),
                  paddedTextBigL(
                      '${Global.format(getWeight(e))}',
                      align: TextAlign.right),
                  paddedTextBigL(
                      Global.format(e.paymentAmount ?? 0),
                      align: TextAlign.right)
                ],
              )),
              TableRow(children: [
                paddedTextBigL('', style: const TextStyle(fontSize: 14)),
                paddedTextBigL(''),
                paddedTextBigL(''),
                paddedTextBigL(''),
                paddedTextBigL('รวมท้ังหมด', align: TextAlign.right),
                paddedTextBigL(
                    '${Global.format(getWeightTotal(ods))}',
                    align: TextAlign.right),
                paddedTextBigL(Global.format(getPaymentAmountTotal(ods)),
                    align: TextAlign.right),
              ])
            ],
          ),
        ),
      ),
    );
  }

  void resetFilter() {
    yearNotifier = ValueNotifier<dynamic>("");
    monthNotifier = ValueNotifier<dynamic>("");
    fromDateNotifier = ValueNotifier<dynamic>("");
    toDateNotifier = ValueNotifier<dynamic>("");
    yearCtrl.text = "";
    monthCtrl.text = "";
    fromDateCtrl.text = "";
    toDateCtrl.text = "";
    fromDate = null;
    toDate = null;
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    search();
    setState(() {});
  }

  List<RedeemModel> genDailyList(List<RedeemModel?>? filterList) {
    List<RedeemModel> orderList = [];
    int days = Global.daysBetween(fromDate!, toDate!);
    for (int i = 0; i <= days; i++) {
      DateTime? monthDate = fromDate!.add(Duration(days: i));
      // motivePrint(monthDate);
      var dateList = filterList
          ?.where((element) =>
      Global.dateOnly(element!.createdDate.toString()) ==
          Global.dateOnly(monthDate.toString()))
          .toList();
      motivePrint(dateList?.length);
      if (dateList!.isNotEmpty) {
        var order = RedeemModel(
            redeemId: '${dateList.first?.redeemId} - ${dateList.last?.redeemId}',
            redeemDate: dateList.first?.redeemDate,
            createdDate: monthDate,
            customerId: 0,
            weight: getWeightTotal(dateList),
            redemptionVat: getRedemptionVatTotal(dateList),
            redemptionValue: getRedemptionValueTotal(dateList),
            depositAmount: getDepositAmountTotal(dateList),
            taxBase: taxBaseTotal(dateList),
            taxAmount: taxAmountTotal(dateList),);
        orderList.add(order);
      }
    }
    return orderList;
  }
}
