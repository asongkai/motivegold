import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/screen/settings/reports/stock-reports/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';

class StockReportListScreen extends StatefulWidget {
  const StockReportListScreen({super.key});

  @override
  State<StockReportListScreen> createState() => _StockReportListScreenState();
}

class _StockReportListScreenState extends State<StockReportListScreen> {
  bool loading = false;
  List<QtyLocationModel>? dataList = [];
  List<QtyLocationModel>? filterList = [];
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  Screen? size;

  final TextEditingController productCtrl = TextEditingController();
  final TextEditingController warehouseCtrl = TextEditingController();
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  @override
  void initState() {
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    loadProducts();
    search();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {

      var result = await ApiServices.post('/product/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post('/binlocation/all', Global.requestObj(null));
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
    setState(() {
      loading = false;
    });
  }

  void search() async {

    setState(() {
      loading = true;
    });

    var location =
    await ApiServices.post('/qtybylocation/search', Global.requestObj({
      "productId": selectedProduct?.id,
      "binLocationId": selectedWarehouse?.id
    }));
    if (location?.status == "success") {
      var data = jsonEncode(location?.data);
      List<QtyLocationModel> products = qtyLocationListModelFromJson(data);
      setState(() {
        dataList = products;
        filterList = products;
      });
    } else {
      dataList = [];
      filterList!.clear();
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายงานสต็อก'),
        actions: [
          GestureDetector(
            onTap: () {
              if (filterList!.isEmpty) {
                Alert.warning(context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PreviewStockReportPage(list: filterList!, type: 1,),
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
                  'พิมพ์',
                  style: TextStyle(fontSize: size.getWidthPx(6)),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                                                    child: MiraiDropDownMenu<
                                                        ProductModel>(
                                                      key:
                                                      UniqueKey(),
                                                      children:
                                                      productList,
                                                      space: 4,
                                                      maxHeight:
                                                      360,
                                                      showSearchTextField:
                                                      true,
                                                      selectedItemBackgroundColor:
                                                      Colors
                                                          .transparent,
                                                      emptyListMessage: 'ไม่มีข้อมูล',
                                                      showSelectedItemBackgroundColor:
                                                      true,
                                                      itemWidgetBuilder:
                                                          (
                                                          int index,
                                                          ProductModel?
                                                          project, {
                                                        bool isItemSelected =
                                                        false,
                                                      }) {
                                                        return DropDownItemWidget(
                                                          project:
                                                          project,
                                                          isItemSelected:
                                                          isItemSelected,
                                                          firstSpace:
                                                          10,
                                                          fontSize:
                                                          size.getWidthPx(6),
                                                        );
                                                      },
                                                      onChanged:
                                                          (ProductModel
                                                      value) {
                                                        productCtrl.text =
                                                            value.name;
                                                        selectedProduct = value;
                                                        productNotifier!.value =
                                                            value;
                                                        search();
                                                      },
                                                      child:
                                                      DropDownObjectChildWidget(
                                                        key:
                                                        GlobalKey(),
                                                        fontSize:
                                                        size.getWidthPx(6),
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
                                                    child: MiraiDropDownMenu<
                                                        WarehouseModel>(
                                                      key:
                                                      UniqueKey(),
                                                      children:
                                                      warehouseList,
                                                      space: 4,
                                                      maxHeight:
                                                      360,
                                                      showSearchTextField:
                                                      true,
                                                      selectedItemBackgroundColor:
                                                      Colors
                                                          .transparent,
                                                      emptyListMessage: 'ไม่มีข้อมูล',
                                                      showSelectedItemBackgroundColor:
                                                      true,
                                                      itemWidgetBuilder:
                                                          (
                                                          int index,
                                                          WarehouseModel?
                                                          project, {
                                                        bool isItemSelected =
                                                        false,
                                                      }) {
                                                        return DropDownItemWidget(
                                                          project:
                                                          project,
                                                          isItemSelected:
                                                          isItemSelected,
                                                          firstSpace:
                                                          10,
                                                          fontSize:
                                                          size.getWidthPx(6),
                                                        );
                                                      },
                                                      onChanged:
                                                          (WarehouseModel
                                                      value) {
                                                        warehouseCtrl.text = value
                                                            .name
                                                            .toString();
                                                        selectedWarehouse =
                                                            value;
                                                        warehouseNotifier!.value =
                                                            value;
                                                        search();
                                                      },
                                                      child:
                                                      DropDownObjectChildWidget(
                                                        key:
                                                        GlobalKey(),
                                                        fontSize:
                                                        size.getWidthPx(6),
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
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: getProportionateScreenWidth(3.0),
                                      vertical: getProportionateScreenHeight(5.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                MaterialStateProperty.all<Color>(bgColor3)),
                                            onPressed: search,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.search),
                                                Text(
                                                  'ค้นหา'.tr(),
                                                  style: const TextStyle(fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                MaterialStateProperty.all<Color>(Colors.red)),
                                            onPressed: () {
                                              productNotifier =
                                                  ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
                                              warehouseNotifier = ValueNotifier<WarehouseModel>(WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
                                              productCtrl.text = "";
                                              warehouseCtrl.text = "";
                                              selectedProduct = null;
                                              selectedWarehouse = null;
                                              search();
                                              setState(() {

                                              });
                                            },
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.clear),
                                                Text(
                                                  'Reset'.tr(),
                                                  style: const TextStyle(fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
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
                            :  productCard(filterList),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget productCard(List<QtyLocationModel>? productList) {
    return filterList!.isEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 100),
            child: const EmptyContent())
        : Expanded(
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey[300]!),
                    children: [
                      TableRow(children: [
                        paddedTextBigXL('สินค้า'),
                        paddedTextBigXL('คลังสินค้า'),
                        paddedTextBigXL('น้ำหนักรวม'),
                        paddedTextBigXL('ราคาต่อหน่วย'),
                        paddedTextBigXL('ราคารวม'),
                      ]),
                      ...productList!.map((e) => TableRow(
                            decoration: const BoxDecoration(),
                            children: [
                              paddedTextBigXL(
                                  e.product == null ? "" : e.product!.name),
                              paddedTextBigXL(e.binLocation == null
                                  ? ""
                                  : e.binLocation!.name),
                              paddedTextBigXL(Global.format(e.weight ?? 0),
                                  style: const TextStyle(fontSize: 30),
                                  align: TextAlign.right),
                              paddedTextBigXL(
                                  Global.format(
                                      Global.getBuyPrice(e.weight ?? 0) /
                                          e.weight!),
                                  style: const TextStyle(fontSize: 30),
                                  align: TextAlign.right),
                              paddedTextBigXL(
                                  Global.format(
                                      Global.getBuyPrice(e.weight ?? 0)),
                                  style: const TextStyle(fontSize: 30),
                                  align: TextAlign.right),
                            ],
                          )),
                      // TableRow(children: [
                      //   paddedTextBigXL('', style: const TextStyle(fontSize: 14)),
                      //   paddedTextBigXL(''),
                      //   paddedTextBigXL(''),
                      //   paddedTextBigXL('รวมท้ังหมด'),
                      //   paddedTextBigXL(Global.format(getWeightTotal(ods))),
                      //   paddedTextBigXL(''),
                      //   paddedTextBigXL(Global.format(priceIncludeTaxTotal(ods))),
                      //   paddedTextBigXL(Global.format(purchasePriceTotal(ods))),
                      //   paddedTextBigXL(Global.format(priceDiffTotal(ods))),
                      //   paddedTextBigXL(Global.format(taxBaseTotal(ods))),
                      //   paddedTextBigXL(Global.format(taxAmountTotal(ods))),
                      //   paddedTextBigXL(Global.format(priceExcludeTaxTotal(ods))),
                      // ])
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
