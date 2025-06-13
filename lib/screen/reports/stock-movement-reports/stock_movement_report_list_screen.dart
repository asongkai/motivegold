import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/stockmovement.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/preview.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/preview_stock_card.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
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
import 'package:motivegold/widget/pdf/components.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class StockMovementReportListScreen extends StatefulWidget {
  const StockMovementReportListScreen({super.key});

  @override
  State<StockMovementReportListScreen> createState() =>
      _StockMovementReportListScreenState();
}

class _StockMovementReportListScreenState
    extends State<StockMovementReportListScreen> {
  bool loading = false;
  List<StockMovementModel>? dataList = [];
  List<StockMovementModel>? filterList = [];
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  Screen? size;

  final TextEditingController productCtrl = TextEditingController();
  final TextEditingController warehouseCtrl = TextEditingController();
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    loadProducts();
    // search();
  }

  void loadProducts() async {
    // setState(() {
    //   loading = true;
    // });
    try {
      var result =
          await ApiServices.post('/product/all', Global.requestObj(null));
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
    // setState(() {
    //   loading = false;
    // });
  }

  void search() async {
    setState(() {
      loading = true;
    });

    var location = await ApiServices.post(
        '/stockmovement/search',
        Global.requestObj({
          "productId": selectedProduct?.id,
          "binLocationId": selectedWarehouse?.id,
          "fromDate": fromDateCtrl.text.isNotEmpty
              ? DateTime.parse(fromDateCtrl.text).toString()
              : null,
          "toDate": toDateCtrl.text.isNotEmpty
              ? DateTime.parse(toDateCtrl.text).toString()
              : null,
        }));
    // motivePrint(location?.toJson());
    if (location?.status == "success") {
      var data = jsonEncode(location?.data);
      List<StockMovementModel> products = stockMovementListModelFromJson(data);
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
                  flex: 6,
                  child: Text("รายงานความเคลื่อนไหวสต๊อกสินค้า",
                      style: TextStyle(
                          fontSize: size.getWidthPx(10),
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (selectedWarehouse == null) {
                              Alert.warning(context, 'คำเตือน',
                                  'กรุณาเลือกคลังสินค้า', 'OK',
                                  action: () {});
                              return;
                            }

                            if (selectedProduct == null) {
                              Alert.warning(
                                  context, 'คำเตือน', 'กรุณาเลือกสินค้า', 'OK',
                                  action: () {});
                              return;
                            }

                            if (fromDateCtrl.text.isEmpty) {
                              Alert.warning(context, 'คำเตือน',
                                  'กรุณาเลือกจากวันที่', 'OK',
                                  action: () {});
                              return;
                            }

                            if (toDateCtrl.text.isEmpty) {
                              Alert.warning(context, 'คำเตือน',
                                  'กรุณาเลือกถึงวันที่', 'OK',
                                  action: () {});
                              return;
                            }

                            if (filterList!.isEmpty) {
                              Alert.warning(
                                  context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                              return;
                            }

                            final ProgressDialog pr = ProgressDialog(context,
                                type: ProgressDialogType.normal,
                                isDismissible: true,
                                showLogs: true);
                            await pr.show();
                            pr.update(message: 'processing'.tr());

                            var location = await ApiServices.post(
                                '/stockmovement/search/balance',
                                Global.requestObj({
                                  "productId": selectedProduct?.id,
                                  "binLocationId": selectedWarehouse?.id,
                                  "fromDate": fromDateCtrl.text.isNotEmpty
                                      ? DateTime.parse(fromDateCtrl.text)
                                          .toString()
                                      : null,
                                  "toDate": toDateCtrl.text.isNotEmpty
                                      ? DateTime.parse(toDateCtrl.text)
                                          .toString()
                                      : null,
                                }));
                            motivePrint(location?.toJson());
                            StockMovementModel? product;
                            if (location?.status == "success") {
                              product =
                                  StockMovementModel.fromJson(location?.data);
                              setState(() {});
                            }

                            await pr.hide();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PreviewStockCardReportPage(
                                  list: filterList!.reversed.toList(),
                                  type: 1,
                                  warehouseModel: selectedWarehouse,
                                  productModel: selectedProduct,
                                  stockMovementModel: product,
                                  date:
                                      '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.print,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text(
                                'พิมพ์ Stock card',
                                style: TextStyle(
                                    fontSize: size.getWidthPx(8),
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (filterList!.isEmpty) {
                              Alert.warning(
                                  context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PreviewStockMovementReportPage(
                                  list: filterList!.reversed.toList(),
                                  type: 1,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.print,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text(
                                'พิมพ์',
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
                                          'คลังสินค้า',
                                          style: TextStyle(
                                              fontSize: size.getWidthPx(10)),
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
                                                fontSize: size.getWidthPx(10),
                                              );
                                            },
                                            onChanged: (WarehouseModel value) {
                                              warehouseCtrl.text =
                                                  value.name.toString();
                                              selectedWarehouse = value;
                                              warehouseNotifier!.value = value;
                                              search();
                                            },
                                            child: DropDownObjectChildWidget(
                                              key: GlobalKey(),
                                              fontSize: size.getWidthPx(10),
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
                                              fontSize: size.getWidthPx(10)),
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
                                                fontSize: size.getWidthPx(10),
                                              );
                                            },
                                            onChanged: (ProductModel value) {
                                              productCtrl.text = value.name;
                                              selectedProduct = value;
                                              productNotifier!.value = value;
                                              search();
                                            },
                                            child: DropDownObjectChildWidget(
                                              key: GlobalKey(),
                                              fontSize: size.getWidthPx(10),
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
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: TextField(
                                  controller: fromDateCtrl,
                                  style:
                                      TextStyle(fontSize: size.getWidthPx(12)),
                                  //editing controller of this TextField
                                  decoration: InputDecoration(
                                    prefixIcon:
                                        const Icon(Icons.calendar_today),
                                    //icon of text field
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    suffixIcon: fromDateCtrl.text.isNotEmpty
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                fromDateCtrl.text = "";
                                                toDateCtrl.text = "";
                                                filterList = dataList;
                                              });
                                            },
                                            child: const Icon(Icons.clear))
                                        : null,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    labelText: "จากวันที่",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(2),
                                      ),
                                      borderSide: const BorderSide(
                                        color: kGreyShade3,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(2),
                                      ),
                                      borderSide: const BorderSide(
                                        color: kGreyShade3,
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  //set it true, so that user will not able to edit text
                                  onTap: () async {

                                    showDialog(
                                      context: context,
                                      builder: (_) => SfDatePickerDialog(
                                        initialDate: DateTime.now(),
                                        onDateSelected: (date) {
                                          motivePrint('You picked: $date');
                                          // Your logic here
                                          String formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(date);
                                          motivePrint(
                                              formattedDate); //formatted date output using intl package =>  2021-03-16
                                          //you can implement different kind of Date Format here according to your requirement
                                          setState(() {
                                            fromDateCtrl.text =
                                                formattedDate; //set output date to TextField value.
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: TextField(
                                  controller: toDateCtrl,
                                  //editing controller of this TextField
                                  style:
                                      TextStyle(fontSize: size.getWidthPx(12)),
                                  //editing controller of this TextField
                                  decoration: InputDecoration(
                                    prefixIcon:
                                        const Icon(Icons.calendar_today),
                                    //icon of text field
                                    suffixIcon: toDateCtrl.text.isNotEmpty
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                toDateCtrl.text = "";
                                                fromDateCtrl.text = "";
                                                filterList = dataList;
                                              });
                                            },
                                            child: const Icon(Icons.clear))
                                        : null,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    labelText: "ถึงวันที่",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(2),
                                      ),
                                      borderSide: const BorderSide(
                                        color: kGreyShade3,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(2),
                                      ),
                                      borderSide: const BorderSide(
                                        color: kGreyShade3,
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  //set it true, so that user will not able to edit text
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (_) => SfDatePickerDialog(
                                        initialDate: DateTime.now(),
                                        onDateSelected: (date) {
                                          motivePrint('You picked: $date');
                                          // Your logic here
                                          String formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(date);
                                          motivePrint(
                                              formattedDate); //formatted date output using intl package =>  2021-03-16
                                          //you can implement different kind of Date Format here according to your requirement
                                          setState(() {
                                            toDateCtrl.text =
                                                formattedDate; //set output date to TextField value.
                                          });
                                        },
                                      ),
                                    );
                                  },
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
                                          WidgetStateProperty.all<Color>(
                                              bgColor3)),
                                  onPressed: search,
                                  child: const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search),
                                      Text(
                                        'ค้นหา',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.red)),
                                  onPressed: () {
                                    productNotifier =
                                        ValueNotifier<ProductModel>(
                                            ProductModel(
                                                name: 'เลือกสินค้า', id: 0));
                                    warehouseNotifier =
                                        ValueNotifier<WarehouseModel>(
                                            WarehouseModel(
                                                id: 0,
                                                name: 'เลือกคลังสินค้า'));
                                    productCtrl.text = "";
                                    warehouseCtrl.text = "";
                                    selectedProduct = null;
                                    selectedWarehouse = null;
                                    toDateCtrl.text = "";
                                    fromDateCtrl.text = "";
                                    search();
                                    setState(() {});
                                  },
                                  child: const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.clear),
                                      Text(
                                        'Reset',
                                        style: TextStyle(fontSize: 20),
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
                  : productCard(filterList),
            ],
          ),
        ),
      ),
    );
  }

  Widget productCard(List<StockMovementModel>? productList) {
    return filterList!.isEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 100),
            child: const NoDataFoundWidget())
        : Expanded(
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey[300]!),
                    children: [
                      TableRow(children: [
                        paddedTextBig('เลขที่ใบ\nกํากับภาษ'),
                        paddedTextBig('วัน/เดือน/ปี'),
                        paddedTextBig('สินค้า'),
                        paddedTextBig('คลังสินค้า'),
                        paddedTextBig('ประเภท\nการเคลื่อนไหว'),
                        paddedTextBig('ประเภท\nเอกสาร'),
                        paddedTextBig('น้ำหนักรวม'),
                        paddedTextBig('ราคา\nต่อหน่วย'),
                        paddedTextBig('ราคารวม'),
                      ]),
                      ...productList!.map((e) => TableRow(
                            decoration: const BoxDecoration(),
                            children: [
                              paddedTextBig(e.orderId!),
                              paddedTextBig(
                                  Global.dateOnly(e.createdDate.toString())),
                              paddedTextBig(
                                  e.product == null ? "" : e.product!.name),
                              paddedTextBig(e.binLocation == null
                                  ? ""
                                  : e.binLocation!.name),
                              paddedTextBig('${e.type!} '),
                              paddedTextBig('${e.docType!} '),
                              paddedTextBig(' ${Global.format(e.weight ?? 0)}',
                                  style: const TextStyle(fontSize: 16),
                                  align: TextAlign.right),
                              paddedTextBig(
                                  ' ${Global.format6(e.unitCost ?? 0)}',
                                  style: const TextStyle(fontSize: 16),
                                  align: TextAlign.right),
                              paddedTextBig(' ${Global.format6(e.price ?? 0)}',
                                  style: const TextStyle(fontSize: 16),
                                  align: TextAlign.right),
                            ],
                          )),
                      // TableRow(children: [
                      //   paddedTextBig('', style: const TextStyle(fontSize: 14)),
                      //   paddedTextBig(''),
                      //   paddedTextBig(''),
                      //   paddedTextBig('รวมท้ังหมด'),
                      //   paddedTextBig(Global.format(getWeightTotal(ods))),
                      //   paddedTextBig(''),
                      //   paddedTextBig(Global.format(priceIncludeTaxTotal(ods))),
                      //   paddedTextBig(Global.format(purchasePriceTotal(ods))),
                      //   paddedTextBig(Global.format(priceDiffTotal(ods))),
                      //   paddedTextBig(Global.format(taxBaseTotal(ods))),
                      //   paddedTextBig(Global.format(taxAmountTotal(ods))),
                      //   paddedTextBig(Global.format(priceExcludeTaxTotal(ods))),
                      // ])
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
