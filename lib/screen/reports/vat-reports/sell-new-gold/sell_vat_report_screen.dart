import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/vat-reports/sell-new-gold/preview.dart';
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

class SellVatReportScreen extends StatefulWidget {
  const SellVatReportScreen({super.key});

  @override
  State<SellVatReportScreen> createState() => _SellVatReportScreenState();
}

class _SellVatReportScreenState extends State<SellVatReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
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
    loadProducts();
    search();
  }

  void loadProducts() async {
    try {
      var result = await ApiServices.post(
          '/product/type/NEW/1', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/branch', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
        });
      } else {
        warehouseList = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void search() async {
    // if (yearCtrl.text.isEmpty) {
    //   Alert.warning(context, 'คำเตือน', 'กรุณาเลือกปี', 'OK');
    //   return;
    // }
    //
    // if (monthCtrl.text.isEmpty) {
    //   Alert.warning(context, 'คำเตือน', 'กรุณาเลือกเดือน', 'OK');
    //   return;
    // }

    makeSearchDate();

    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/1',
          Global.requestObj({
            "year": yearCtrl.text == "" ? null : yearCtrl.text,
            "month": monthCtrl.text == "" ? null : monthCtrl.text,
            "productId": selectedProduct?.id,
            "warehouseId": selectedWarehouse?.id,
            "fromDate": fromDate.toString(),
            "toDate": toDate.toString(),
          }));
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

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
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
                const Expanded(
                  flex: 5,
                  child: Text("รายงานภาษีขายทองคำรูปพรรณใหม่ 96.5%",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (filterList!.isEmpty) {
                              Alert.warning(
                                  context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PreviewSellVatReportPage(
                                  orders: filterList!.reversed.toList(),
                                  type: 1,
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  date:
                                      '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.print,
                                  size: 50, color: Colors.white),
                              Text(
                                'แบบเรียงเบอร์',
                                style: TextStyle(
                                    fontSize: size.getWidthPx(8),
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            List<OrderModel> dailyList =
                                genDailyList(filterList);
                            if (dailyList.isEmpty) {
                              Alert.warning(
                                  context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PreviewSellVatReportPage(
                                  orders: dailyList,
                                  type: 2,
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  date:
                                      '${Global.formatDateNT(fromDate.toString())} - ${Global.formatDateNT(toDate.toString())}',
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.print,
                                  size: 50, color: Colors.white),
                              Text(
                                'แบบรายวัน',
                                style: TextStyle(
                                    fontSize: size.getWidthPx(8),
                                    color: Colors.white),
                              )
                            ],
                          ),
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
                                          'สินค้า',
                                          style: TextStyle(
                                              fontSize: size.getWidthPx(6)),
                                        ),
                                        SizedBox(
                                          height: 80,
                                          child:
                                              MiraiDropDownMenu<ProductModel>(
                                            key: UniqueKey(),
                                            children: productList,
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
                                              ProductModel? project, {
                                              bool isItemSelected = false,
                                            }) {
                                              return DropDownItemWidget(
                                                project: project,
                                                isItemSelected: isItemSelected,
                                                firstSpace: 10,
                                                fontSize: size.getWidthPx(6),
                                              );
                                            },
                                            onChanged: (ProductModel value) {
                                              selectedProduct = value;
                                              productNotifier!.value = value;
                                              search();
                                            },
                                            child: DropDownObjectChildWidget(
                                              key: GlobalKey(),
                                              fontSize: size.getWidthPx(6),
                                              projectValueNotifier:
                                                  productNotifier!,
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
                                          'คลังสินค้า',
                                          style: TextStyle(
                                              fontSize: size.getWidthPx(6)),
                                        ),
                                        SizedBox(
                                          height: 80,
                                          child:
                                              MiraiDropDownMenu<WarehouseModel>(
                                            key: UniqueKey(),
                                            children: warehouseList,
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
                                              WarehouseModel? project, {
                                              bool isItemSelected = false,
                                            }) {
                                              return DropDownItemWidget(
                                                project: project,
                                                isItemSelected: isItemSelected,
                                                firstSpace: 10,
                                                fontSize: size.getWidthPx(6),
                                              );
                                            },
                                            onChanged: (WarehouseModel value) {
                                              selectedWarehouse = value;
                                              warehouseNotifier!.value = value;
                                              search();
                                            },
                                            child: DropDownObjectChildWidget(
                                              key: GlobalKey(),
                                              fontSize: size.getWidthPx(6),
                                              projectValueNotifier:
                                                  warehouseNotifier!,
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
                                          'จากวันที่',
                                          style: TextStyle(
                                              fontSize: size.getWidthPx(8)),
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
                                                fontSize: size.getWidthPx(8),
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
                                              fontSize: size.getWidthPx(8),
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
                                              fontSize: size.getWidthPx(8)),
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
                                                fontSize: size.getWidthPx(8),
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
                                              fontSize: size.getWidthPx(8),
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
                                              fontSize: size.getWidthPx(8)),
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
                                                fontSize: size.getWidthPx(8),
                                              );
                                            },
                                            onChanged: (dynamic value) {
                                              monthCtrl.text = value.toString();
                                              monthNotifier!.value = value;
                                              search();
                                            },
                                            child: DropDownObjectChildWidget(
                                              key: GlobalKey(),
                                              fontSize: size.getWidthPx(8),
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
                                              fontSize: size.getWidthPx(8)),
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
                                                fontSize: size.getWidthPx(8),
                                              );
                                            },
                                            onChanged: (dynamic value) {
                                              yearCtrl.text = value.toString();
                                              yearNotifier!.value = value;
                                              search();
                                            },
                                            child: DropDownObjectChildWidget(
                                              key: GlobalKey(),
                                              fontSize: size.getWidthPx(8),
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

  Widget productCard(List<OrderModel?> ods) {
    return filterList!.isEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 100),
            child: const NoDataFoundWidget())
        : Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(color: Colors.grey[300]!),
                  children: [
                    TableRow(children: [
                      paddedTextBig('วัน/เดือน/ปี', align: TextAlign.center),
                      paddedTextBig('เลขที่ใบกํากับภาษี',
                          align: TextAlign.center),
                      paddedTextBig('ชื่อ', align: TextAlign.center),
                      paddedTextBig('เลขประจําตัวลูกค้า',
                          align: TextAlign.center),
                      paddedTextBig('น้ําหนัก', align: TextAlign.center),
                      paddedTextBig('หน่วย', align: TextAlign.center),
                      paddedTextBig('ยอดขายรวม\nภาษีมูลค่าเพิ่ม',
                          align: TextAlign.center),
                      paddedTextBig('มูลค่ายกเว้น', align: TextAlign.center),
                      paddedTextBig('ผลต่างรวม\nภาษีมูลค่าเพิ่ม',
                          align: TextAlign.center),
                      paddedTextBig('ฐานภาษีมูลค่าเพิ่ม',
                          align: TextAlign.center),
                      paddedTextBig('ภาษีมูลค่าเพิ่ม', align: TextAlign.center),
                      paddedTextBig('ยอดขายที่ไม่รวม\nภาษีมูลค่าเพิ่ม',
                          align: TextAlign.center),
                    ]),
                    ...ods.map((e) => TableRow(
                          decoration: const BoxDecoration(),
                          children: [
                            paddedTextBig(
                                Global.dateOnly(e!.orderDate.toString()),
                                align: TextAlign.center),
                            paddedTextBig(e.orderId, align: TextAlign.center),
                            paddedTextBig('เงินสด', align: TextAlign.center),
                            paddedTextBig(
                                Global.company != null
                                    ? Global.company!.taxNumber ?? ''
                                    : '',
                                align: TextAlign.center),
                            paddedTextBig(Global.format(getWeight(e)),
                                align: TextAlign.right),
                            paddedTextBig('กรัม', align: TextAlign.center),
                            paddedTextBig(Global.format(e.priceIncludeTax ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.purchasePrice ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.priceDiff ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.taxBase ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.taxAmount ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.priceExcludeTax ?? 0),
                                align: TextAlign.right)
                          ],
                        )),
                    TableRow(children: [
                      paddedTextBig('', style: const TextStyle(fontSize: 14)),
                      paddedTextBig(''),
                      paddedTextBig(''),
                      paddedTextBig('รวมท้ังหมด', align: TextAlign.right),
                      paddedTextBig(Global.format(getWeightTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(''),
                      paddedTextBig(Global.format(priceIncludeTaxTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(purchasePriceTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(priceDiffTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(taxBaseTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(taxAmountTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(priceExcludeTaxTotal(ods)),
                          align: TextAlign.right),
                    ])
                  ],
                ),
              ),
            ),
          );
  }

  List<OrderModel> genDailyList(List<OrderModel?>? filterList) {
    List<OrderModel> orderList = [];
    int days = Global.daysBetween(fromDate!, toDate!);
    for (int i = 0; i <= days; i++) {
      DateTime? monthDate = fromDate!.add(Duration(days: i));
      var dateList = filterList
          ?.where((element) =>
              Global.dateOnly(element!.createdDate.toString()) ==
              Global.dateOnly(monthDate.toString()))
          .toList();
      // motivePrint(dateList?.length);
      if (dateList!.isNotEmpty) {
        var order = OrderModel(
            orderId: '${dateList.last?.orderId} - ${dateList.first?.orderId}',
            orderDate: dateList.first?.orderDate,
            createdDate: monthDate,
            customerId: 0,
            weight: getWeightTotal(dateList),
            priceIncludeTax: priceIncludeTaxTotal(dateList),
            purchasePrice: purchasePriceTotal(dateList),
            priceDiff: priceDiffTotal(dateList),
            taxBase: taxBaseTotal(dateList),
            taxAmount: taxAmountTotal(dateList),
            priceExcludeTax: priceExcludeTaxTotal(dateList));
        // motivePrint(order.toJson());
        orderList.add(order);
      }
    }
    return orderList;
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

    // motivePrint(fromDate.toString());
    // motivePrint(toDate.toString());
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
}
